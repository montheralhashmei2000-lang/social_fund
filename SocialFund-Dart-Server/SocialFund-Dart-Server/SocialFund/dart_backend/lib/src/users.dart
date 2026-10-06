import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart' hide TxSession;
import 'package:uuid/uuid.dart';

import 'config.dart';
import 'database.dart';
import 'http.dart';
import 'rbac.dart';
import 'security.dart';

void registerUserRoutes(Router router, Database db, AppConfig config) {
  // List all users (admin only)
  router.get('/users', (request) async {
    final rows = await db.query(
      'SELECT id, username, full_name, role, is_active, phone FROM users WHERE deleted=false ORDER BY full_name',
    );
    return jsonResponse(rows.map(_userOut).toList());
  });

  // Get current user's colleagues (for messaging)
  router.get('/users/colleagues', (request) async {
    final userId = request.context['userId'] as String;
    final rows = await db.query(
      'SELECT id, username, full_name, role, avatar_initial FROM users WHERE deleted=false AND is_active=true AND id != @id ORDER BY full_name',
      {'id': userId},
    );
    return jsonResponse(rows.map((r) => {
      'id': '${r['id']}',
      'username': r['username'],
      'full_name': r['full_name'],
      'role': r['role'],
      'avatar_initial': r['avatar_initial'],
    }).toList());
  });

  // Create user (admin only)
  router.post('/users', (request) async {
    try {
      final body = await readJson(request);
      final username = stringValue(body, 'username')?.trim();
      final password = stringValue(body, 'password');
      final fullName = stringValue(body, 'full_name')?.trim();
      final role = stringValue(body, 'role');
      final phone = stringValue(body, 'phone');

      if (username == null || username.isEmpty || password == null || password.length < 8) {
        return jsonResponse({'detail': 'Username and password (min 8 chars) required'}, status: 400);
      }
      if (fullName == null || fullName.isEmpty) {
        return jsonResponse({'detail': 'Full name is required'}, status: 400);
      }
      if (!['admin', 'accountant', 'reviewer', 'viewer'].contains(role)) {
        return jsonResponse({'detail': 'Invalid role'}, status: 400);
      }

      final existing = await db.query(
        'SELECT id FROM users WHERE username=@username AND deleted=false',
        {'username': username},
      );
      if (existing.isNotEmpty) {
        return jsonResponse({'detail': 'Username already exists'}, status: 400);
      }

      final id = _uuid.v4();
      final avatarInitial = fullName[0];
      await db.query(
        'INSERT INTO users(id, username, password_hash, full_name, role, avatar_initial, is_active, phone) VALUES (@id, @username, @hash, @full, @role, @avatar, true, @phone)',
        {
          'id': id,
          'username': username,
          'hash': hashPassword(password),
          'full': fullName,
          'role': role,
          'avatar': avatarInitial,
          'phone': phone,
        },
      );
      final rows = await db.query(
        'SELECT id, username, full_name, role, is_active, phone FROM users WHERE id=@id',
        {'id': id},
      );
      return jsonResponse(_userOut(rows.first), status: 201);
    } on FormatException catch (e) {
      return jsonResponse({'detail': e.message}, status: 400);
    }
  });

  // Update user (admin only)
  router.put('/users/<id>', (request) async {
    final userId = request.params['id'];
    try {
      final body = await readJson(request);
      final fullName = stringValue(body, 'full_name');
      final role = stringValue(body, 'role');
      final phone = stringValue(body, 'phone');
      final isActive = body['is_active'];

      if (role != null && !['admin', 'accountant', 'reviewer', 'viewer'].contains(role)) {
        return jsonResponse({'detail': 'Invalid role'}, status: 400);
      }

      final updates = <String, Object?>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (role != null) updates['role'] = role;
      if (phone != null) updates['phone'] = phone;
      if (isActive != null) updates['is_active'] = isActive;

      if (updates.isEmpty) {
        return jsonResponse({'detail': 'No updates provided'}, status: 400);
      }

      final setClause = updates.keys.map((k) => '$k = @$k').join(', ');
      await db.query(
        'UPDATE users SET $setClause, updated_at=now() WHERE id=@id AND deleted=false',
        {...updates, 'id': userId},
      );
      final rows = await db.query(
        'SELECT id, username, full_name, role, is_active, phone FROM users WHERE id=@id',
        {'id': userId},
      );
      if (rows.isEmpty) {
        return jsonResponse({'detail': 'User not found'}, status: 404);
      }
      return jsonResponse(_userOut(rows.first));
    } on FormatException catch (e) {
      return jsonResponse({'detail': e.message}, status: 400);
    }
  });

  // Delete user (admin only, soft delete)
  router.delete('/users/<id>', (request) async {
    final userId = request.params['id'];
    final currentUserId = request.context['userId'] as String;
    if (userId == currentUserId) {
      return jsonResponse({'detail': 'Cannot delete your own account'}, status: 400);
    }
    await db.query(
      'UPDATE users SET deleted=true, is_active=false, updated_at=now() WHERE id=@id AND deleted=false',
      {'id': userId},
    );
    return jsonResponse({'message': 'User deleted'});
  });
}

Map<String, dynamic> _userOut(Map<String, dynamic> u) => {
  'id': '${u['id']}',
  'username': u['username'],
  'full_name': u['full_name'],
  'role': u['role'],
  'is_active': u['is_active'],
  'phone': u['phone']?.toString(),
};

final _uuid = const Uuid();
