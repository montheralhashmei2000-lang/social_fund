// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('viewer'));
  static const VerificationMeta _avatarInitialMeta =
      const VerificationMeta('avatarInitial');
  @override
  late final GeneratedColumn<String> avatarInitial = GeneratedColumn<String>(
      'avatar_initial', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('?'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _otpEnabledMeta =
      const VerificationMeta('otpEnabled');
  @override
  late final GeneratedColumn<bool> otpEnabled = GeneratedColumn<bool>(
      'otp_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("otp_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _biometricEnabledMeta =
      const VerificationMeta('biometricEnabled');
  @override
  late final GeneratedColumn<bool> biometricEnabled = GeneratedColumn<bool>(
      'biometric_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("biometric_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        username,
        passwordHash,
        fullName,
        role,
        avatarInitial,
        isActive,
        phone,
        otpEnabled,
        biometricEnabled,
        createdAt,
        updatedAt,
        deleted,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('avatar_initial')) {
      context.handle(
          _avatarInitialMeta,
          avatarInitial.isAcceptableOrUnknown(
              data['avatar_initial']!, _avatarInitialMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('otp_enabled')) {
      context.handle(
          _otpEnabledMeta,
          otpEnabled.isAcceptableOrUnknown(
              data['otp_enabled']!, _otpEnabledMeta));
    }
    if (data.containsKey('biometric_enabled')) {
      context.handle(
          _biometricEnabledMeta,
          biometricEnabled.isAcceptableOrUnknown(
              data['biometric_enabled']!, _biometricEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      avatarInitial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_initial'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      otpEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}otp_enabled'])!,
      biometricEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}biometric_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String username;
  final String passwordHash;
  final String fullName;
  final String role;
  final String avatarInitial;
  final bool isActive;
  final String? phone;
  final bool otpEnabled;
  final bool biometricEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String? deviceId;
  const User(
      {required this.id,
      required this.username,
      required this.passwordHash,
      required this.fullName,
      required this.role,
      required this.avatarInitial,
      required this.isActive,
      this.phone,
      required this.otpEnabled,
      required this.biometricEnabled,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<String>(passwordHash);
    map['full_name'] = Variable<String>(fullName);
    map['role'] = Variable<String>(role);
    map['avatar_initial'] = Variable<String>(avatarInitial);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['otp_enabled'] = Variable<bool>(otpEnabled);
    map['biometric_enabled'] = Variable<bool>(biometricEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      passwordHash: Value(passwordHash),
      fullName: Value(fullName),
      role: Value(role),
      avatarInitial: Value(avatarInitial),
      isActive: Value(isActive),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      otpEnabled: Value(otpEnabled),
      biometricEnabled: Value(biometricEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      fullName: serializer.fromJson<String>(json['fullName']),
      role: serializer.fromJson<String>(json['role']),
      avatarInitial: serializer.fromJson<String>(json['avatarInitial']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      phone: serializer.fromJson<String?>(json['phone']),
      otpEnabled: serializer.fromJson<bool>(json['otpEnabled']),
      biometricEnabled: serializer.fromJson<bool>(json['biometricEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'fullName': serializer.toJson<String>(fullName),
      'role': serializer.toJson<String>(role),
      'avatarInitial': serializer.toJson<String>(avatarInitial),
      'isActive': serializer.toJson<bool>(isActive),
      'phone': serializer.toJson<String?>(phone),
      'otpEnabled': serializer.toJson<bool>(otpEnabled),
      'biometricEnabled': serializer.toJson<bool>(biometricEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  User copyWith(
          {String? id,
          String? username,
          String? passwordHash,
          String? fullName,
          String? role,
          String? avatarInitial,
          bool? isActive,
          Value<String?> phone = const Value.absent(),
          bool? otpEnabled,
          bool? biometricEnabled,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          Value<String?> deviceId = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        passwordHash: passwordHash ?? this.passwordHash,
        fullName: fullName ?? this.fullName,
        role: role ?? this.role,
        avatarInitial: avatarInitial ?? this.avatarInitial,
        isActive: isActive ?? this.isActive,
        phone: phone.present ? phone.value : this.phone,
        otpEnabled: otpEnabled ?? this.otpEnabled,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      role: data.role.present ? data.role.value : this.role,
      avatarInitial: data.avatarInitial.present
          ? data.avatarInitial.value
          : this.avatarInitial,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      phone: data.phone.present ? data.phone.value : this.phone,
      otpEnabled:
          data.otpEnabled.present ? data.otpEnabled.value : this.otpEnabled,
      biometricEnabled: data.biometricEnabled.present
          ? data.biometricEnabled.value
          : this.biometricEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('avatarInitial: $avatarInitial, ')
          ..write('isActive: $isActive, ')
          ..write('phone: $phone, ')
          ..write('otpEnabled: $otpEnabled, ')
          ..write('biometricEnabled: $biometricEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      username,
      passwordHash,
      fullName,
      role,
      avatarInitial,
      isActive,
      phone,
      otpEnabled,
      biometricEnabled,
      createdAt,
      updatedAt,
      deleted,
      deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.passwordHash == this.passwordHash &&
          other.fullName == this.fullName &&
          other.role == this.role &&
          other.avatarInitial == this.avatarInitial &&
          other.isActive == this.isActive &&
          other.phone == this.phone &&
          other.otpEnabled == this.otpEnabled &&
          other.biometricEnabled == this.biometricEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.deviceId == this.deviceId);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> username;
  final Value<String> passwordHash;
  final Value<String> fullName;
  final Value<String> role;
  final Value<String> avatarInitial;
  final Value<bool> isActive;
  final Value<String?> phone;
  final Value<bool> otpEnabled;
  final Value<bool> biometricEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.fullName = const Value.absent(),
    this.role = const Value.absent(),
    this.avatarInitial = const Value.absent(),
    this.isActive = const Value.absent(),
    this.phone = const Value.absent(),
    this.otpEnabled = const Value.absent(),
    this.biometricEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String username,
    required String passwordHash,
    required String fullName,
    this.role = const Value.absent(),
    this.avatarInitial = const Value.absent(),
    this.isActive = const Value.absent(),
    this.phone = const Value.absent(),
    this.otpEnabled = const Value.absent(),
    this.biometricEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        username = Value(username),
        passwordHash = Value(passwordHash),
        fullName = Value(fullName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? passwordHash,
    Expression<String>? fullName,
    Expression<String>? role,
    Expression<String>? avatarInitial,
    Expression<bool>? isActive,
    Expression<String>? phone,
    Expression<bool>? otpEnabled,
    Expression<bool>? biometricEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (fullName != null) 'full_name': fullName,
      if (role != null) 'role': role,
      if (avatarInitial != null) 'avatar_initial': avatarInitial,
      if (isActive != null) 'is_active': isActive,
      if (phone != null) 'phone': phone,
      if (otpEnabled != null) 'otp_enabled': otpEnabled,
      if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? username,
      Value<String>? passwordHash,
      Value<String>? fullName,
      Value<String>? role,
      Value<String>? avatarInitial,
      Value<bool>? isActive,
      Value<String?>? phone,
      Value<bool>? otpEnabled,
      Value<bool>? biometricEnabled,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      avatarInitial: avatarInitial ?? this.avatarInitial,
      isActive: isActive ?? this.isActive,
      phone: phone ?? this.phone,
      otpEnabled: otpEnabled ?? this.otpEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (avatarInitial.present) {
      map['avatar_initial'] = Variable<String>(avatarInitial.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (otpEnabled.present) {
      map['otp_enabled'] = Variable<bool>(otpEnabled.value);
    }
    if (biometricEnabled.present) {
      map['biometric_enabled'] = Variable<bool>(biometricEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('avatarInitial: $avatarInitial, ')
          ..write('isActive: $isActive, ')
          ..write('phone: $phone, ')
          ..write('otpEnabled: $otpEnabled, ')
          ..write('biometricEnabled: $biometricEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nationalIdMeta =
      const VerificationMeta('nationalId');
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
      'national_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nationalIdSearchMeta =
      const VerificationMeta('nationalIdSearch');
  @override
  late final GeneratedColumn<String> nationalIdSearch = GeneratedColumn<String>(
      'national_id_search', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _joinDateMeta =
      const VerificationMeta('joinDate');
  @override
  late final GeneratedColumn<String> joinDate = GeneratedColumn<String>(
      'join_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('نشط'));
  static const VerificationMeta _monthlySubscriptionMeta =
      const VerificationMeta('monthlySubscription');
  @override
  late final GeneratedColumn<int> monthlySubscription = GeneratedColumn<int>(
      'monthly_subscription', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalPaidMeta =
      const VerificationMeta('totalPaid');
  @override
  late final GeneratedColumn<int> totalPaid = GeneratedColumn<int>(
      'total_paid', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _balanceDueMeta =
      const VerificationMeta('balanceDue');
  @override
  late final GeneratedColumn<int> balanceDue = GeneratedColumn<int>(
      'balance_due', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        nationalId,
        nationalIdSearch,
        phone,
        email,
        city,
        joinDate,
        status,
        monthlySubscription,
        totalPaid,
        balanceDue,
        createdAt,
        updatedAt,
        deleted,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(Insertable<Member> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('national_id')) {
      context.handle(
          _nationalIdMeta,
          nationalId.isAcceptableOrUnknown(
              data['national_id']!, _nationalIdMeta));
    } else if (isInserting) {
      context.missing(_nationalIdMeta);
    }
    if (data.containsKey('national_id_search')) {
      context.handle(
          _nationalIdSearchMeta,
          nationalIdSearch.isAcceptableOrUnknown(
              data['national_id_search']!, _nationalIdSearchMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('join_date')) {
      context.handle(_joinDateMeta,
          joinDate.isAcceptableOrUnknown(data['join_date']!, _joinDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('monthly_subscription')) {
      context.handle(
          _monthlySubscriptionMeta,
          monthlySubscription.isAcceptableOrUnknown(
              data['monthly_subscription']!, _monthlySubscriptionMeta));
    }
    if (data.containsKey('total_paid')) {
      context.handle(_totalPaidMeta,
          totalPaid.isAcceptableOrUnknown(data['total_paid']!, _totalPaidMeta));
    }
    if (data.containsKey('balance_due')) {
      context.handle(
          _balanceDueMeta,
          balanceDue.isAcceptableOrUnknown(
              data['balance_due']!, _balanceDueMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nationalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}national_id'])!,
      nationalIdSearch: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}national_id_search']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      joinDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}join_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      monthlySubscription: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}monthly_subscription'])!,
      totalPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_paid'])!,
      balanceDue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}balance_due'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final String id;
  final String name;
  final String nationalId;
  final String? nationalIdSearch;
  final String phone;
  final String? email;
  final String? city;
  final String? joinDate;
  final String status;
  final int monthlySubscription;
  final int totalPaid;
  final int balanceDue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String? deviceId;
  const Member(
      {required this.id,
      required this.name,
      required this.nationalId,
      this.nationalIdSearch,
      required this.phone,
      this.email,
      this.city,
      this.joinDate,
      required this.status,
      required this.monthlySubscription,
      required this.totalPaid,
      required this.balanceDue,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['national_id'] = Variable<String>(nationalId);
    if (!nullToAbsent || nationalIdSearch != null) {
      map['national_id_search'] = Variable<String>(nationalIdSearch);
    }
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || joinDate != null) {
      map['join_date'] = Variable<String>(joinDate);
    }
    map['status'] = Variable<String>(status);
    map['monthly_subscription'] = Variable<int>(monthlySubscription);
    map['total_paid'] = Variable<int>(totalPaid);
    map['balance_due'] = Variable<int>(balanceDue);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      name: Value(name),
      nationalId: Value(nationalId),
      nationalIdSearch: nationalIdSearch == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalIdSearch),
      phone: Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      joinDate: joinDate == null && nullToAbsent
          ? const Value.absent()
          : Value(joinDate),
      status: Value(status),
      monthlySubscription: Value(monthlySubscription),
      totalPaid: Value(totalPaid),
      balanceDue: Value(balanceDue),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory Member.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nationalId: serializer.fromJson<String>(json['nationalId']),
      nationalIdSearch: serializer.fromJson<String?>(json['nationalIdSearch']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      city: serializer.fromJson<String?>(json['city']),
      joinDate: serializer.fromJson<String?>(json['joinDate']),
      status: serializer.fromJson<String>(json['status']),
      monthlySubscription:
          serializer.fromJson<int>(json['monthlySubscription']),
      totalPaid: serializer.fromJson<int>(json['totalPaid']),
      balanceDue: serializer.fromJson<int>(json['balanceDue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nationalId': serializer.toJson<String>(nationalId),
      'nationalIdSearch': serializer.toJson<String?>(nationalIdSearch),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String?>(email),
      'city': serializer.toJson<String?>(city),
      'joinDate': serializer.toJson<String?>(joinDate),
      'status': serializer.toJson<String>(status),
      'monthlySubscription': serializer.toJson<int>(monthlySubscription),
      'totalPaid': serializer.toJson<int>(totalPaid),
      'balanceDue': serializer.toJson<int>(balanceDue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  Member copyWith(
          {String? id,
          String? name,
          String? nationalId,
          Value<String?> nationalIdSearch = const Value.absent(),
          String? phone,
          Value<String?> email = const Value.absent(),
          Value<String?> city = const Value.absent(),
          Value<String?> joinDate = const Value.absent(),
          String? status,
          int? monthlySubscription,
          int? totalPaid,
          int? balanceDue,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          Value<String?> deviceId = const Value.absent()}) =>
      Member(
        id: id ?? this.id,
        name: name ?? this.name,
        nationalId: nationalId ?? this.nationalId,
        nationalIdSearch: nationalIdSearch.present
            ? nationalIdSearch.value
            : this.nationalIdSearch,
        phone: phone ?? this.phone,
        email: email.present ? email.value : this.email,
        city: city.present ? city.value : this.city,
        joinDate: joinDate.present ? joinDate.value : this.joinDate,
        status: status ?? this.status,
        monthlySubscription: monthlySubscription ?? this.monthlySubscription,
        totalPaid: totalPaid ?? this.totalPaid,
        balanceDue: balanceDue ?? this.balanceDue,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nationalId:
          data.nationalId.present ? data.nationalId.value : this.nationalId,
      nationalIdSearch: data.nationalIdSearch.present
          ? data.nationalIdSearch.value
          : this.nationalIdSearch,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      city: data.city.present ? data.city.value : this.city,
      joinDate: data.joinDate.present ? data.joinDate.value : this.joinDate,
      status: data.status.present ? data.status.value : this.status,
      monthlySubscription: data.monthlySubscription.present
          ? data.monthlySubscription.value
          : this.monthlySubscription,
      totalPaid: data.totalPaid.present ? data.totalPaid.value : this.totalPaid,
      balanceDue:
          data.balanceDue.present ? data.balanceDue.value : this.balanceDue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nationalId: $nationalId, ')
          ..write('nationalIdSearch: $nationalIdSearch, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('city: $city, ')
          ..write('joinDate: $joinDate, ')
          ..write('status: $status, ')
          ..write('monthlySubscription: $monthlySubscription, ')
          ..write('totalPaid: $totalPaid, ')
          ..write('balanceDue: $balanceDue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      nationalId,
      nationalIdSearch,
      phone,
      email,
      city,
      joinDate,
      status,
      monthlySubscription,
      totalPaid,
      balanceDue,
      createdAt,
      updatedAt,
      deleted,
      deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.name == this.name &&
          other.nationalId == this.nationalId &&
          other.nationalIdSearch == this.nationalIdSearch &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.city == this.city &&
          other.joinDate == this.joinDate &&
          other.status == this.status &&
          other.monthlySubscription == this.monthlySubscription &&
          other.totalPaid == this.totalPaid &&
          other.balanceDue == this.balanceDue &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.deviceId == this.deviceId);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> nationalId;
  final Value<String?> nationalIdSearch;
  final Value<String> phone;
  final Value<String?> email;
  final Value<String?> city;
  final Value<String?> joinDate;
  final Value<String> status;
  final Value<int> monthlySubscription;
  final Value<int> totalPaid;
  final Value<int> balanceDue;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.nationalIdSearch = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.city = const Value.absent(),
    this.joinDate = const Value.absent(),
    this.status = const Value.absent(),
    this.monthlySubscription = const Value.absent(),
    this.totalPaid = const Value.absent(),
    this.balanceDue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String name,
    required String nationalId,
    this.nationalIdSearch = const Value.absent(),
    required String phone,
    this.email = const Value.absent(),
    this.city = const Value.absent(),
    this.joinDate = const Value.absent(),
    this.status = const Value.absent(),
    this.monthlySubscription = const Value.absent(),
    this.totalPaid = const Value.absent(),
    this.balanceDue = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        nationalId = Value(nationalId),
        phone = Value(phone),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Member> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nationalId,
    Expression<String>? nationalIdSearch,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? city,
    Expression<String>? joinDate,
    Expression<String>? status,
    Expression<int>? monthlySubscription,
    Expression<int>? totalPaid,
    Expression<int>? balanceDue,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nationalId != null) 'national_id': nationalId,
      if (nationalIdSearch != null) 'national_id_search': nationalIdSearch,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (city != null) 'city': city,
      if (joinDate != null) 'join_date': joinDate,
      if (status != null) 'status': status,
      if (monthlySubscription != null)
        'monthly_subscription': monthlySubscription,
      if (totalPaid != null) 'total_paid': totalPaid,
      if (balanceDue != null) 'balance_due': balanceDue,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? nationalId,
      Value<String?>? nationalIdSearch,
      Value<String>? phone,
      Value<String?>? email,
      Value<String?>? city,
      Value<String?>? joinDate,
      Value<String>? status,
      Value<int>? monthlySubscription,
      Value<int>? totalPaid,
      Value<int>? balanceDue,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return MembersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nationalId: nationalId ?? this.nationalId,
      nationalIdSearch: nationalIdSearch ?? this.nationalIdSearch,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      city: city ?? this.city,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      monthlySubscription: monthlySubscription ?? this.monthlySubscription,
      totalPaid: totalPaid ?? this.totalPaid,
      balanceDue: balanceDue ?? this.balanceDue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (nationalIdSearch.present) {
      map['national_id_search'] = Variable<String>(nationalIdSearch.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (joinDate.present) {
      map['join_date'] = Variable<String>(joinDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (monthlySubscription.present) {
      map['monthly_subscription'] = Variable<int>(monthlySubscription.value);
    }
    if (totalPaid.present) {
      map['total_paid'] = Variable<int>(totalPaid.value);
    }
    if (balanceDue.present) {
      map['balance_due'] = Variable<int>(balanceDue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nationalId: $nationalId, ')
          ..write('nationalIdSearch: $nationalIdSearch, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('city: $city, ')
          ..write('joinDate: $joinDate, ')
          ..write('status: $status, ')
          ..write('monthlySubscription: $monthlySubscription, ')
          ..write('totalPaid: $totalPaid, ')
          ..write('balanceDue: $balanceDue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AidRequestsTable extends AidRequests
    with TableInfo<$AidRequestsTable, AidRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AidRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memberNameMeta =
      const VerificationMeta('memberName');
  @override
  late final GeneratedColumn<String> memberName = GeneratedColumn<String>(
      'member_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aidTypeMeta =
      const VerificationMeta('aidType');
  @override
  late final GeneratedColumn<String> aidType = GeneratedColumn<String>(
      'aid_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalAmountMeta =
      const VerificationMeta('originalAmount');
  @override
  late final GeneratedColumn<double> originalAmount = GeneratedColumn<double>(
      'original_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchange_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _requestDateMeta =
      const VerificationMeta('requestDate');
  @override
  late final GeneratedColumn<String> requestDate = GeneratedColumn<String>(
      'request_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('قيد المراجعة'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reviewerNameMeta =
      const VerificationMeta('reviewerName');
  @override
  late final GeneratedColumn<String> reviewerName = GeneratedColumn<String>(
      'reviewer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reviewerIdMeta =
      const VerificationMeta('reviewerId');
  @override
  late final GeneratedColumn<String> reviewerId = GeneratedColumn<String>(
      'reviewer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
      'beneficiary_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        memberId,
        memberName,
        aidType,
        amount,
        currencyCode,
        originalAmount,
        exchangeRate,
        requestDate,
        status,
        note,
        reviewerName,
        reviewerId,
        createdBy,
        beneficiaryId,
        createdAt,
        updatedAt,
        deleted,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aid_requests';
  @override
  VerificationContext validateIntegrity(Insertable<AidRequest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('member_name')) {
      context.handle(
          _memberNameMeta,
          memberName.isAcceptableOrUnknown(
              data['member_name']!, _memberNameMeta));
    } else if (isInserting) {
      context.missing(_memberNameMeta);
    }
    if (data.containsKey('aid_type')) {
      context.handle(_aidTypeMeta,
          aidType.isAcceptableOrUnknown(data['aid_type']!, _aidTypeMeta));
    } else if (isInserting) {
      context.missing(_aidTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('original_amount')) {
      context.handle(
          _originalAmountMeta,
          originalAmount.isAcceptableOrUnknown(
              data['original_amount']!, _originalAmountMeta));
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchange_rate']!, _exchangeRateMeta));
    }
    if (data.containsKey('request_date')) {
      context.handle(
          _requestDateMeta,
          requestDate.isAcceptableOrUnknown(
              data['request_date']!, _requestDateMeta));
    } else if (isInserting) {
      context.missing(_requestDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('reviewer_name')) {
      context.handle(
          _reviewerNameMeta,
          reviewerName.isAcceptableOrUnknown(
              data['reviewer_name']!, _reviewerNameMeta));
    }
    if (data.containsKey('reviewer_id')) {
      context.handle(
          _reviewerIdMeta,
          reviewerId.isAcceptableOrUnknown(
              data['reviewer_id']!, _reviewerIdMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AidRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AidRequest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      memberName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_name'])!,
      aidType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aid_type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code']),
      originalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}original_amount']),
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchange_rate']),
      requestDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}request_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      reviewerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reviewer_name']),
      reviewerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reviewer_id']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}beneficiary_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $AidRequestsTable createAlias(String alias) {
    return $AidRequestsTable(attachedDatabase, alias);
  }
}

class AidRequest extends DataClass implements Insertable<AidRequest> {
  final String id;
  final String memberId;
  final String memberName;
  final String aidType;
  final int amount;
  final String? currencyCode;
  final double? originalAmount;
  final double? exchangeRate;
  final String requestDate;
  final String status;
  final String? note;
  final String? reviewerName;
  final String? reviewerId;
  final String? createdBy;
  final String? beneficiaryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String? deviceId;
  const AidRequest(
      {required this.id,
      required this.memberId,
      required this.memberName,
      required this.aidType,
      required this.amount,
      this.currencyCode,
      this.originalAmount,
      this.exchangeRate,
      required this.requestDate,
      required this.status,
      this.note,
      this.reviewerName,
      this.reviewerId,
      this.createdBy,
      this.beneficiaryId,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['member_id'] = Variable<String>(memberId);
    map['member_name'] = Variable<String>(memberName);
    map['aid_type'] = Variable<String>(aidType);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || currencyCode != null) {
      map['currency_code'] = Variable<String>(currencyCode);
    }
    if (!nullToAbsent || originalAmount != null) {
      map['original_amount'] = Variable<double>(originalAmount);
    }
    if (!nullToAbsent || exchangeRate != null) {
      map['exchange_rate'] = Variable<double>(exchangeRate);
    }
    map['request_date'] = Variable<String>(requestDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || reviewerName != null) {
      map['reviewer_name'] = Variable<String>(reviewerName);
    }
    if (!nullToAbsent || reviewerId != null) {
      map['reviewer_id'] = Variable<String>(reviewerId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || beneficiaryId != null) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  AidRequestsCompanion toCompanion(bool nullToAbsent) {
    return AidRequestsCompanion(
      id: Value(id),
      memberId: Value(memberId),
      memberName: Value(memberName),
      aidType: Value(aidType),
      amount: Value(amount),
      currencyCode: currencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyCode),
      originalAmount: originalAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmount),
      exchangeRate: exchangeRate == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRate),
      requestDate: Value(requestDate),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      reviewerName: reviewerName == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewerName),
      reviewerId: reviewerId == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewerId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      beneficiaryId: beneficiaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(beneficiaryId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory AidRequest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AidRequest(
      id: serializer.fromJson<String>(json['id']),
      memberId: serializer.fromJson<String>(json['memberId']),
      memberName: serializer.fromJson<String>(json['memberName']),
      aidType: serializer.fromJson<String>(json['aidType']),
      amount: serializer.fromJson<int>(json['amount']),
      currencyCode: serializer.fromJson<String?>(json['currencyCode']),
      originalAmount: serializer.fromJson<double?>(json['originalAmount']),
      exchangeRate: serializer.fromJson<double?>(json['exchangeRate']),
      requestDate: serializer.fromJson<String>(json['requestDate']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      reviewerName: serializer.fromJson<String?>(json['reviewerName']),
      reviewerId: serializer.fromJson<String?>(json['reviewerId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      beneficiaryId: serializer.fromJson<String?>(json['beneficiaryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memberId': serializer.toJson<String>(memberId),
      'memberName': serializer.toJson<String>(memberName),
      'aidType': serializer.toJson<String>(aidType),
      'amount': serializer.toJson<int>(amount),
      'currencyCode': serializer.toJson<String?>(currencyCode),
      'originalAmount': serializer.toJson<double?>(originalAmount),
      'exchangeRate': serializer.toJson<double?>(exchangeRate),
      'requestDate': serializer.toJson<String>(requestDate),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'reviewerName': serializer.toJson<String?>(reviewerName),
      'reviewerId': serializer.toJson<String?>(reviewerId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'beneficiaryId': serializer.toJson<String?>(beneficiaryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  AidRequest copyWith(
          {String? id,
          String? memberId,
          String? memberName,
          String? aidType,
          int? amount,
          Value<String?> currencyCode = const Value.absent(),
          Value<double?> originalAmount = const Value.absent(),
          Value<double?> exchangeRate = const Value.absent(),
          String? requestDate,
          String? status,
          Value<String?> note = const Value.absent(),
          Value<String?> reviewerName = const Value.absent(),
          Value<String?> reviewerId = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> beneficiaryId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          Value<String?> deviceId = const Value.absent()}) =>
      AidRequest(
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        memberName: memberName ?? this.memberName,
        aidType: aidType ?? this.aidType,
        amount: amount ?? this.amount,
        currencyCode:
            currencyCode.present ? currencyCode.value : this.currencyCode,
        originalAmount:
            originalAmount.present ? originalAmount.value : this.originalAmount,
        exchangeRate:
            exchangeRate.present ? exchangeRate.value : this.exchangeRate,
        requestDate: requestDate ?? this.requestDate,
        status: status ?? this.status,
        note: note.present ? note.value : this.note,
        reviewerName:
            reviewerName.present ? reviewerName.value : this.reviewerName,
        reviewerId: reviewerId.present ? reviewerId.value : this.reviewerId,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        beneficiaryId:
            beneficiaryId.present ? beneficiaryId.value : this.beneficiaryId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  AidRequest copyWithCompanion(AidRequestsCompanion data) {
    return AidRequest(
      id: data.id.present ? data.id.value : this.id,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      memberName:
          data.memberName.present ? data.memberName.value : this.memberName,
      aidType: data.aidType.present ? data.aidType.value : this.aidType,
      amount: data.amount.present ? data.amount.value : this.amount,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      originalAmount: data.originalAmount.present
          ? data.originalAmount.value
          : this.originalAmount,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      requestDate:
          data.requestDate.present ? data.requestDate.value : this.requestDate,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      reviewerName: data.reviewerName.present
          ? data.reviewerName.value
          : this.reviewerName,
      reviewerId:
          data.reviewerId.present ? data.reviewerId.value : this.reviewerId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AidRequest(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('memberName: $memberName, ')
          ..write('aidType: $aidType, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('requestDate: $requestDate, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('reviewerName: $reviewerName, ')
          ..write('reviewerId: $reviewerId, ')
          ..write('createdBy: $createdBy, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      memberId,
      memberName,
      aidType,
      amount,
      currencyCode,
      originalAmount,
      exchangeRate,
      requestDate,
      status,
      note,
      reviewerName,
      reviewerId,
      createdBy,
      beneficiaryId,
      createdAt,
      updatedAt,
      deleted,
      deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AidRequest &&
          other.id == this.id &&
          other.memberId == this.memberId &&
          other.memberName == this.memberName &&
          other.aidType == this.aidType &&
          other.amount == this.amount &&
          other.currencyCode == this.currencyCode &&
          other.originalAmount == this.originalAmount &&
          other.exchangeRate == this.exchangeRate &&
          other.requestDate == this.requestDate &&
          other.status == this.status &&
          other.note == this.note &&
          other.reviewerName == this.reviewerName &&
          other.reviewerId == this.reviewerId &&
          other.createdBy == this.createdBy &&
          other.beneficiaryId == this.beneficiaryId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.deviceId == this.deviceId);
}

class AidRequestsCompanion extends UpdateCompanion<AidRequest> {
  final Value<String> id;
  final Value<String> memberId;
  final Value<String> memberName;
  final Value<String> aidType;
  final Value<int> amount;
  final Value<String?> currencyCode;
  final Value<double?> originalAmount;
  final Value<double?> exchangeRate;
  final Value<String> requestDate;
  final Value<String> status;
  final Value<String?> note;
  final Value<String?> reviewerName;
  final Value<String?> reviewerId;
  final Value<String?> createdBy;
  final Value<String?> beneficiaryId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const AidRequestsCompanion({
    this.id = const Value.absent(),
    this.memberId = const Value.absent(),
    this.memberName = const Value.absent(),
    this.aidType = const Value.absent(),
    this.amount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.requestDate = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.reviewerName = const Value.absent(),
    this.reviewerId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AidRequestsCompanion.insert({
    required String id,
    required String memberId,
    required String memberName,
    required String aidType,
    required int amount,
    this.currencyCode = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    required String requestDate,
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.reviewerName = const Value.absent(),
    this.reviewerId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        memberId = Value(memberId),
        memberName = Value(memberName),
        aidType = Value(aidType),
        amount = Value(amount),
        requestDate = Value(requestDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AidRequest> custom({
    Expression<String>? id,
    Expression<String>? memberId,
    Expression<String>? memberName,
    Expression<String>? aidType,
    Expression<int>? amount,
    Expression<String>? currencyCode,
    Expression<double>? originalAmount,
    Expression<double>? exchangeRate,
    Expression<String>? requestDate,
    Expression<String>? status,
    Expression<String>? note,
    Expression<String>? reviewerName,
    Expression<String>? reviewerId,
    Expression<String>? createdBy,
    Expression<String>? beneficiaryId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memberId != null) 'member_id': memberId,
      if (memberName != null) 'member_name': memberName,
      if (aidType != null) 'aid_type': aidType,
      if (amount != null) 'amount': amount,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (originalAmount != null) 'original_amount': originalAmount,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (requestDate != null) 'request_date': requestDate,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (reviewerName != null) 'reviewer_name': reviewerName,
      if (reviewerId != null) 'reviewer_id': reviewerId,
      if (createdBy != null) 'created_by': createdBy,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AidRequestsCompanion copyWith(
      {Value<String>? id,
      Value<String>? memberId,
      Value<String>? memberName,
      Value<String>? aidType,
      Value<int>? amount,
      Value<String?>? currencyCode,
      Value<double?>? originalAmount,
      Value<double?>? exchangeRate,
      Value<String>? requestDate,
      Value<String>? status,
      Value<String?>? note,
      Value<String?>? reviewerName,
      Value<String?>? reviewerId,
      Value<String?>? createdBy,
      Value<String?>? beneficiaryId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return AidRequestsCompanion(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      aidType: aidType ?? this.aidType,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      originalAmount: originalAmount ?? this.originalAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      note: note ?? this.note,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerId: reviewerId ?? this.reviewerId,
      createdBy: createdBy ?? this.createdBy,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (memberName.present) {
      map['member_name'] = Variable<String>(memberName.value);
    }
    if (aidType.present) {
      map['aid_type'] = Variable<String>(aidType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (originalAmount.present) {
      map['original_amount'] = Variable<double>(originalAmount.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (requestDate.present) {
      map['request_date'] = Variable<String>(requestDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (reviewerName.present) {
      map['reviewer_name'] = Variable<String>(reviewerName.value);
    }
    if (reviewerId.present) {
      map['reviewer_id'] = Variable<String>(reviewerId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AidRequestsCompanion(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('memberName: $memberName, ')
          ..write('aidType: $aidType, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('requestDate: $requestDate, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('reviewerName: $reviewerName, ')
          ..write('reviewerId: $reviewerId, ')
          ..write('createdBy: $createdBy, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, Subscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memberNameMeta =
      const VerificationMeta('memberName');
  @override
  late final GeneratedColumn<String> memberName = GeneratedColumn<String>(
      'member_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalAmountMeta =
      const VerificationMeta('originalAmount');
  @override
  late final GeneratedColumn<double> originalAmount = GeneratedColumn<double>(
      'original_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchange_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<String> paymentDate = GeneratedColumn<String>(
      'payment_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceNoMeta =
      const VerificationMeta('referenceNo');
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
      'reference_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        memberId,
        memberName,
        amount,
        currencyCode,
        originalAmount,
        exchangeRate,
        paymentDate,
        period,
        method,
        referenceNo,
        createdAt,
        updatedAt,
        deleted,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(Insertable<Subscription> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('member_name')) {
      context.handle(
          _memberNameMeta,
          memberName.isAcceptableOrUnknown(
              data['member_name']!, _memberNameMeta));
    } else if (isInserting) {
      context.missing(_memberNameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('original_amount')) {
      context.handle(
          _originalAmountMeta,
          originalAmount.isAcceptableOrUnknown(
              data['original_amount']!, _originalAmountMeta));
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchange_rate']!, _exchangeRateMeta));
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('reference_no')) {
      context.handle(
          _referenceNoMeta,
          referenceNo.isAcceptableOrUnknown(
              data['reference_no']!, _referenceNoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscription(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      memberName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code']),
      originalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}original_amount']),
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchange_rate']),
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_date'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period']),
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      referenceNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_no']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }
}

class Subscription extends DataClass implements Insertable<Subscription> {
  final String id;
  final String memberId;
  final String memberName;
  final int amount;
  final String? currencyCode;
  final double? originalAmount;
  final double? exchangeRate;
  final String paymentDate;
  final String? period;
  final String method;
  final String? referenceNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String? deviceId;
  const Subscription(
      {required this.id,
      required this.memberId,
      required this.memberName,
      required this.amount,
      this.currencyCode,
      this.originalAmount,
      this.exchangeRate,
      required this.paymentDate,
      this.period,
      required this.method,
      this.referenceNo,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['member_id'] = Variable<String>(memberId);
    map['member_name'] = Variable<String>(memberName);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || currencyCode != null) {
      map['currency_code'] = Variable<String>(currencyCode);
    }
    if (!nullToAbsent || originalAmount != null) {
      map['original_amount'] = Variable<double>(originalAmount);
    }
    if (!nullToAbsent || exchangeRate != null) {
      map['exchange_rate'] = Variable<double>(exchangeRate);
    }
    map['payment_date'] = Variable<String>(paymentDate);
    if (!nullToAbsent || period != null) {
      map['period'] = Variable<String>(period);
    }
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      memberId: Value(memberId),
      memberName: Value(memberName),
      amount: Value(amount),
      currencyCode: currencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyCode),
      originalAmount: originalAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmount),
      exchangeRate: exchangeRate == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRate),
      paymentDate: Value(paymentDate),
      period:
          period == null && nullToAbsent ? const Value.absent() : Value(period),
      method: Value(method),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscription(
      id: serializer.fromJson<String>(json['id']),
      memberId: serializer.fromJson<String>(json['memberId']),
      memberName: serializer.fromJson<String>(json['memberName']),
      amount: serializer.fromJson<int>(json['amount']),
      currencyCode: serializer.fromJson<String?>(json['currencyCode']),
      originalAmount: serializer.fromJson<double?>(json['originalAmount']),
      exchangeRate: serializer.fromJson<double?>(json['exchangeRate']),
      paymentDate: serializer.fromJson<String>(json['paymentDate']),
      period: serializer.fromJson<String?>(json['period']),
      method: serializer.fromJson<String>(json['method']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memberId': serializer.toJson<String>(memberId),
      'memberName': serializer.toJson<String>(memberName),
      'amount': serializer.toJson<int>(amount),
      'currencyCode': serializer.toJson<String?>(currencyCode),
      'originalAmount': serializer.toJson<double?>(originalAmount),
      'exchangeRate': serializer.toJson<double?>(exchangeRate),
      'paymentDate': serializer.toJson<String>(paymentDate),
      'period': serializer.toJson<String?>(period),
      'method': serializer.toJson<String>(method),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  Subscription copyWith(
          {String? id,
          String? memberId,
          String? memberName,
          int? amount,
          Value<String?> currencyCode = const Value.absent(),
          Value<double?> originalAmount = const Value.absent(),
          Value<double?> exchangeRate = const Value.absent(),
          String? paymentDate,
          Value<String?> period = const Value.absent(),
          String? method,
          Value<String?> referenceNo = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          Value<String?> deviceId = const Value.absent()}) =>
      Subscription(
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        memberName: memberName ?? this.memberName,
        amount: amount ?? this.amount,
        currencyCode:
            currencyCode.present ? currencyCode.value : this.currencyCode,
        originalAmount:
            originalAmount.present ? originalAmount.value : this.originalAmount,
        exchangeRate:
            exchangeRate.present ? exchangeRate.value : this.exchangeRate,
        paymentDate: paymentDate ?? this.paymentDate,
        period: period.present ? period.value : this.period,
        method: method ?? this.method,
        referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  Subscription copyWithCompanion(SubscriptionsCompanion data) {
    return Subscription(
      id: data.id.present ? data.id.value : this.id,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      memberName:
          data.memberName.present ? data.memberName.value : this.memberName,
      amount: data.amount.present ? data.amount.value : this.amount,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      originalAmount: data.originalAmount.present
          ? data.originalAmount.value
          : this.originalAmount,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      period: data.period.present ? data.period.value : this.period,
      method: data.method.present ? data.method.value : this.method,
      referenceNo:
          data.referenceNo.present ? data.referenceNo.value : this.referenceNo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscription(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('memberName: $memberName, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('period: $period, ')
          ..write('method: $method, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      memberId,
      memberName,
      amount,
      currencyCode,
      originalAmount,
      exchangeRate,
      paymentDate,
      period,
      method,
      referenceNo,
      createdAt,
      updatedAt,
      deleted,
      deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          other.id == this.id &&
          other.memberId == this.memberId &&
          other.memberName == this.memberName &&
          other.amount == this.amount &&
          other.currencyCode == this.currencyCode &&
          other.originalAmount == this.originalAmount &&
          other.exchangeRate == this.exchangeRate &&
          other.paymentDate == this.paymentDate &&
          other.period == this.period &&
          other.method == this.method &&
          other.referenceNo == this.referenceNo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.deviceId == this.deviceId);
}

class SubscriptionsCompanion extends UpdateCompanion<Subscription> {
  final Value<String> id;
  final Value<String> memberId;
  final Value<String> memberName;
  final Value<int> amount;
  final Value<String?> currencyCode;
  final Value<double?> originalAmount;
  final Value<double?> exchangeRate;
  final Value<String> paymentDate;
  final Value<String?> period;
  final Value<String> method;
  final Value<String?> referenceNo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.memberId = const Value.absent(),
    this.memberName = const Value.absent(),
    this.amount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.period = const Value.absent(),
    this.method = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    required String id,
    required String memberId,
    required String memberName,
    required int amount,
    this.currencyCode = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    required String paymentDate,
    this.period = const Value.absent(),
    required String method,
    this.referenceNo = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        memberId = Value(memberId),
        memberName = Value(memberName),
        amount = Value(amount),
        paymentDate = Value(paymentDate),
        method = Value(method),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Subscription> custom({
    Expression<String>? id,
    Expression<String>? memberId,
    Expression<String>? memberName,
    Expression<int>? amount,
    Expression<String>? currencyCode,
    Expression<double>? originalAmount,
    Expression<double>? exchangeRate,
    Expression<String>? paymentDate,
    Expression<String>? period,
    Expression<String>? method,
    Expression<String>? referenceNo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memberId != null) 'member_id': memberId,
      if (memberName != null) 'member_name': memberName,
      if (amount != null) 'amount': amount,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (originalAmount != null) 'original_amount': originalAmount,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (period != null) 'period': period,
      if (method != null) 'method': method,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? memberId,
      Value<String>? memberName,
      Value<int>? amount,
      Value<String?>? currencyCode,
      Value<double?>? originalAmount,
      Value<double?>? exchangeRate,
      Value<String>? paymentDate,
      Value<String?>? period,
      Value<String>? method,
      Value<String?>? referenceNo,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      originalAmount: originalAmount ?? this.originalAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      paymentDate: paymentDate ?? this.paymentDate,
      period: period ?? this.period,
      method: method ?? this.method,
      referenceNo: referenceNo ?? this.referenceNo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (memberName.present) {
      map['member_name'] = Variable<String>(memberName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (originalAmount.present) {
      map['original_amount'] = Variable<double>(originalAmount.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<String>(paymentDate.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('memberName: $memberName, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('period: $period, ')
          ..write('method: $method, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreasuryEntriesTable extends TreasuryEntries
    with TableInfo<$TreasuryEntriesTable, TreasuryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreasuryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalAmountMeta =
      const VerificationMeta('originalAmount');
  @override
  late final GeneratedColumn<double> originalAmount = GeneratedColumn<double>(
      'original_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchange_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _entryDateMeta =
      const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
      'entry_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceNoMeta =
      const VerificationMeta('referenceNo');
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
      'reference_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        category,
        description,
        amount,
        currencyCode,
        originalAmount,
        exchangeRate,
        entryDate,
        referenceNo,
        createdAt,
        updatedAt,
        deleted,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treasury_entries';
  @override
  VerificationContext validateIntegrity(Insertable<TreasuryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('original_amount')) {
      context.handle(
          _originalAmountMeta,
          originalAmount.isAcceptableOrUnknown(
              data['original_amount']!, _originalAmountMeta));
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchange_rate']!, _exchangeRateMeta));
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta,
          entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('reference_no')) {
      context.handle(
          _referenceNoMeta,
          referenceNo.isAcceptableOrUnknown(
              data['reference_no']!, _referenceNoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TreasuryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TreasuryEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code']),
      originalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}original_amount']),
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchange_rate']),
      entryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_date'])!,
      referenceNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_no']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $TreasuryEntriesTable createAlias(String alias) {
    return $TreasuryEntriesTable(attachedDatabase, alias);
  }
}

class TreasuryEntry extends DataClass implements Insertable<TreasuryEntry> {
  final String id;
  final String type;
  final String category;
  final String description;
  final int amount;
  final String? currencyCode;
  final double? originalAmount;
  final double? exchangeRate;
  final String entryDate;
  final String? referenceNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String? deviceId;
  const TreasuryEntry(
      {required this.id,
      required this.type,
      required this.category,
      required this.description,
      required this.amount,
      this.currencyCode,
      this.originalAmount,
      this.exchangeRate,
      required this.entryDate,
      this.referenceNo,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || currencyCode != null) {
      map['currency_code'] = Variable<String>(currencyCode);
    }
    if (!nullToAbsent || originalAmount != null) {
      map['original_amount'] = Variable<double>(originalAmount);
    }
    if (!nullToAbsent || exchangeRate != null) {
      map['exchange_rate'] = Variable<double>(exchangeRate);
    }
    map['entry_date'] = Variable<String>(entryDate);
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  TreasuryEntriesCompanion toCompanion(bool nullToAbsent) {
    return TreasuryEntriesCompanion(
      id: Value(id),
      type: Value(type),
      category: Value(category),
      description: Value(description),
      amount: Value(amount),
      currencyCode: currencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyCode),
      originalAmount: originalAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmount),
      exchangeRate: exchangeRate == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRate),
      entryDate: Value(entryDate),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory TreasuryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TreasuryEntry(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<int>(json['amount']),
      currencyCode: serializer.fromJson<String?>(json['currencyCode']),
      originalAmount: serializer.fromJson<double?>(json['originalAmount']),
      exchangeRate: serializer.fromJson<double?>(json['exchangeRate']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<int>(amount),
      'currencyCode': serializer.toJson<String?>(currencyCode),
      'originalAmount': serializer.toJson<double?>(originalAmount),
      'exchangeRate': serializer.toJson<double?>(exchangeRate),
      'entryDate': serializer.toJson<String>(entryDate),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  TreasuryEntry copyWith(
          {String? id,
          String? type,
          String? category,
          String? description,
          int? amount,
          Value<String?> currencyCode = const Value.absent(),
          Value<double?> originalAmount = const Value.absent(),
          Value<double?> exchangeRate = const Value.absent(),
          String? entryDate,
          Value<String?> referenceNo = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          Value<String?> deviceId = const Value.absent()}) =>
      TreasuryEntry(
        id: id ?? this.id,
        type: type ?? this.type,
        category: category ?? this.category,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        currencyCode:
            currencyCode.present ? currencyCode.value : this.currencyCode,
        originalAmount:
            originalAmount.present ? originalAmount.value : this.originalAmount,
        exchangeRate:
            exchangeRate.present ? exchangeRate.value : this.exchangeRate,
        entryDate: entryDate ?? this.entryDate,
        referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  TreasuryEntry copyWithCompanion(TreasuryEntriesCompanion data) {
    return TreasuryEntry(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      originalAmount: data.originalAmount.present
          ? data.originalAmount.value
          : this.originalAmount,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      referenceNo:
          data.referenceNo.present ? data.referenceNo.value : this.referenceNo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TreasuryEntry(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('entryDate: $entryDate, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      category,
      description,
      amount,
      currencyCode,
      originalAmount,
      exchangeRate,
      entryDate,
      referenceNo,
      createdAt,
      updatedAt,
      deleted,
      deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TreasuryEntry &&
          other.id == this.id &&
          other.type == this.type &&
          other.category == this.category &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.currencyCode == this.currencyCode &&
          other.originalAmount == this.originalAmount &&
          other.exchangeRate == this.exchangeRate &&
          other.entryDate == this.entryDate &&
          other.referenceNo == this.referenceNo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.deviceId == this.deviceId);
}

class TreasuryEntriesCompanion extends UpdateCompanion<TreasuryEntry> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> category;
  final Value<String> description;
  final Value<int> amount;
  final Value<String?> currencyCode;
  final Value<double?> originalAmount;
  final Value<double?> exchangeRate;
  final Value<String> entryDate;
  final Value<String?> referenceNo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const TreasuryEntriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreasuryEntriesCompanion.insert({
    required String id,
    required String type,
    required String category,
    required String description,
    required int amount,
    this.currencyCode = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    required String entryDate,
    this.referenceNo = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        category = Value(category),
        description = Value(description),
        amount = Value(amount),
        entryDate = Value(entryDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TreasuryEntry> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? description,
    Expression<int>? amount,
    Expression<String>? currencyCode,
    Expression<double>? originalAmount,
    Expression<double>? exchangeRate,
    Expression<String>? entryDate,
    Expression<String>? referenceNo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (originalAmount != null) 'original_amount': originalAmount,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (entryDate != null) 'entry_date': entryDate,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreasuryEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? category,
      Value<String>? description,
      Value<int>? amount,
      Value<String?>? currencyCode,
      Value<double?>? originalAmount,
      Value<double?>? exchangeRate,
      Value<String>? entryDate,
      Value<String?>? referenceNo,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return TreasuryEntriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      originalAmount: originalAmount ?? this.originalAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      entryDate: entryDate ?? this.entryDate,
      referenceNo: referenceNo ?? this.referenceNo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (originalAmount.present) {
      map['original_amount'] = Variable<double>(originalAmount.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreasuryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('entryDate: $entryDate, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VouchersTable extends Vouchers with TableInfo<$VouchersTable, Voucher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VouchersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _voucherNoMeta =
      const VerificationMeta('voucherNo');
  @override
  late final GeneratedColumn<String> voucherNo = GeneratedColumn<String>(
      'voucher_no', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _memberNameMeta =
      const VerificationMeta('memberName');
  @override
  late final GeneratedColumn<String> memberName = GeneratedColumn<String>(
      'member_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _donorIdMeta =
      const VerificationMeta('donorId');
  @override
  late final GeneratedColumn<String> donorId = GeneratedColumn<String>(
      'donor_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
      'beneficiary_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partyNameMeta =
      const VerificationMeta('partyName');
  @override
  late final GeneratedColumn<String> partyName = GeneratedColumn<String>(
      'party_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalAmountMeta =
      const VerificationMeta('originalAmount');
  @override
  late final GeneratedColumn<double> originalAmount = GeneratedColumn<double>(
      'original_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchange_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _voucherDateMeta =
      const VerificationMeta('voucherDate');
  @override
  late final GeneratedColumn<String> voucherDate = GeneratedColumn<String>(
      'voucher_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _issuedByNameMeta =
      const VerificationMeta('issuedByName');
  @override
  late final GeneratedColumn<String> issuedByName = GeneratedColumn<String>(
      'issued_by_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _issuedByIdMeta =
      const VerificationMeta('issuedById');
  @override
  late final GeneratedColumn<String> issuedById = GeneratedColumn<String>(
      'issued_by_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('معتمد'));
  static const VerificationMeta _treasuryAccountIdMeta =
      const VerificationMeta('treasuryAccountId');
  @override
  late final GeneratedColumn<String> treasuryAccountId =
      GeneratedColumn<String>('treasury_account_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _counterAccountIdMeta =
      const VerificationMeta('counterAccountId');
  @override
  late final GeneratedColumn<String> counterAccountId = GeneratedColumn<String>(
      'counter_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _journalEntryIdMeta =
      const VerificationMeta('journalEntryId');
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
      'journal_entry_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        voucherNo,
        kind,
        memberId,
        memberName,
        donorId,
        beneficiaryId,
        partyName,
        amount,
        currencyCode,
        originalAmount,
        exchangeRate,
        voucherDate,
        method,
        description,
        issuedByName,
        issuedById,
        status,
        treasuryAccountId,
        counterAccountId,
        journalEntryId,
        createdAt,
        updatedAt,
        deleted,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vouchers';
  @override
  VerificationContext validateIntegrity(Insertable<Voucher> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('voucher_no')) {
      context.handle(_voucherNoMeta,
          voucherNo.isAcceptableOrUnknown(data['voucher_no']!, _voucherNoMeta));
    } else if (isInserting) {
      context.missing(_voucherNoMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    }
    if (data.containsKey('member_name')) {
      context.handle(
          _memberNameMeta,
          memberName.isAcceptableOrUnknown(
              data['member_name']!, _memberNameMeta));
    }
    if (data.containsKey('donor_id')) {
      context.handle(_donorIdMeta,
          donorId.isAcceptableOrUnknown(data['donor_id']!, _donorIdMeta));
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    }
    if (data.containsKey('party_name')) {
      context.handle(_partyNameMeta,
          partyName.isAcceptableOrUnknown(data['party_name']!, _partyNameMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('original_amount')) {
      context.handle(
          _originalAmountMeta,
          originalAmount.isAcceptableOrUnknown(
              data['original_amount']!, _originalAmountMeta));
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchange_rate']!, _exchangeRateMeta));
    }
    if (data.containsKey('voucher_date')) {
      context.handle(
          _voucherDateMeta,
          voucherDate.isAcceptableOrUnknown(
              data['voucher_date']!, _voucherDateMeta));
    } else if (isInserting) {
      context.missing(_voucherDateMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('issued_by_name')) {
      context.handle(
          _issuedByNameMeta,
          issuedByName.isAcceptableOrUnknown(
              data['issued_by_name']!, _issuedByNameMeta));
    } else if (isInserting) {
      context.missing(_issuedByNameMeta);
    }
    if (data.containsKey('issued_by_id')) {
      context.handle(
          _issuedByIdMeta,
          issuedById.isAcceptableOrUnknown(
              data['issued_by_id']!, _issuedByIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('treasury_account_id')) {
      context.handle(
          _treasuryAccountIdMeta,
          treasuryAccountId.isAcceptableOrUnknown(
              data['treasury_account_id']!, _treasuryAccountIdMeta));
    }
    if (data.containsKey('counter_account_id')) {
      context.handle(
          _counterAccountIdMeta,
          counterAccountId.isAcceptableOrUnknown(
              data['counter_account_id']!, _counterAccountIdMeta));
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
          _journalEntryIdMeta,
          journalEntryId.isAcceptableOrUnknown(
              data['journal_entry_id']!, _journalEntryIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Voucher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Voucher(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      voucherNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voucher_no'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id']),
      memberName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_name']),
      donorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}donor_id']),
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}beneficiary_id']),
      partyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_name']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code']),
      originalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}original_amount']),
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchange_rate']),
      voucherDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voucher_date'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      issuedByName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}issued_by_name'])!,
      issuedById: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}issued_by_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      treasuryAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}treasury_account_id']),
      counterAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}counter_account_id']),
      journalEntryId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}journal_entry_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $VouchersTable createAlias(String alias) {
    return $VouchersTable(attachedDatabase, alias);
  }
}

class Voucher extends DataClass implements Insertable<Voucher> {
  final String id;
  final String voucherNo;
  final String kind;
  final String? memberId;
  final String? memberName;
  final String? donorId;
  final String? beneficiaryId;
  final String? partyName;
  final int amount;
  final String? currencyCode;
  final double? originalAmount;
  final double? exchangeRate;
  final String voucherDate;
  final String method;
  final String description;
  final String issuedByName;
  final String? issuedById;
  final String status;
  final String? treasuryAccountId;
  final String? counterAccountId;
  final String? journalEntryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String? deviceId;
  const Voucher(
      {required this.id,
      required this.voucherNo,
      required this.kind,
      this.memberId,
      this.memberName,
      this.donorId,
      this.beneficiaryId,
      this.partyName,
      required this.amount,
      this.currencyCode,
      this.originalAmount,
      this.exchangeRate,
      required this.voucherDate,
      required this.method,
      required this.description,
      required this.issuedByName,
      this.issuedById,
      required this.status,
      this.treasuryAccountId,
      this.counterAccountId,
      this.journalEntryId,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['voucher_no'] = Variable<String>(voucherNo);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    if (!nullToAbsent || memberName != null) {
      map['member_name'] = Variable<String>(memberName);
    }
    if (!nullToAbsent || donorId != null) {
      map['donor_id'] = Variable<String>(donorId);
    }
    if (!nullToAbsent || beneficiaryId != null) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId);
    }
    if (!nullToAbsent || partyName != null) {
      map['party_name'] = Variable<String>(partyName);
    }
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || currencyCode != null) {
      map['currency_code'] = Variable<String>(currencyCode);
    }
    if (!nullToAbsent || originalAmount != null) {
      map['original_amount'] = Variable<double>(originalAmount);
    }
    if (!nullToAbsent || exchangeRate != null) {
      map['exchange_rate'] = Variable<double>(exchangeRate);
    }
    map['voucher_date'] = Variable<String>(voucherDate);
    map['method'] = Variable<String>(method);
    map['description'] = Variable<String>(description);
    map['issued_by_name'] = Variable<String>(issuedByName);
    if (!nullToAbsent || issuedById != null) {
      map['issued_by_id'] = Variable<String>(issuedById);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || treasuryAccountId != null) {
      map['treasury_account_id'] = Variable<String>(treasuryAccountId);
    }
    if (!nullToAbsent || counterAccountId != null) {
      map['counter_account_id'] = Variable<String>(counterAccountId);
    }
    if (!nullToAbsent || journalEntryId != null) {
      map['journal_entry_id'] = Variable<String>(journalEntryId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  VouchersCompanion toCompanion(bool nullToAbsent) {
    return VouchersCompanion(
      id: Value(id),
      voucherNo: Value(voucherNo),
      kind: Value(kind),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      memberName: memberName == null && nullToAbsent
          ? const Value.absent()
          : Value(memberName),
      donorId: donorId == null && nullToAbsent
          ? const Value.absent()
          : Value(donorId),
      beneficiaryId: beneficiaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(beneficiaryId),
      partyName: partyName == null && nullToAbsent
          ? const Value.absent()
          : Value(partyName),
      amount: Value(amount),
      currencyCode: currencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyCode),
      originalAmount: originalAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmount),
      exchangeRate: exchangeRate == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRate),
      voucherDate: Value(voucherDate),
      method: Value(method),
      description: Value(description),
      issuedByName: Value(issuedByName),
      issuedById: issuedById == null && nullToAbsent
          ? const Value.absent()
          : Value(issuedById),
      status: Value(status),
      treasuryAccountId: treasuryAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(treasuryAccountId),
      counterAccountId: counterAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(counterAccountId),
      journalEntryId: journalEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(journalEntryId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory Voucher.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Voucher(
      id: serializer.fromJson<String>(json['id']),
      voucherNo: serializer.fromJson<String>(json['voucherNo']),
      kind: serializer.fromJson<String>(json['kind']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      memberName: serializer.fromJson<String?>(json['memberName']),
      donorId: serializer.fromJson<String?>(json['donorId']),
      beneficiaryId: serializer.fromJson<String?>(json['beneficiaryId']),
      partyName: serializer.fromJson<String?>(json['partyName']),
      amount: serializer.fromJson<int>(json['amount']),
      currencyCode: serializer.fromJson<String?>(json['currencyCode']),
      originalAmount: serializer.fromJson<double?>(json['originalAmount']),
      exchangeRate: serializer.fromJson<double?>(json['exchangeRate']),
      voucherDate: serializer.fromJson<String>(json['voucherDate']),
      method: serializer.fromJson<String>(json['method']),
      description: serializer.fromJson<String>(json['description']),
      issuedByName: serializer.fromJson<String>(json['issuedByName']),
      issuedById: serializer.fromJson<String?>(json['issuedById']),
      status: serializer.fromJson<String>(json['status']),
      treasuryAccountId:
          serializer.fromJson<String?>(json['treasuryAccountId']),
      counterAccountId: serializer.fromJson<String?>(json['counterAccountId']),
      journalEntryId: serializer.fromJson<String?>(json['journalEntryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'voucherNo': serializer.toJson<String>(voucherNo),
      'kind': serializer.toJson<String>(kind),
      'memberId': serializer.toJson<String?>(memberId),
      'memberName': serializer.toJson<String?>(memberName),
      'donorId': serializer.toJson<String?>(donorId),
      'beneficiaryId': serializer.toJson<String?>(beneficiaryId),
      'partyName': serializer.toJson<String?>(partyName),
      'amount': serializer.toJson<int>(amount),
      'currencyCode': serializer.toJson<String?>(currencyCode),
      'originalAmount': serializer.toJson<double?>(originalAmount),
      'exchangeRate': serializer.toJson<double?>(exchangeRate),
      'voucherDate': serializer.toJson<String>(voucherDate),
      'method': serializer.toJson<String>(method),
      'description': serializer.toJson<String>(description),
      'issuedByName': serializer.toJson<String>(issuedByName),
      'issuedById': serializer.toJson<String?>(issuedById),
      'status': serializer.toJson<String>(status),
      'treasuryAccountId': serializer.toJson<String?>(treasuryAccountId),
      'counterAccountId': serializer.toJson<String?>(counterAccountId),
      'journalEntryId': serializer.toJson<String?>(journalEntryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  Voucher copyWith(
          {String? id,
          String? voucherNo,
          String? kind,
          Value<String?> memberId = const Value.absent(),
          Value<String?> memberName = const Value.absent(),
          Value<String?> donorId = const Value.absent(),
          Value<String?> beneficiaryId = const Value.absent(),
          Value<String?> partyName = const Value.absent(),
          int? amount,
          Value<String?> currencyCode = const Value.absent(),
          Value<double?> originalAmount = const Value.absent(),
          Value<double?> exchangeRate = const Value.absent(),
          String? voucherDate,
          String? method,
          String? description,
          String? issuedByName,
          Value<String?> issuedById = const Value.absent(),
          String? status,
          Value<String?> treasuryAccountId = const Value.absent(),
          Value<String?> counterAccountId = const Value.absent(),
          Value<String?> journalEntryId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          Value<String?> deviceId = const Value.absent()}) =>
      Voucher(
        id: id ?? this.id,
        voucherNo: voucherNo ?? this.voucherNo,
        kind: kind ?? this.kind,
        memberId: memberId.present ? memberId.value : this.memberId,
        memberName: memberName.present ? memberName.value : this.memberName,
        donorId: donorId.present ? donorId.value : this.donorId,
        beneficiaryId:
            beneficiaryId.present ? beneficiaryId.value : this.beneficiaryId,
        partyName: partyName.present ? partyName.value : this.partyName,
        amount: amount ?? this.amount,
        currencyCode:
            currencyCode.present ? currencyCode.value : this.currencyCode,
        originalAmount:
            originalAmount.present ? originalAmount.value : this.originalAmount,
        exchangeRate:
            exchangeRate.present ? exchangeRate.value : this.exchangeRate,
        voucherDate: voucherDate ?? this.voucherDate,
        method: method ?? this.method,
        description: description ?? this.description,
        issuedByName: issuedByName ?? this.issuedByName,
        issuedById: issuedById.present ? issuedById.value : this.issuedById,
        status: status ?? this.status,
        treasuryAccountId: treasuryAccountId.present
            ? treasuryAccountId.value
            : this.treasuryAccountId,
        counterAccountId: counterAccountId.present
            ? counterAccountId.value
            : this.counterAccountId,
        journalEntryId:
            journalEntryId.present ? journalEntryId.value : this.journalEntryId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  Voucher copyWithCompanion(VouchersCompanion data) {
    return Voucher(
      id: data.id.present ? data.id.value : this.id,
      voucherNo: data.voucherNo.present ? data.voucherNo.value : this.voucherNo,
      kind: data.kind.present ? data.kind.value : this.kind,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      memberName:
          data.memberName.present ? data.memberName.value : this.memberName,
      donorId: data.donorId.present ? data.donorId.value : this.donorId,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      partyName: data.partyName.present ? data.partyName.value : this.partyName,
      amount: data.amount.present ? data.amount.value : this.amount,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      originalAmount: data.originalAmount.present
          ? data.originalAmount.value
          : this.originalAmount,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      voucherDate:
          data.voucherDate.present ? data.voucherDate.value : this.voucherDate,
      method: data.method.present ? data.method.value : this.method,
      description:
          data.description.present ? data.description.value : this.description,
      issuedByName: data.issuedByName.present
          ? data.issuedByName.value
          : this.issuedByName,
      issuedById:
          data.issuedById.present ? data.issuedById.value : this.issuedById,
      status: data.status.present ? data.status.value : this.status,
      treasuryAccountId: data.treasuryAccountId.present
          ? data.treasuryAccountId.value
          : this.treasuryAccountId,
      counterAccountId: data.counterAccountId.present
          ? data.counterAccountId.value
          : this.counterAccountId,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Voucher(')
          ..write('id: $id, ')
          ..write('voucherNo: $voucherNo, ')
          ..write('kind: $kind, ')
          ..write('memberId: $memberId, ')
          ..write('memberName: $memberName, ')
          ..write('donorId: $donorId, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('partyName: $partyName, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('voucherDate: $voucherDate, ')
          ..write('method: $method, ')
          ..write('description: $description, ')
          ..write('issuedByName: $issuedByName, ')
          ..write('issuedById: $issuedById, ')
          ..write('status: $status, ')
          ..write('treasuryAccountId: $treasuryAccountId, ')
          ..write('counterAccountId: $counterAccountId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        voucherNo,
        kind,
        memberId,
        memberName,
        donorId,
        beneficiaryId,
        partyName,
        amount,
        currencyCode,
        originalAmount,
        exchangeRate,
        voucherDate,
        method,
        description,
        issuedByName,
        issuedById,
        status,
        treasuryAccountId,
        counterAccountId,
        journalEntryId,
        createdAt,
        updatedAt,
        deleted,
        deviceId
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Voucher &&
          other.id == this.id &&
          other.voucherNo == this.voucherNo &&
          other.kind == this.kind &&
          other.memberId == this.memberId &&
          other.memberName == this.memberName &&
          other.donorId == this.donorId &&
          other.beneficiaryId == this.beneficiaryId &&
          other.partyName == this.partyName &&
          other.amount == this.amount &&
          other.currencyCode == this.currencyCode &&
          other.originalAmount == this.originalAmount &&
          other.exchangeRate == this.exchangeRate &&
          other.voucherDate == this.voucherDate &&
          other.method == this.method &&
          other.description == this.description &&
          other.issuedByName == this.issuedByName &&
          other.issuedById == this.issuedById &&
          other.status == this.status &&
          other.treasuryAccountId == this.treasuryAccountId &&
          other.counterAccountId == this.counterAccountId &&
          other.journalEntryId == this.journalEntryId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.deviceId == this.deviceId);
}

class VouchersCompanion extends UpdateCompanion<Voucher> {
  final Value<String> id;
  final Value<String> voucherNo;
  final Value<String> kind;
  final Value<String?> memberId;
  final Value<String?> memberName;
  final Value<String?> donorId;
  final Value<String?> beneficiaryId;
  final Value<String?> partyName;
  final Value<int> amount;
  final Value<String?> currencyCode;
  final Value<double?> originalAmount;
  final Value<double?> exchangeRate;
  final Value<String> voucherDate;
  final Value<String> method;
  final Value<String> description;
  final Value<String> issuedByName;
  final Value<String?> issuedById;
  final Value<String> status;
  final Value<String?> treasuryAccountId;
  final Value<String?> counterAccountId;
  final Value<String?> journalEntryId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const VouchersCompanion({
    this.id = const Value.absent(),
    this.voucherNo = const Value.absent(),
    this.kind = const Value.absent(),
    this.memberId = const Value.absent(),
    this.memberName = const Value.absent(),
    this.donorId = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.partyName = const Value.absent(),
    this.amount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.voucherDate = const Value.absent(),
    this.method = const Value.absent(),
    this.description = const Value.absent(),
    this.issuedByName = const Value.absent(),
    this.issuedById = const Value.absent(),
    this.status = const Value.absent(),
    this.treasuryAccountId = const Value.absent(),
    this.counterAccountId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VouchersCompanion.insert({
    required String id,
    required String voucherNo,
    required String kind,
    this.memberId = const Value.absent(),
    this.memberName = const Value.absent(),
    this.donorId = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.partyName = const Value.absent(),
    required int amount,
    this.currencyCode = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    required String voucherDate,
    required String method,
    required String description,
    required String issuedByName,
    this.issuedById = const Value.absent(),
    this.status = const Value.absent(),
    this.treasuryAccountId = const Value.absent(),
    this.counterAccountId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        voucherNo = Value(voucherNo),
        kind = Value(kind),
        amount = Value(amount),
        voucherDate = Value(voucherDate),
        method = Value(method),
        description = Value(description),
        issuedByName = Value(issuedByName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Voucher> custom({
    Expression<String>? id,
    Expression<String>? voucherNo,
    Expression<String>? kind,
    Expression<String>? memberId,
    Expression<String>? memberName,
    Expression<String>? donorId,
    Expression<String>? beneficiaryId,
    Expression<String>? partyName,
    Expression<int>? amount,
    Expression<String>? currencyCode,
    Expression<double>? originalAmount,
    Expression<double>? exchangeRate,
    Expression<String>? voucherDate,
    Expression<String>? method,
    Expression<String>? description,
    Expression<String>? issuedByName,
    Expression<String>? issuedById,
    Expression<String>? status,
    Expression<String>? treasuryAccountId,
    Expression<String>? counterAccountId,
    Expression<String>? journalEntryId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (voucherNo != null) 'voucher_no': voucherNo,
      if (kind != null) 'kind': kind,
      if (memberId != null) 'member_id': memberId,
      if (memberName != null) 'member_name': memberName,
      if (donorId != null) 'donor_id': donorId,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (partyName != null) 'party_name': partyName,
      if (amount != null) 'amount': amount,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (originalAmount != null) 'original_amount': originalAmount,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (voucherDate != null) 'voucher_date': voucherDate,
      if (method != null) 'method': method,
      if (description != null) 'description': description,
      if (issuedByName != null) 'issued_by_name': issuedByName,
      if (issuedById != null) 'issued_by_id': issuedById,
      if (status != null) 'status': status,
      if (treasuryAccountId != null) 'treasury_account_id': treasuryAccountId,
      if (counterAccountId != null) 'counter_account_id': counterAccountId,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VouchersCompanion copyWith(
      {Value<String>? id,
      Value<String>? voucherNo,
      Value<String>? kind,
      Value<String?>? memberId,
      Value<String?>? memberName,
      Value<String?>? donorId,
      Value<String?>? beneficiaryId,
      Value<String?>? partyName,
      Value<int>? amount,
      Value<String?>? currencyCode,
      Value<double?>? originalAmount,
      Value<double?>? exchangeRate,
      Value<String>? voucherDate,
      Value<String>? method,
      Value<String>? description,
      Value<String>? issuedByName,
      Value<String?>? issuedById,
      Value<String>? status,
      Value<String?>? treasuryAccountId,
      Value<String?>? counterAccountId,
      Value<String?>? journalEntryId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return VouchersCompanion(
      id: id ?? this.id,
      voucherNo: voucherNo ?? this.voucherNo,
      kind: kind ?? this.kind,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      donorId: donorId ?? this.donorId,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      partyName: partyName ?? this.partyName,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      originalAmount: originalAmount ?? this.originalAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      voucherDate: voucherDate ?? this.voucherDate,
      method: method ?? this.method,
      description: description ?? this.description,
      issuedByName: issuedByName ?? this.issuedByName,
      issuedById: issuedById ?? this.issuedById,
      status: status ?? this.status,
      treasuryAccountId: treasuryAccountId ?? this.treasuryAccountId,
      counterAccountId: counterAccountId ?? this.counterAccountId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (voucherNo.present) {
      map['voucher_no'] = Variable<String>(voucherNo.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (memberName.present) {
      map['member_name'] = Variable<String>(memberName.value);
    }
    if (donorId.present) {
      map['donor_id'] = Variable<String>(donorId.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId.value);
    }
    if (partyName.present) {
      map['party_name'] = Variable<String>(partyName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (originalAmount.present) {
      map['original_amount'] = Variable<double>(originalAmount.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (voucherDate.present) {
      map['voucher_date'] = Variable<String>(voucherDate.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (issuedByName.present) {
      map['issued_by_name'] = Variable<String>(issuedByName.value);
    }
    if (issuedById.present) {
      map['issued_by_id'] = Variable<String>(issuedById.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (treasuryAccountId.present) {
      map['treasury_account_id'] = Variable<String>(treasuryAccountId.value);
    }
    if (counterAccountId.present) {
      map['counter_account_id'] = Variable<String>(counterAccountId.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VouchersCompanion(')
          ..write('id: $id, ')
          ..write('voucherNo: $voucherNo, ')
          ..write('kind: $kind, ')
          ..write('memberId: $memberId, ')
          ..write('memberName: $memberName, ')
          ..write('donorId: $donorId, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('partyName: $partyName, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('voucherDate: $voucherDate, ')
          ..write('method: $method, ')
          ..write('description: $description, ')
          ..write('issuedByName: $issuedByName, ')
          ..write('issuedById: $issuedById, ')
          ..write('status: $status, ')
          ..write('treasuryAccountId: $treasuryAccountId, ')
          ..write('counterAccountId: $counterAccountId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromUserIdMeta =
      const VerificationMeta('fromUserId');
  @override
  late final GeneratedColumn<String> fromUserId = GeneratedColumn<String>(
      'from_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromNameMeta =
      const VerificationMeta('fromName');
  @override
  late final GeneratedColumn<String> fromName = GeneratedColumn<String>(
      'from_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toUserIdMeta =
      const VerificationMeta('toUserId');
  @override
  late final GeneratedColumn<String> toUserId = GeneratedColumn<String>(
      'to_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toNameMeta = const VerificationMeta('toName');
  @override
  late final GeneratedColumn<String> toName = GeneratedColumn<String>(
      'to_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
      'read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fromUserId,
        fromName,
        toUserId,
        toName,
        body,
        read,
        createdAt,
        updatedAt,
        deleted,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_user_id')) {
      context.handle(
          _fromUserIdMeta,
          fromUserId.isAcceptableOrUnknown(
              data['from_user_id']!, _fromUserIdMeta));
    } else if (isInserting) {
      context.missing(_fromUserIdMeta);
    }
    if (data.containsKey('from_name')) {
      context.handle(_fromNameMeta,
          fromName.isAcceptableOrUnknown(data['from_name']!, _fromNameMeta));
    } else if (isInserting) {
      context.missing(_fromNameMeta);
    }
    if (data.containsKey('to_user_id')) {
      context.handle(_toUserIdMeta,
          toUserId.isAcceptableOrUnknown(data['to_user_id']!, _toUserIdMeta));
    } else if (isInserting) {
      context.missing(_toUserIdMeta);
    }
    if (data.containsKey('to_name')) {
      context.handle(_toNameMeta,
          toName.isAcceptableOrUnknown(data['to_name']!, _toNameMeta));
    } else if (isInserting) {
      context.missing(_toNameMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('read')) {
      context.handle(
          _readMeta, read.isAcceptableOrUnknown(data['read']!, _readMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fromUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_user_id'])!,
      fromName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_name'])!,
      toUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_user_id'])!,
      toName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_name'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      read: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}read'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String fromUserId;
  final String fromName;
  final String toUserId;
  final String toName;
  final String body;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String? deviceId;
  const Message(
      {required this.id,
      required this.fromUserId,
      required this.fromName,
      required this.toUserId,
      required this.toName,
      required this.body,
      required this.read,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_user_id'] = Variable<String>(fromUserId);
    map['from_name'] = Variable<String>(fromName);
    map['to_user_id'] = Variable<String>(toUserId);
    map['to_name'] = Variable<String>(toName);
    map['body'] = Variable<String>(body);
    map['read'] = Variable<bool>(read);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      fromUserId: Value(fromUserId),
      fromName: Value(fromName),
      toUserId: Value(toUserId),
      toName: Value(toName),
      body: Value(body),
      read: Value(read),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      fromUserId: serializer.fromJson<String>(json['fromUserId']),
      fromName: serializer.fromJson<String>(json['fromName']),
      toUserId: serializer.fromJson<String>(json['toUserId']),
      toName: serializer.fromJson<String>(json['toName']),
      body: serializer.fromJson<String>(json['body']),
      read: serializer.fromJson<bool>(json['read']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromUserId': serializer.toJson<String>(fromUserId),
      'fromName': serializer.toJson<String>(fromName),
      'toUserId': serializer.toJson<String>(toUserId),
      'toName': serializer.toJson<String>(toName),
      'body': serializer.toJson<String>(body),
      'read': serializer.toJson<bool>(read),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  Message copyWith(
          {String? id,
          String? fromUserId,
          String? fromName,
          String? toUserId,
          String? toName,
          String? body,
          bool? read,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          Value<String?> deviceId = const Value.absent()}) =>
      Message(
        id: id ?? this.id,
        fromUserId: fromUserId ?? this.fromUserId,
        fromName: fromName ?? this.fromName,
        toUserId: toUserId ?? this.toUserId,
        toName: toName ?? this.toName,
        body: body ?? this.body,
        read: read ?? this.read,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      fromUserId:
          data.fromUserId.present ? data.fromUserId.value : this.fromUserId,
      fromName: data.fromName.present ? data.fromName.value : this.fromName,
      toUserId: data.toUserId.present ? data.toUserId.value : this.toUserId,
      toName: data.toName.present ? data.toName.value : this.toName,
      body: data.body.present ? data.body.value : this.body,
      read: data.read.present ? data.read.value : this.read,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('fromName: $fromName, ')
          ..write('toUserId: $toUserId, ')
          ..write('toName: $toName, ')
          ..write('body: $body, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fromUserId, fromName, toUserId, toName,
      body, read, createdAt, updatedAt, deleted, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.fromUserId == this.fromUserId &&
          other.fromName == this.fromName &&
          other.toUserId == this.toUserId &&
          other.toName == this.toName &&
          other.body == this.body &&
          other.read == this.read &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.deviceId == this.deviceId);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> fromUserId;
  final Value<String> fromName;
  final Value<String> toUserId;
  final Value<String> toName;
  final Value<String> body;
  final Value<bool> read;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.fromUserId = const Value.absent(),
    this.fromName = const Value.absent(),
    this.toUserId = const Value.absent(),
    this.toName = const Value.absent(),
    this.body = const Value.absent(),
    this.read = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String fromUserId,
    required String fromName,
    required String toUserId,
    required String toName,
    required String body,
    this.read = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fromUserId = Value(fromUserId),
        fromName = Value(fromName),
        toUserId = Value(toUserId),
        toName = Value(toName),
        body = Value(body),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? fromUserId,
    Expression<String>? fromName,
    Expression<String>? toUserId,
    Expression<String>? toName,
    Expression<String>? body,
    Expression<bool>? read,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromUserId != null) 'from_user_id': fromUserId,
      if (fromName != null) 'from_name': fromName,
      if (toUserId != null) 'to_user_id': toUserId,
      if (toName != null) 'to_name': toName,
      if (body != null) 'body': body,
      if (read != null) 'read': read,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? fromUserId,
      Value<String>? fromName,
      Value<String>? toUserId,
      Value<String>? toName,
      Value<String>? body,
      Value<bool>? read,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromName: fromName ?? this.fromName,
      toUserId: toUserId ?? this.toUserId,
      toName: toName ?? this.toName,
      body: body ?? this.body,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromUserId.present) {
      map['from_user_id'] = Variable<String>(fromUserId.value);
    }
    if (fromName.present) {
      map['from_name'] = Variable<String>(fromName.value);
    }
    if (toUserId.present) {
      map['to_user_id'] = Variable<String>(toUserId.value);
    }
    if (toName.present) {
      map['to_name'] = Variable<String>(toName.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('fromName: $fromName, ')
          ..write('toUserId: $toUserId, ')
          ..write('toName: $toName, ')
          ..write('body: $body, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventDateMeta =
      const VerificationMeta('eventDate');
  @override
  late final GeneratedColumn<String> eventDate = GeneratedColumn<String>(
      'event_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTimeMeta =
      const VerificationMeta('eventTime');
  @override
  late final GeneratedColumn<String> eventTime = GeneratedColumn<String>(
      'event_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
      'place', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#1B5E20'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        eventDate,
        eventTime,
        place,
        type,
        color,
        createdAt,
        updatedAt,
        deleted,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<Event> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(_eventDateMeta,
          eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta));
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('event_time')) {
      context.handle(_eventTimeMeta,
          eventTime.isAcceptableOrUnknown(data['event_time']!, _eventTimeMeta));
    }
    if (data.containsKey('place')) {
      context.handle(
          _placeMeta, place.isAcceptableOrUnknown(data['place']!, _placeMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      eventDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_date'])!,
      eventTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_time']),
      place: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}place']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String title;
  final String eventDate;
  final String? eventTime;
  final String? place;
  final String? type;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String? deviceId;
  const Event(
      {required this.id,
      required this.title,
      required this.eventDate,
      this.eventTime,
      this.place,
      this.type,
      required this.color,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['event_date'] = Variable<String>(eventDate);
    if (!nullToAbsent || eventTime != null) {
      map['event_time'] = Variable<String>(eventTime);
    }
    if (!nullToAbsent || place != null) {
      map['place'] = Variable<String>(place);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      title: Value(title),
      eventDate: Value(eventDate),
      eventTime: eventTime == null && nullToAbsent
          ? const Value.absent()
          : Value(eventTime),
      place:
          place == null && nullToAbsent ? const Value.absent() : Value(place),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      color: Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory Event.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      eventDate: serializer.fromJson<String>(json['eventDate']),
      eventTime: serializer.fromJson<String?>(json['eventTime']),
      place: serializer.fromJson<String?>(json['place']),
      type: serializer.fromJson<String?>(json['type']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'eventDate': serializer.toJson<String>(eventDate),
      'eventTime': serializer.toJson<String?>(eventTime),
      'place': serializer.toJson<String?>(place),
      'type': serializer.toJson<String?>(type),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  Event copyWith(
          {String? id,
          String? title,
          String? eventDate,
          Value<String?> eventTime = const Value.absent(),
          Value<String?> place = const Value.absent(),
          Value<String?> type = const Value.absent(),
          String? color,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          Value<String?> deviceId = const Value.absent()}) =>
      Event(
        id: id ?? this.id,
        title: title ?? this.title,
        eventDate: eventDate ?? this.eventDate,
        eventTime: eventTime.present ? eventTime.value : this.eventTime,
        place: place.present ? place.value : this.place,
        type: type.present ? type.value : this.type,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      eventTime: data.eventTime.present ? data.eventTime.value : this.eventTime,
      place: data.place.present ? data.place.value : this.place,
      type: data.type.present ? data.type.value : this.type,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('eventDate: $eventDate, ')
          ..write('eventTime: $eventTime, ')
          ..write('place: $place, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, eventDate, eventTime, place, type,
      color, createdAt, updatedAt, deleted, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.title == this.title &&
          other.eventDate == this.eventDate &&
          other.eventTime == this.eventTime &&
          other.place == this.place &&
          other.type == this.type &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.deviceId == this.deviceId);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> eventDate;
  final Value<String?> eventTime;
  final Value<String?> place;
  final Value<String?> type;
  final Value<String> color;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.eventTime = const Value.absent(),
    this.place = const Value.absent(),
    this.type = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String title,
    required String eventDate,
    this.eventTime = const Value.absent(),
    this.place = const Value.absent(),
    this.type = const Value.absent(),
    this.color = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        eventDate = Value(eventDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? eventDate,
    Expression<String>? eventTime,
    Expression<String>? place,
    Expression<String>? type,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (eventDate != null) 'event_date': eventDate,
      if (eventTime != null) 'event_time': eventTime,
      if (place != null) 'place': place,
      if (type != null) 'type': type,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? eventDate,
      Value<String?>? eventTime,
      Value<String?>? place,
      Value<String?>? type,
      Value<String>? color,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      place: place ?? this.place,
      type: type ?? this.type,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<String>(eventDate.value);
    }
    if (eventTime.present) {
      map['event_time'] = Variable<String>(eventTime.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('eventDate: $eventDate, ')
          ..write('eventTime: $eventTime, ')
          ..write('place: $place, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FundSettingsTable extends FundSettings
    with TableInfo<$FundSettingsTable, FundSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FundSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('الصندوق الاجتماعي التنموي'));
  static const VerificationMeta _logoBase64Meta =
      const VerificationMeta('logoBase64');
  @override
  late final GeneratedColumn<String> logoBase64 = GeneratedColumn<String>(
      'logo_base64', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _registrationNoMeta =
      const VerificationMeta('registrationNo');
  @override
  late final GeneratedColumn<String> registrationNo = GeneratedColumn<String>(
      'registration_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        logoBase64,
        phone,
        email,
        address,
        registrationNo,
        createdAt,
        updatedAt,
        deleted,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fund_settings';
  @override
  VerificationContext validateIntegrity(Insertable<FundSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('logo_base64')) {
      context.handle(
          _logoBase64Meta,
          logoBase64.isAcceptableOrUnknown(
              data['logo_base64']!, _logoBase64Meta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('registration_no')) {
      context.handle(
          _registrationNoMeta,
          registrationNo.isAcceptableOrUnknown(
              data['registration_no']!, _registrationNoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FundSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FundSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      logoBase64: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_base64']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      registrationNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}registration_no']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $FundSettingsTable createAlias(String alias) {
    return $FundSettingsTable(attachedDatabase, alias);
  }
}

class FundSetting extends DataClass implements Insertable<FundSetting> {
  final String id;
  final String name;
  final String? logoBase64;
  final String? phone;
  final String? email;
  final String? address;
  final String? registrationNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final String? deviceId;
  const FundSetting(
      {required this.id,
      required this.name,
      this.logoBase64,
      this.phone,
      this.email,
      this.address,
      this.registrationNo,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logoBase64 != null) {
      map['logo_base64'] = Variable<String>(logoBase64);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || registrationNo != null) {
      map['registration_no'] = Variable<String>(registrationNo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  FundSettingsCompanion toCompanion(bool nullToAbsent) {
    return FundSettingsCompanion(
      id: Value(id),
      name: Value(name),
      logoBase64: logoBase64 == null && nullToAbsent
          ? const Value.absent()
          : Value(logoBase64),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      registrationNo: registrationNo == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationNo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory FundSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FundSetting(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      logoBase64: serializer.fromJson<String?>(json['logoBase64']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      registrationNo: serializer.fromJson<String?>(json['registrationNo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'logoBase64': serializer.toJson<String?>(logoBase64),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'registrationNo': serializer.toJson<String?>(registrationNo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  FundSetting copyWith(
          {String? id,
          String? name,
          Value<String?> logoBase64 = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> registrationNo = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          Value<String?> deviceId = const Value.absent()}) =>
      FundSetting(
        id: id ?? this.id,
        name: name ?? this.name,
        logoBase64: logoBase64.present ? logoBase64.value : this.logoBase64,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        address: address.present ? address.value : this.address,
        registrationNo:
            registrationNo.present ? registrationNo.value : this.registrationNo,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  FundSetting copyWithCompanion(FundSettingsCompanion data) {
    return FundSetting(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      logoBase64:
          data.logoBase64.present ? data.logoBase64.value : this.logoBase64,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      registrationNo: data.registrationNo.present
          ? data.registrationNo.value
          : this.registrationNo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FundSetting(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoBase64: $logoBase64, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('registrationNo: $registrationNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, logoBase64, phone, email, address,
      registrationNo, createdAt, updatedAt, deleted, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FundSetting &&
          other.id == this.id &&
          other.name == this.name &&
          other.logoBase64 == this.logoBase64 &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.registrationNo == this.registrationNo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.deviceId == this.deviceId);
}

class FundSettingsCompanion extends UpdateCompanion<FundSetting> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> logoBase64;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> registrationNo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const FundSettingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.logoBase64 = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.registrationNo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FundSettingsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.logoBase64 = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.registrationNo = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FundSetting> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? logoBase64,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? registrationNo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (logoBase64 != null) 'logo_base64': logoBase64,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (registrationNo != null) 'registration_no': registrationNo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FundSettingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? logoBase64,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? address,
      Value<String?>? registrationNo,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return FundSettingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      logoBase64: logoBase64 ?? this.logoBase64,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      registrationNo: registrationNo ?? this.registrationNo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logoBase64.present) {
      map['logo_base64'] = Variable<String>(logoBase64.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (registrationNo.present) {
      map['registration_no'] = Variable<String>(registrationNo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FundSettingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoBase64: $logoBase64, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('registrationNo: $registrationNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPostableMeta =
      const VerificationMeta('isPostable');
  @override
  late final GeneratedColumn<bool> isPostable = GeneratedColumn<bool>(
      'is_postable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_postable" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isBankMeta = const VerificationMeta('isBank');
  @override
  late final GeneratedColumn<bool> isBank = GeneratedColumn<bool>(
      'is_bank', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_bank" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isCashMeta = const VerificationMeta('isCash');
  @override
  late final GeneratedColumn<bool> isCash = GeneratedColumn<bool>(
      'is_cash', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_cash" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isWalletMeta =
      const VerificationMeta('isWallet');
  @override
  late final GeneratedColumn<bool> isWallet = GeneratedColumn<bool>(
      'is_wallet', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_wallet" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('YER'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        code,
        name,
        type,
        parentId,
        isPostable,
        level,
        sortOrder,
        description,
        isBank,
        isCash,
        isWallet,
        bankName,
        accountNumber,
        currency,
        isActive,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('is_postable')) {
      context.handle(
          _isPostableMeta,
          isPostable.isAcceptableOrUnknown(
              data['is_postable']!, _isPostableMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_bank')) {
      context.handle(_isBankMeta,
          isBank.isAcceptableOrUnknown(data['is_bank']!, _isBankMeta));
    }
    if (data.containsKey('is_cash')) {
      context.handle(_isCashMeta,
          isCash.isAcceptableOrUnknown(data['is_cash']!, _isCashMeta));
    }
    if (data.containsKey('is_wallet')) {
      context.handle(_isWalletMeta,
          isWallet.isAcceptableOrUnknown(data['is_wallet']!, _isWalletMeta));
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      isPostable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_postable'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isBank: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_bank'])!,
      isCash: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_cash'])!,
      isWallet: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_wallet'])!,
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name']),
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String code;
  final String name;
  final String type;
  final String? parentId;
  final bool isPostable;
  final int level;
  final int sortOrder;
  final String? description;
  final bool isBank;
  final bool isCash;
  final bool isWallet;
  final String? bankName;
  final String? accountNumber;
  final String currency;
  final bool isActive;
  final DateTime createdAt;
  const Account(
      {required this.id,
      required this.code,
      required this.name,
      required this.type,
      this.parentId,
      required this.isPostable,
      required this.level,
      required this.sortOrder,
      this.description,
      required this.isBank,
      required this.isCash,
      required this.isWallet,
      this.bankName,
      this.accountNumber,
      required this.currency,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['is_postable'] = Variable<bool>(isPostable);
    map['level'] = Variable<int>(level);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_bank'] = Variable<bool>(isBank);
    map['is_cash'] = Variable<bool>(isCash);
    map['is_wallet'] = Variable<bool>(isWallet);
    if (!nullToAbsent || bankName != null) {
      map['bank_name'] = Variable<String>(bankName);
    }
    if (!nullToAbsent || accountNumber != null) {
      map['account_number'] = Variable<String>(accountNumber);
    }
    map['currency'] = Variable<String>(currency);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      type: Value(type),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isPostable: Value(isPostable),
      level: Value(level),
      sortOrder: Value(sortOrder),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isBank: Value(isBank),
      isCash: Value(isCash),
      isWallet: Value(isWallet),
      bankName: bankName == null && nullToAbsent
          ? const Value.absent()
          : Value(bankName),
      accountNumber: accountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountNumber),
      currency: Value(currency),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      isPostable: serializer.fromJson<bool>(json['isPostable']),
      level: serializer.fromJson<int>(json['level']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      description: serializer.fromJson<String?>(json['description']),
      isBank: serializer.fromJson<bool>(json['isBank']),
      isCash: serializer.fromJson<bool>(json['isCash']),
      isWallet: serializer.fromJson<bool>(json['isWallet']),
      bankName: serializer.fromJson<String?>(json['bankName']),
      accountNumber: serializer.fromJson<String?>(json['accountNumber']),
      currency: serializer.fromJson<String>(json['currency']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'parentId': serializer.toJson<String?>(parentId),
      'isPostable': serializer.toJson<bool>(isPostable),
      'level': serializer.toJson<int>(level),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'description': serializer.toJson<String?>(description),
      'isBank': serializer.toJson<bool>(isBank),
      'isCash': serializer.toJson<bool>(isCash),
      'isWallet': serializer.toJson<bool>(isWallet),
      'bankName': serializer.toJson<String?>(bankName),
      'accountNumber': serializer.toJson<String?>(accountNumber),
      'currency': serializer.toJson<String>(currency),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Account copyWith(
          {String? id,
          String? code,
          String? name,
          String? type,
          Value<String?> parentId = const Value.absent(),
          bool? isPostable,
          int? level,
          int? sortOrder,
          Value<String?> description = const Value.absent(),
          bool? isBank,
          bool? isCash,
          bool? isWallet,
          Value<String?> bankName = const Value.absent(),
          Value<String?> accountNumber = const Value.absent(),
          String? currency,
          bool? isActive,
          DateTime? createdAt}) =>
      Account(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        type: type ?? this.type,
        parentId: parentId.present ? parentId.value : this.parentId,
        isPostable: isPostable ?? this.isPostable,
        level: level ?? this.level,
        sortOrder: sortOrder ?? this.sortOrder,
        description: description.present ? description.value : this.description,
        isBank: isBank ?? this.isBank,
        isCash: isCash ?? this.isCash,
        isWallet: isWallet ?? this.isWallet,
        bankName: bankName.present ? bankName.value : this.bankName,
        accountNumber:
            accountNumber.present ? accountNumber.value : this.accountNumber,
        currency: currency ?? this.currency,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isPostable:
          data.isPostable.present ? data.isPostable.value : this.isPostable,
      level: data.level.present ? data.level.value : this.level,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      description:
          data.description.present ? data.description.value : this.description,
      isBank: data.isBank.present ? data.isBank.value : this.isBank,
      isCash: data.isCash.present ? data.isCash.value : this.isCash,
      isWallet: data.isWallet.present ? data.isWallet.value : this.isWallet,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      currency: data.currency.present ? data.currency.value : this.currency,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('isPostable: $isPostable, ')
          ..write('level: $level, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('description: $description, ')
          ..write('isBank: $isBank, ')
          ..write('isCash: $isCash, ')
          ..write('isWallet: $isWallet, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('currency: $currency, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      code,
      name,
      type,
      parentId,
      isPostable,
      level,
      sortOrder,
      description,
      isBank,
      isCash,
      isWallet,
      bankName,
      accountNumber,
      currency,
      isActive,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.type == this.type &&
          other.parentId == this.parentId &&
          other.isPostable == this.isPostable &&
          other.level == this.level &&
          other.sortOrder == this.sortOrder &&
          other.description == this.description &&
          other.isBank == this.isBank &&
          other.isCash == this.isCash &&
          other.isWallet == this.isWallet &&
          other.bankName == this.bankName &&
          other.accountNumber == this.accountNumber &&
          other.currency == this.currency &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> parentId;
  final Value<bool> isPostable;
  final Value<int> level;
  final Value<int> sortOrder;
  final Value<String?> description;
  final Value<bool> isBank;
  final Value<bool> isCash;
  final Value<bool> isWallet;
  final Value<String?> bankName;
  final Value<String?> accountNumber;
  final Value<String> currency;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isPostable = const Value.absent(),
    this.level = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.description = const Value.absent(),
    this.isBank = const Value.absent(),
    this.isCash = const Value.absent(),
    this.isWallet = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.currency = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String code,
    required String name,
    required String type,
    this.parentId = const Value.absent(),
    this.isPostable = const Value.absent(),
    this.level = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.description = const Value.absent(),
    this.isBank = const Value.absent(),
    this.isCash = const Value.absent(),
    this.isWallet = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.currency = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        code = Value(code),
        name = Value(name),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? parentId,
    Expression<bool>? isPostable,
    Expression<int>? level,
    Expression<int>? sortOrder,
    Expression<String>? description,
    Expression<bool>? isBank,
    Expression<bool>? isCash,
    Expression<bool>? isWallet,
    Expression<String>? bankName,
    Expression<String>? accountNumber,
    Expression<String>? currency,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (parentId != null) 'parent_id': parentId,
      if (isPostable != null) 'is_postable': isPostable,
      if (level != null) 'level': level,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (description != null) 'description': description,
      if (isBank != null) 'is_bank': isBank,
      if (isCash != null) 'is_cash': isCash,
      if (isWallet != null) 'is_wallet': isWallet,
      if (bankName != null) 'bank_name': bankName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (currency != null) 'currency': currency,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? code,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? parentId,
      Value<bool>? isPostable,
      Value<int>? level,
      Value<int>? sortOrder,
      Value<String?>? description,
      Value<bool>? isBank,
      Value<bool>? isCash,
      Value<bool>? isWallet,
      Value<String?>? bankName,
      Value<String?>? accountNumber,
      Value<String>? currency,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      isPostable: isPostable ?? this.isPostable,
      level: level ?? this.level,
      sortOrder: sortOrder ?? this.sortOrder,
      description: description ?? this.description,
      isBank: isBank ?? this.isBank,
      isCash: isCash ?? this.isCash,
      isWallet: isWallet ?? this.isWallet,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (isPostable.present) {
      map['is_postable'] = Variable<bool>(isPostable.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isBank.present) {
      map['is_bank'] = Variable<bool>(isBank.value);
    }
    if (isCash.present) {
      map['is_cash'] = Variable<bool>(isCash.value);
    }
    if (isWallet.present) {
      map['is_wallet'] = Variable<bool>(isWallet.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('isPostable: $isPostable, ')
          ..write('level: $level, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('description: $description, ')
          ..write('isBank: $isBank, ')
          ..write('isCash: $isCash, ')
          ..write('isWallet: $isWallet, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('currency: $currency, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryNoMeta =
      const VerificationMeta('entryNo');
  @override
  late final GeneratedColumn<String> entryNo = GeneratedColumn<String>(
      'entry_no', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _entryDateMeta =
      const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
      'entry_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryTypeMeta =
      const VerificationMeta('entryType');
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
      'entry_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('posted'));
  static const VerificationMeta _campaignIdMeta =
      const VerificationMeta('campaignId');
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
      'campaign_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _donorIdMeta =
      const VerificationMeta('donorId');
  @override
  late final GeneratedColumn<String> donorId = GeneratedColumn<String>(
      'donor_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aidIdMeta = const VerificationMeta('aidId');
  @override
  late final GeneratedColumn<String> aidId = GeneratedColumn<String>(
      'aid_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
      'beneficiary_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _voucherIdMeta =
      const VerificationMeta('voucherId');
  @override
  late final GeneratedColumn<String> voucherId = GeneratedColumn<String>(
      'voucher_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entryNo,
        entryDate,
        description,
        entryType,
        reference,
        status,
        campaignId,
        donorId,
        memberId,
        aidId,
        beneficiaryId,
        voucherId,
        createdBy,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(Insertable<JournalEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_no')) {
      context.handle(_entryNoMeta,
          entryNo.isAcceptableOrUnknown(data['entry_no']!, _entryNoMeta));
    } else if (isInserting) {
      context.missing(_entryNoMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta,
          entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(_entryTypeMeta,
          entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta));
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
          _campaignIdMeta,
          campaignId.isAcceptableOrUnknown(
              data['campaign_id']!, _campaignIdMeta));
    }
    if (data.containsKey('donor_id')) {
      context.handle(_donorIdMeta,
          donorId.isAcceptableOrUnknown(data['donor_id']!, _donorIdMeta));
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    }
    if (data.containsKey('aid_id')) {
      context.handle(
          _aidIdMeta, aidId.isAcceptableOrUnknown(data['aid_id']!, _aidIdMeta));
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    }
    if (data.containsKey('voucher_id')) {
      context.handle(_voucherIdMeta,
          voucherId.isAcceptableOrUnknown(data['voucher_id']!, _voucherIdMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entryNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_no'])!,
      entryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      entryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_type'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      campaignId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}campaign_id']),
      donorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}donor_id']),
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id']),
      aidId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aid_id']),
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}beneficiary_id']),
      voucherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voucher_id']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final String id;
  final String entryNo;
  final String entryDate;
  final String description;
  final String entryType;
  final String? reference;
  final String status;
  final String? campaignId;
  final String? donorId;
  final String? memberId;
  final String? aidId;
  final String? beneficiaryId;
  final String? voucherId;
  final String? createdBy;
  final DateTime createdAt;
  const JournalEntry(
      {required this.id,
      required this.entryNo,
      required this.entryDate,
      required this.description,
      required this.entryType,
      this.reference,
      required this.status,
      this.campaignId,
      this.donorId,
      this.memberId,
      this.aidId,
      this.beneficiaryId,
      this.voucherId,
      this.createdBy,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_no'] = Variable<String>(entryNo);
    map['entry_date'] = Variable<String>(entryDate);
    map['description'] = Variable<String>(description);
    map['entry_type'] = Variable<String>(entryType);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || campaignId != null) {
      map['campaign_id'] = Variable<String>(campaignId);
    }
    if (!nullToAbsent || donorId != null) {
      map['donor_id'] = Variable<String>(donorId);
    }
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    if (!nullToAbsent || aidId != null) {
      map['aid_id'] = Variable<String>(aidId);
    }
    if (!nullToAbsent || beneficiaryId != null) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId);
    }
    if (!nullToAbsent || voucherId != null) {
      map['voucher_id'] = Variable<String>(voucherId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      entryNo: Value(entryNo),
      entryDate: Value(entryDate),
      description: Value(description),
      entryType: Value(entryType),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      status: Value(status),
      campaignId: campaignId == null && nullToAbsent
          ? const Value.absent()
          : Value(campaignId),
      donorId: donorId == null && nullToAbsent
          ? const Value.absent()
          : Value(donorId),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      aidId:
          aidId == null && nullToAbsent ? const Value.absent() : Value(aidId),
      beneficiaryId: beneficiaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(beneficiaryId),
      voucherId: voucherId == null && nullToAbsent
          ? const Value.absent()
          : Value(voucherId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<String>(json['id']),
      entryNo: serializer.fromJson<String>(json['entryNo']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      description: serializer.fromJson<String>(json['description']),
      entryType: serializer.fromJson<String>(json['entryType']),
      reference: serializer.fromJson<String?>(json['reference']),
      status: serializer.fromJson<String>(json['status']),
      campaignId: serializer.fromJson<String?>(json['campaignId']),
      donorId: serializer.fromJson<String?>(json['donorId']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      aidId: serializer.fromJson<String?>(json['aidId']),
      beneficiaryId: serializer.fromJson<String?>(json['beneficiaryId']),
      voucherId: serializer.fromJson<String?>(json['voucherId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryNo': serializer.toJson<String>(entryNo),
      'entryDate': serializer.toJson<String>(entryDate),
      'description': serializer.toJson<String>(description),
      'entryType': serializer.toJson<String>(entryType),
      'reference': serializer.toJson<String?>(reference),
      'status': serializer.toJson<String>(status),
      'campaignId': serializer.toJson<String?>(campaignId),
      'donorId': serializer.toJson<String?>(donorId),
      'memberId': serializer.toJson<String?>(memberId),
      'aidId': serializer.toJson<String?>(aidId),
      'beneficiaryId': serializer.toJson<String?>(beneficiaryId),
      'voucherId': serializer.toJson<String?>(voucherId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  JournalEntry copyWith(
          {String? id,
          String? entryNo,
          String? entryDate,
          String? description,
          String? entryType,
          Value<String?> reference = const Value.absent(),
          String? status,
          Value<String?> campaignId = const Value.absent(),
          Value<String?> donorId = const Value.absent(),
          Value<String?> memberId = const Value.absent(),
          Value<String?> aidId = const Value.absent(),
          Value<String?> beneficiaryId = const Value.absent(),
          Value<String?> voucherId = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          DateTime? createdAt}) =>
      JournalEntry(
        id: id ?? this.id,
        entryNo: entryNo ?? this.entryNo,
        entryDate: entryDate ?? this.entryDate,
        description: description ?? this.description,
        entryType: entryType ?? this.entryType,
        reference: reference.present ? reference.value : this.reference,
        status: status ?? this.status,
        campaignId: campaignId.present ? campaignId.value : this.campaignId,
        donorId: donorId.present ? donorId.value : this.donorId,
        memberId: memberId.present ? memberId.value : this.memberId,
        aidId: aidId.present ? aidId.value : this.aidId,
        beneficiaryId:
            beneficiaryId.present ? beneficiaryId.value : this.beneficiaryId,
        voucherId: voucherId.present ? voucherId.value : this.voucherId,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        createdAt: createdAt ?? this.createdAt,
      );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      entryNo: data.entryNo.present ? data.entryNo.value : this.entryNo,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      description:
          data.description.present ? data.description.value : this.description,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      reference: data.reference.present ? data.reference.value : this.reference,
      status: data.status.present ? data.status.value : this.status,
      campaignId:
          data.campaignId.present ? data.campaignId.value : this.campaignId,
      donorId: data.donorId.present ? data.donorId.value : this.donorId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      aidId: data.aidId.present ? data.aidId.value : this.aidId,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      voucherId: data.voucherId.present ? data.voucherId.value : this.voucherId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('entryNo: $entryNo, ')
          ..write('entryDate: $entryDate, ')
          ..write('description: $description, ')
          ..write('entryType: $entryType, ')
          ..write('reference: $reference, ')
          ..write('status: $status, ')
          ..write('campaignId: $campaignId, ')
          ..write('donorId: $donorId, ')
          ..write('memberId: $memberId, ')
          ..write('aidId: $aidId, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('voucherId: $voucherId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entryNo,
      entryDate,
      description,
      entryType,
      reference,
      status,
      campaignId,
      donorId,
      memberId,
      aidId,
      beneficiaryId,
      voucherId,
      createdBy,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.entryNo == this.entryNo &&
          other.entryDate == this.entryDate &&
          other.description == this.description &&
          other.entryType == this.entryType &&
          other.reference == this.reference &&
          other.status == this.status &&
          other.campaignId == this.campaignId &&
          other.donorId == this.donorId &&
          other.memberId == this.memberId &&
          other.aidId == this.aidId &&
          other.beneficiaryId == this.beneficiaryId &&
          other.voucherId == this.voucherId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<String> id;
  final Value<String> entryNo;
  final Value<String> entryDate;
  final Value<String> description;
  final Value<String> entryType;
  final Value<String?> reference;
  final Value<String> status;
  final Value<String?> campaignId;
  final Value<String?> donorId;
  final Value<String?> memberId;
  final Value<String?> aidId;
  final Value<String?> beneficiaryId;
  final Value<String?> voucherId;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.entryNo = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.description = const Value.absent(),
    this.entryType = const Value.absent(),
    this.reference = const Value.absent(),
    this.status = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.donorId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.aidId = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.voucherId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required String entryNo,
    required String entryDate,
    required String description,
    required String entryType,
    this.reference = const Value.absent(),
    this.status = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.donorId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.aidId = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.voucherId = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entryNo = Value(entryNo),
        entryDate = Value(entryDate),
        description = Value(description),
        entryType = Value(entryType),
        createdAt = Value(createdAt);
  static Insertable<JournalEntry> custom({
    Expression<String>? id,
    Expression<String>? entryNo,
    Expression<String>? entryDate,
    Expression<String>? description,
    Expression<String>? entryType,
    Expression<String>? reference,
    Expression<String>? status,
    Expression<String>? campaignId,
    Expression<String>? donorId,
    Expression<String>? memberId,
    Expression<String>? aidId,
    Expression<String>? beneficiaryId,
    Expression<String>? voucherId,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryNo != null) 'entry_no': entryNo,
      if (entryDate != null) 'entry_date': entryDate,
      if (description != null) 'description': description,
      if (entryType != null) 'entry_type': entryType,
      if (reference != null) 'reference': reference,
      if (status != null) 'status': status,
      if (campaignId != null) 'campaign_id': campaignId,
      if (donorId != null) 'donor_id': donorId,
      if (memberId != null) 'member_id': memberId,
      if (aidId != null) 'aid_id': aidId,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (voucherId != null) 'voucher_id': voucherId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? entryNo,
      Value<String>? entryDate,
      Value<String>? description,
      Value<String>? entryType,
      Value<String?>? reference,
      Value<String>? status,
      Value<String?>? campaignId,
      Value<String?>? donorId,
      Value<String?>? memberId,
      Value<String?>? aidId,
      Value<String?>? beneficiaryId,
      Value<String?>? voucherId,
      Value<String?>? createdBy,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      entryNo: entryNo ?? this.entryNo,
      entryDate: entryDate ?? this.entryDate,
      description: description ?? this.description,
      entryType: entryType ?? this.entryType,
      reference: reference ?? this.reference,
      status: status ?? this.status,
      campaignId: campaignId ?? this.campaignId,
      donorId: donorId ?? this.donorId,
      memberId: memberId ?? this.memberId,
      aidId: aidId ?? this.aidId,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      voucherId: voucherId ?? this.voucherId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryNo.present) {
      map['entry_no'] = Variable<String>(entryNo.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (donorId.present) {
      map['donor_id'] = Variable<String>(donorId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (aidId.present) {
      map['aid_id'] = Variable<String>(aidId.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId.value);
    }
    if (voucherId.present) {
      map['voucher_id'] = Variable<String>(voucherId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entryNo: $entryNo, ')
          ..write('entryDate: $entryDate, ')
          ..write('description: $description, ')
          ..write('entryType: $entryType, ')
          ..write('reference: $reference, ')
          ..write('status: $status, ')
          ..write('campaignId: $campaignId, ')
          ..write('donorId: $donorId, ')
          ..write('memberId: $memberId, ')
          ..write('aidId: $aidId, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('voucherId: $voucherId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalLinesTable extends JournalLines
    with TableInfo<$JournalLinesTable, JournalLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryIdMeta =
      const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
      'entry_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _debitMeta = const VerificationMeta('debit');
  @override
  late final GeneratedColumn<double> debit = GeneratedColumn<double>(
      'debit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _creditMeta = const VerificationMeta('credit');
  @override
  late final GeneratedColumn<double> credit = GeneratedColumn<double>(
      'credit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entryId, accountId, debit, credit, memo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_lines';
  @override
  VerificationContext validateIntegrity(Insertable<JournalLine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta,
          entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('debit')) {
      context.handle(
          _debitMeta, debit.isAcceptableOrUnknown(data['debit']!, _debitMeta));
    }
    if (data.containsKey('credit')) {
      context.handle(_creditMeta,
          credit.isAcceptableOrUnknown(data['credit']!, _creditMeta));
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalLine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      debit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}debit'])!,
      credit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}credit'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
    );
  }

  @override
  $JournalLinesTable createAlias(String alias) {
    return $JournalLinesTable(attachedDatabase, alias);
  }
}

class JournalLine extends DataClass implements Insertable<JournalLine> {
  final String id;
  final String entryId;
  final String accountId;
  final double debit;
  final double credit;
  final String? memo;
  const JournalLine(
      {required this.id,
      required this.entryId,
      required this.accountId,
      required this.debit,
      required this.credit,
      this.memo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_id'] = Variable<String>(entryId);
    map['account_id'] = Variable<String>(accountId);
    map['debit'] = Variable<double>(debit);
    map['credit'] = Variable<double>(credit);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    return map;
  }

  JournalLinesCompanion toCompanion(bool nullToAbsent) {
    return JournalLinesCompanion(
      id: Value(id),
      entryId: Value(entryId),
      accountId: Value(accountId),
      debit: Value(debit),
      credit: Value(credit),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
    );
  }

  factory JournalLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalLine(
      id: serializer.fromJson<String>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      debit: serializer.fromJson<double>(json['debit']),
      credit: serializer.fromJson<double>(json['credit']),
      memo: serializer.fromJson<String?>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryId': serializer.toJson<String>(entryId),
      'accountId': serializer.toJson<String>(accountId),
      'debit': serializer.toJson<double>(debit),
      'credit': serializer.toJson<double>(credit),
      'memo': serializer.toJson<String?>(memo),
    };
  }

  JournalLine copyWith(
          {String? id,
          String? entryId,
          String? accountId,
          double? debit,
          double? credit,
          Value<String?> memo = const Value.absent()}) =>
      JournalLine(
        id: id ?? this.id,
        entryId: entryId ?? this.entryId,
        accountId: accountId ?? this.accountId,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
        memo: memo.present ? memo.value : this.memo,
      );
  JournalLine copyWithCompanion(JournalLinesCompanion data) {
    return JournalLine(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      debit: data.debit.present ? data.debit.value : this.debit,
      credit: data.credit.present ? data.credit.value : this.credit,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalLine(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('accountId: $accountId, ')
          ..write('debit: $debit, ')
          ..write('credit: $credit, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entryId, accountId, debit, credit, memo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalLine &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.accountId == this.accountId &&
          other.debit == this.debit &&
          other.credit == this.credit &&
          other.memo == this.memo);
}

class JournalLinesCompanion extends UpdateCompanion<JournalLine> {
  final Value<String> id;
  final Value<String> entryId;
  final Value<String> accountId;
  final Value<double> debit;
  final Value<double> credit;
  final Value<String?> memo;
  final Value<int> rowid;
  const JournalLinesCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
    this.memo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalLinesCompanion.insert({
    required String id,
    required String entryId,
    required String accountId,
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
    this.memo = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entryId = Value(entryId),
        accountId = Value(accountId);
  static Insertable<JournalLine> custom({
    Expression<String>? id,
    Expression<String>? entryId,
    Expression<String>? accountId,
    Expression<double>? debit,
    Expression<double>? credit,
    Expression<String>? memo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (accountId != null) 'account_id': accountId,
      if (debit != null) 'debit': debit,
      if (credit != null) 'credit': credit,
      if (memo != null) 'memo': memo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalLinesCompanion copyWith(
      {Value<String>? id,
      Value<String>? entryId,
      Value<String>? accountId,
      Value<double>? debit,
      Value<double>? credit,
      Value<String?>? memo,
      Value<int>? rowid}) {
    return JournalLinesCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      accountId: accountId ?? this.accountId,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      memo: memo ?? this.memo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (debit.present) {
      map['debit'] = Variable<double>(debit.value);
    }
    if (credit.present) {
      map['credit'] = Variable<double>(credit.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalLinesCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('accountId: $accountId, ')
          ..write('debit: $debit, ')
          ..write('credit: $credit, ')
          ..write('memo: $memo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BankStatementLinesTable extends BankStatementLines
    with TableInfo<$BankStatementLinesTable, BankStatementLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankStatementLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lineDateMeta =
      const VerificationMeta('lineDate');
  @override
  late final GeneratedColumn<String> lineDate = GeneratedColumn<String>(
      'line_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _externalRefMeta =
      const VerificationMeta('externalRef');
  @override
  late final GeneratedColumn<String> externalRef = GeneratedColumn<String>(
      'external_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _matchedLineIdMeta =
      const VerificationMeta('matchedLineId');
  @override
  late final GeneratedColumn<String> matchedLineId = GeneratedColumn<String>(
      'matched_line_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountId,
        lineDate,
        description,
        amount,
        externalRef,
        matchedLineId,
        createdBy,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_statement_lines';
  @override
  VerificationContext validateIntegrity(Insertable<BankStatementLine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('line_date')) {
      context.handle(_lineDateMeta,
          lineDate.isAcceptableOrUnknown(data['line_date']!, _lineDateMeta));
    } else if (isInserting) {
      context.missing(_lineDateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('external_ref')) {
      context.handle(
          _externalRefMeta,
          externalRef.isAcceptableOrUnknown(
              data['external_ref']!, _externalRefMeta));
    }
    if (data.containsKey('matched_line_id')) {
      context.handle(
          _matchedLineIdMeta,
          matchedLineId.isAcceptableOrUnknown(
              data['matched_line_id']!, _matchedLineIdMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankStatementLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankStatementLine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      lineDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}line_date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      externalRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}external_ref']),
      matchedLineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}matched_line_id']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BankStatementLinesTable createAlias(String alias) {
    return $BankStatementLinesTable(attachedDatabase, alias);
  }
}

class BankStatementLine extends DataClass
    implements Insertable<BankStatementLine> {
  final String id;
  final String accountId;
  final String lineDate;
  final String description;
  final double amount;
  final String? externalRef;
  final String? matchedLineId;
  final String? createdBy;
  final DateTime createdAt;
  const BankStatementLine(
      {required this.id,
      required this.accountId,
      required this.lineDate,
      required this.description,
      required this.amount,
      this.externalRef,
      this.matchedLineId,
      this.createdBy,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['line_date'] = Variable<String>(lineDate);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || externalRef != null) {
      map['external_ref'] = Variable<String>(externalRef);
    }
    if (!nullToAbsent || matchedLineId != null) {
      map['matched_line_id'] = Variable<String>(matchedLineId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BankStatementLinesCompanion toCompanion(bool nullToAbsent) {
    return BankStatementLinesCompanion(
      id: Value(id),
      accountId: Value(accountId),
      lineDate: Value(lineDate),
      description: Value(description),
      amount: Value(amount),
      externalRef: externalRef == null && nullToAbsent
          ? const Value.absent()
          : Value(externalRef),
      matchedLineId: matchedLineId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedLineId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory BankStatementLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankStatementLine(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      lineDate: serializer.fromJson<String>(json['lineDate']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      externalRef: serializer.fromJson<String?>(json['externalRef']),
      matchedLineId: serializer.fromJson<String?>(json['matchedLineId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'lineDate': serializer.toJson<String>(lineDate),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'externalRef': serializer.toJson<String?>(externalRef),
      'matchedLineId': serializer.toJson<String?>(matchedLineId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BankStatementLine copyWith(
          {String? id,
          String? accountId,
          String? lineDate,
          String? description,
          double? amount,
          Value<String?> externalRef = const Value.absent(),
          Value<String?> matchedLineId = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          DateTime? createdAt}) =>
      BankStatementLine(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        lineDate: lineDate ?? this.lineDate,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        externalRef: externalRef.present ? externalRef.value : this.externalRef,
        matchedLineId:
            matchedLineId.present ? matchedLineId.value : this.matchedLineId,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        createdAt: createdAt ?? this.createdAt,
      );
  BankStatementLine copyWithCompanion(BankStatementLinesCompanion data) {
    return BankStatementLine(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      lineDate: data.lineDate.present ? data.lineDate.value : this.lineDate,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      externalRef:
          data.externalRef.present ? data.externalRef.value : this.externalRef,
      matchedLineId: data.matchedLineId.present
          ? data.matchedLineId.value
          : this.matchedLineId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankStatementLine(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('lineDate: $lineDate, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('externalRef: $externalRef, ')
          ..write('matchedLineId: $matchedLineId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountId, lineDate, description, amount,
      externalRef, matchedLineId, createdBy, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankStatementLine &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.lineDate == this.lineDate &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.externalRef == this.externalRef &&
          other.matchedLineId == this.matchedLineId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class BankStatementLinesCompanion extends UpdateCompanion<BankStatementLine> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> lineDate;
  final Value<String> description;
  final Value<double> amount;
  final Value<String?> externalRef;
  final Value<String?> matchedLineId;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BankStatementLinesCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.lineDate = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.matchedLineId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BankStatementLinesCompanion.insert({
    required String id,
    required String accountId,
    required String lineDate,
    required String description,
    required double amount,
    this.externalRef = const Value.absent(),
    this.matchedLineId = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        accountId = Value(accountId),
        lineDate = Value(lineDate),
        description = Value(description),
        amount = Value(amount),
        createdAt = Value(createdAt);
  static Insertable<BankStatementLine> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? lineDate,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<String>? externalRef,
    Expression<String>? matchedLineId,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (lineDate != null) 'line_date': lineDate,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (externalRef != null) 'external_ref': externalRef,
      if (matchedLineId != null) 'matched_line_id': matchedLineId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BankStatementLinesCompanion copyWith(
      {Value<String>? id,
      Value<String>? accountId,
      Value<String>? lineDate,
      Value<String>? description,
      Value<double>? amount,
      Value<String?>? externalRef,
      Value<String?>? matchedLineId,
      Value<String?>? createdBy,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BankStatementLinesCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      lineDate: lineDate ?? this.lineDate,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      externalRef: externalRef ?? this.externalRef,
      matchedLineId: matchedLineId ?? this.matchedLineId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (lineDate.present) {
      map['line_date'] = Variable<String>(lineDate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (externalRef.present) {
      map['external_ref'] = Variable<String>(externalRef.value);
    }
    if (matchedLineId.present) {
      map['matched_line_id'] = Variable<String>(matchedLineId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankStatementLinesCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('lineDate: $lineDate, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('externalRef: $externalRef, ')
          ..write('matchedLineId: $matchedLineId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DonorsTable extends Donors with TableInfo<$DonorsTable, Donor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DonorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _donorTypeMeta =
      const VerificationMeta('donorType');
  @override
  late final GeneratedColumn<String> donorType = GeneratedColumn<String>(
      'donor_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('individual'));
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
      'tier', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('silver'));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, donorType, tier, phone, email, notes, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'donors';
  @override
  VerificationContext validateIntegrity(Insertable<Donor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('donor_type')) {
      context.handle(_donorTypeMeta,
          donorType.isAcceptableOrUnknown(data['donor_type']!, _donorTypeMeta));
    }
    if (data.containsKey('tier')) {
      context.handle(
          _tierMeta, tier.isAcceptableOrUnknown(data['tier']!, _tierMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Donor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Donor(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      donorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}donor_type'])!,
      tier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tier'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DonorsTable createAlias(String alias) {
    return $DonorsTable(attachedDatabase, alias);
  }
}

class Donor extends DataClass implements Insertable<Donor> {
  final String id;
  final String name;
  final String donorType;
  final String tier;
  final String? phone;
  final String? email;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  const Donor(
      {required this.id,
      required this.name,
      required this.donorType,
      required this.tier,
      this.phone,
      this.email,
      this.notes,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['donor_type'] = Variable<String>(donorType);
    map['tier'] = Variable<String>(tier);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DonorsCompanion toCompanion(bool nullToAbsent) {
    return DonorsCompanion(
      id: Value(id),
      name: Value(name),
      donorType: Value(donorType),
      tier: Value(tier),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Donor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Donor(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      donorType: serializer.fromJson<String>(json['donorType']),
      tier: serializer.fromJson<String>(json['tier']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'donorType': serializer.toJson<String>(donorType),
      'tier': serializer.toJson<String>(tier),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Donor copyWith(
          {String? id,
          String? name,
          String? donorType,
          String? tier,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? isActive,
          DateTime? createdAt}) =>
      Donor(
        id: id ?? this.id,
        name: name ?? this.name,
        donorType: donorType ?? this.donorType,
        tier: tier ?? this.tier,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        notes: notes.present ? notes.value : this.notes,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Donor copyWithCompanion(DonorsCompanion data) {
    return Donor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      donorType: data.donorType.present ? data.donorType.value : this.donorType,
      tier: data.tier.present ? data.tier.value : this.tier,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Donor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('donorType: $donorType, ')
          ..write('tier: $tier, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, donorType, tier, phone, email, notes, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Donor &&
          other.id == this.id &&
          other.name == this.name &&
          other.donorType == this.donorType &&
          other.tier == this.tier &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class DonorsCompanion extends UpdateCompanion<Donor> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> donorType;
  final Value<String> tier;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DonorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.donorType = const Value.absent(),
    this.tier = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DonorsCompanion.insert({
    required String id,
    required String name,
    this.donorType = const Value.absent(),
    this.tier = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Donor> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? donorType,
    Expression<String>? tier,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (donorType != null) 'donor_type': donorType,
      if (tier != null) 'tier': tier,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DonorsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? donorType,
      Value<String>? tier,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? notes,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return DonorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      donorType: donorType ?? this.donorType,
      tier: tier ?? this.tier,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (donorType.present) {
      map['donor_type'] = Variable<String>(donorType.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DonorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('donorType: $donorType, ')
          ..write('tier: $tier, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PledgesTable extends Pledges with TableInfo<$PledgesTable, Pledge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PledgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _donorIdMeta =
      const VerificationMeta('donorId');
  @override
  late final GeneratedColumn<String> donorId = GeneratedColumn<String>(
      'donor_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('monthly'));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
      'end_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _lastFulfilledOnMeta =
      const VerificationMeta('lastFulfilledOn');
  @override
  late final GeneratedColumn<String> lastFulfilledOn = GeneratedColumn<String>(
      'last_fulfilled_on', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        donorId,
        amount,
        frequency,
        startDate,
        endDate,
        status,
        lastFulfilledOn,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pledges';
  @override
  VerificationContext validateIntegrity(Insertable<Pledge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('donor_id')) {
      context.handle(_donorIdMeta,
          donorId.isAcceptableOrUnknown(data['donor_id']!, _donorIdMeta));
    } else if (isInserting) {
      context.missing(_donorIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('last_fulfilled_on')) {
      context.handle(
          _lastFulfilledOnMeta,
          lastFulfilledOn.isAcceptableOrUnknown(
              data['last_fulfilled_on']!, _lastFulfilledOnMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pledge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pledge(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      donorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}donor_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      lastFulfilledOn: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_fulfilled_on']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PledgesTable createAlias(String alias) {
    return $PledgesTable(attachedDatabase, alias);
  }
}

class Pledge extends DataClass implements Insertable<Pledge> {
  final String id;
  final String donorId;
  final double amount;
  final String frequency;
  final String startDate;
  final String? endDate;
  final String status;
  final String? lastFulfilledOn;
  final String? notes;
  final DateTime createdAt;
  const Pledge(
      {required this.id,
      required this.donorId,
      required this.amount,
      required this.frequency,
      required this.startDate,
      this.endDate,
      required this.status,
      this.lastFulfilledOn,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['donor_id'] = Variable<String>(donorId);
    map['amount'] = Variable<double>(amount);
    map['frequency'] = Variable<String>(frequency);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastFulfilledOn != null) {
      map['last_fulfilled_on'] = Variable<String>(lastFulfilledOn);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PledgesCompanion toCompanion(bool nullToAbsent) {
    return PledgesCompanion(
      id: Value(id),
      donorId: Value(donorId),
      amount: Value(amount),
      frequency: Value(frequency),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      status: Value(status),
      lastFulfilledOn: lastFulfilledOn == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFulfilledOn),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Pledge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pledge(
      id: serializer.fromJson<String>(json['id']),
      donorId: serializer.fromJson<String>(json['donorId']),
      amount: serializer.fromJson<double>(json['amount']),
      frequency: serializer.fromJson<String>(json['frequency']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
      lastFulfilledOn: serializer.fromJson<String?>(json['lastFulfilledOn']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'donorId': serializer.toJson<String>(donorId),
      'amount': serializer.toJson<double>(amount),
      'frequency': serializer.toJson<String>(frequency),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'status': serializer.toJson<String>(status),
      'lastFulfilledOn': serializer.toJson<String?>(lastFulfilledOn),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Pledge copyWith(
          {String? id,
          String? donorId,
          double? amount,
          String? frequency,
          String? startDate,
          Value<String?> endDate = const Value.absent(),
          String? status,
          Value<String?> lastFulfilledOn = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      Pledge(
        id: id ?? this.id,
        donorId: donorId ?? this.donorId,
        amount: amount ?? this.amount,
        frequency: frequency ?? this.frequency,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        status: status ?? this.status,
        lastFulfilledOn: lastFulfilledOn.present
            ? lastFulfilledOn.value
            : this.lastFulfilledOn,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  Pledge copyWithCompanion(PledgesCompanion data) {
    return Pledge(
      id: data.id.present ? data.id.value : this.id,
      donorId: data.donorId.present ? data.donorId.value : this.donorId,
      amount: data.amount.present ? data.amount.value : this.amount,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      lastFulfilledOn: data.lastFulfilledOn.present
          ? data.lastFulfilledOn.value
          : this.lastFulfilledOn,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pledge(')
          ..write('id: $id, ')
          ..write('donorId: $donorId, ')
          ..write('amount: $amount, ')
          ..write('frequency: $frequency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('lastFulfilledOn: $lastFulfilledOn, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, donorId, amount, frequency, startDate,
      endDate, status, lastFulfilledOn, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pledge &&
          other.id == this.id &&
          other.donorId == this.donorId &&
          other.amount == this.amount &&
          other.frequency == this.frequency &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.lastFulfilledOn == this.lastFulfilledOn &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PledgesCompanion extends UpdateCompanion<Pledge> {
  final Value<String> id;
  final Value<String> donorId;
  final Value<double> amount;
  final Value<String> frequency;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<String> status;
  final Value<String?> lastFulfilledOn;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PledgesCompanion({
    this.id = const Value.absent(),
    this.donorId = const Value.absent(),
    this.amount = const Value.absent(),
    this.frequency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.lastFulfilledOn = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PledgesCompanion.insert({
    required String id,
    required String donorId,
    required double amount,
    this.frequency = const Value.absent(),
    required String startDate,
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.lastFulfilledOn = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        donorId = Value(donorId),
        amount = Value(amount),
        startDate = Value(startDate),
        createdAt = Value(createdAt);
  static Insertable<Pledge> custom({
    Expression<String>? id,
    Expression<String>? donorId,
    Expression<double>? amount,
    Expression<String>? frequency,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? status,
    Expression<String>? lastFulfilledOn,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (donorId != null) 'donor_id': donorId,
      if (amount != null) 'amount': amount,
      if (frequency != null) 'frequency': frequency,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (lastFulfilledOn != null) 'last_fulfilled_on': lastFulfilledOn,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PledgesCompanion copyWith(
      {Value<String>? id,
      Value<String>? donorId,
      Value<double>? amount,
      Value<String>? frequency,
      Value<String>? startDate,
      Value<String?>? endDate,
      Value<String>? status,
      Value<String?>? lastFulfilledOn,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PledgesCompanion(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      lastFulfilledOn: lastFulfilledOn ?? this.lastFulfilledOn,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (donorId.present) {
      map['donor_id'] = Variable<String>(donorId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastFulfilledOn.present) {
      map['last_fulfilled_on'] = Variable<String>(lastFulfilledOn.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PledgesCompanion(')
          ..write('id: $id, ')
          ..write('donorId: $donorId, ')
          ..write('amount: $amount, ')
          ..write('frequency: $frequency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('lastFulfilledOn: $lastFulfilledOn, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CampaignsTable extends Campaigns
    with TableInfo<$CampaignsTable, Campaign> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _goalAmountMeta =
      const VerificationMeta('goalAmount');
  @override
  late final GeneratedColumn<double> goalAmount = GeneratedColumn<double>(
      'goal_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
      'end_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        goalAmount,
        startDate,
        endDate,
        status,
        createdBy,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaigns';
  @override
  VerificationContext validateIntegrity(Insertable<Campaign> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('goal_amount')) {
      context.handle(
          _goalAmountMeta,
          goalAmount.isAcceptableOrUnknown(
              data['goal_amount']!, _goalAmountMeta));
    } else if (isInserting) {
      context.missing(_goalAmountMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Campaign map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Campaign(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      goalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}goal_amount'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CampaignsTable createAlias(String alias) {
    return $CampaignsTable(attachedDatabase, alias);
  }
}

class Campaign extends DataClass implements Insertable<Campaign> {
  final String id;
  final String name;
  final String? description;
  final double goalAmount;
  final String startDate;
  final String? endDate;
  final String status;
  final String? createdBy;
  final DateTime createdAt;
  const Campaign(
      {required this.id,
      required this.name,
      this.description,
      required this.goalAmount,
      required this.startDate,
      this.endDate,
      required this.status,
      this.createdBy,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['goal_amount'] = Variable<double>(goalAmount);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CampaignsCompanion toCompanion(bool nullToAbsent) {
    return CampaignsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      goalAmount: Value(goalAmount),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      status: Value(status),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory Campaign.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Campaign(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      goalAmount: serializer.fromJson<double>(json['goalAmount']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'goalAmount': serializer.toJson<double>(goalAmount),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Campaign copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          double? goalAmount,
          String? startDate,
          Value<String?> endDate = const Value.absent(),
          String? status,
          Value<String?> createdBy = const Value.absent(),
          DateTime? createdAt}) =>
      Campaign(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        goalAmount: goalAmount ?? this.goalAmount,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        status: status ?? this.status,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        createdAt: createdAt ?? this.createdAt,
      );
  Campaign copyWithCompanion(CampaignsCompanion data) {
    return Campaign(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      goalAmount:
          data.goalAmount.present ? data.goalAmount.value : this.goalAmount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Campaign(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('goalAmount: $goalAmount, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, goalAmount, startDate,
      endDate, status, createdBy, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Campaign &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.goalAmount == this.goalAmount &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class CampaignsCompanion extends UpdateCompanion<Campaign> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> goalAmount;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<String> status;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CampaignsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.goalAmount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required double goalAmount,
    required String startDate,
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        goalAmount = Value(goalAmount),
        startDate = Value(startDate),
        createdAt = Value(createdAt);
  static Insertable<Campaign> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? goalAmount,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? status,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (goalAmount != null) 'goal_amount': goalAmount,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<double>? goalAmount,
      Value<String>? startDate,
      Value<String?>? endDate,
      Value<String>? status,
      Value<String?>? createdBy,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CampaignsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      goalAmount: goalAmount ?? this.goalAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (goalAmount.present) {
      map['goal_amount'] = Variable<double>(goalAmount.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('goalAmount: $goalAmount, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BeneficiariesTable extends Beneficiaries
    with TableInfo<$BeneficiariesTable, Beneficiary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BeneficiariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nationalIdMeta =
      const VerificationMeta('nationalId');
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
      'national_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nationalIdSearchMeta =
      const VerificationMeta('nationalIdSearch');
  @override
  late final GeneratedColumn<String> nationalIdSearch = GeneratedColumn<String>(
      'national_id_search', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _familySizeMeta =
      const VerificationMeta('familySize');
  @override
  late final GeneratedColumn<int> familySize = GeneratedColumn<int>(
      'family_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _monthlyIncomeMeta =
      const VerificationMeta('monthlyIncome');
  @override
  late final GeneratedColumn<double> monthlyIncome = GeneratedColumn<double>(
      'monthly_income', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _housingMeta =
      const VerificationMeta('housing');
  @override
  late final GeneratedColumn<String> housing = GeneratedColumn<String>(
      'housing', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _caseSummaryMeta =
      const VerificationMeta('caseSummary');
  @override
  late final GeneratedColumn<String> caseSummary = GeneratedColumn<String>(
      'case_summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _registeredByMeta =
      const VerificationMeta('registeredBy');
  @override
  late final GeneratedColumn<String> registeredBy = GeneratedColumn<String>(
      'registered_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fullName,
        nationalId,
        nationalIdSearch,
        phone,
        familySize,
        monthlyIncome,
        housing,
        caseSummary,
        status,
        registeredBy,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'beneficiaries';
  @override
  VerificationContext validateIntegrity(Insertable<Beneficiary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('national_id')) {
      context.handle(
          _nationalIdMeta,
          nationalId.isAcceptableOrUnknown(
              data['national_id']!, _nationalIdMeta));
    }
    if (data.containsKey('national_id_search')) {
      context.handle(
          _nationalIdSearchMeta,
          nationalIdSearch.isAcceptableOrUnknown(
              data['national_id_search']!, _nationalIdSearchMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('family_size')) {
      context.handle(
          _familySizeMeta,
          familySize.isAcceptableOrUnknown(
              data['family_size']!, _familySizeMeta));
    }
    if (data.containsKey('monthly_income')) {
      context.handle(
          _monthlyIncomeMeta,
          monthlyIncome.isAcceptableOrUnknown(
              data['monthly_income']!, _monthlyIncomeMeta));
    }
    if (data.containsKey('housing')) {
      context.handle(_housingMeta,
          housing.isAcceptableOrUnknown(data['housing']!, _housingMeta));
    }
    if (data.containsKey('case_summary')) {
      context.handle(
          _caseSummaryMeta,
          caseSummary.isAcceptableOrUnknown(
              data['case_summary']!, _caseSummaryMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('registered_by')) {
      context.handle(
          _registeredByMeta,
          registeredBy.isAcceptableOrUnknown(
              data['registered_by']!, _registeredByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Beneficiary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Beneficiary(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      nationalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}national_id']),
      nationalIdSearch: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}national_id_search']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      familySize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}family_size'])!,
      monthlyIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monthly_income'])!,
      housing: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}housing']),
      caseSummary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_summary']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      registeredBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}registered_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BeneficiariesTable createAlias(String alias) {
    return $BeneficiariesTable(attachedDatabase, alias);
  }
}

class Beneficiary extends DataClass implements Insertable<Beneficiary> {
  final String id;
  final String fullName;
  final String? nationalId;
  final String? nationalIdSearch;
  final String? phone;
  final int familySize;
  final double monthlyIncome;
  final String? housing;
  final String? caseSummary;
  final String status;
  final String? registeredBy;
  final DateTime createdAt;
  const Beneficiary(
      {required this.id,
      required this.fullName,
      this.nationalId,
      this.nationalIdSearch,
      this.phone,
      required this.familySize,
      required this.monthlyIncome,
      this.housing,
      this.caseSummary,
      required this.status,
      this.registeredBy,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    if (!nullToAbsent || nationalIdSearch != null) {
      map['national_id_search'] = Variable<String>(nationalIdSearch);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['family_size'] = Variable<int>(familySize);
    map['monthly_income'] = Variable<double>(monthlyIncome);
    if (!nullToAbsent || housing != null) {
      map['housing'] = Variable<String>(housing);
    }
    if (!nullToAbsent || caseSummary != null) {
      map['case_summary'] = Variable<String>(caseSummary);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || registeredBy != null) {
      map['registered_by'] = Variable<String>(registeredBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BeneficiariesCompanion toCompanion(bool nullToAbsent) {
    return BeneficiariesCompanion(
      id: Value(id),
      fullName: Value(fullName),
      nationalId: nationalId == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalId),
      nationalIdSearch: nationalIdSearch == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalIdSearch),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      familySize: Value(familySize),
      monthlyIncome: Value(monthlyIncome),
      housing: housing == null && nullToAbsent
          ? const Value.absent()
          : Value(housing),
      caseSummary: caseSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(caseSummary),
      status: Value(status),
      registeredBy: registeredBy == null && nullToAbsent
          ? const Value.absent()
          : Value(registeredBy),
      createdAt: Value(createdAt),
    );
  }

  factory Beneficiary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Beneficiary(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      nationalIdSearch: serializer.fromJson<String?>(json['nationalIdSearch']),
      phone: serializer.fromJson<String?>(json['phone']),
      familySize: serializer.fromJson<int>(json['familySize']),
      monthlyIncome: serializer.fromJson<double>(json['monthlyIncome']),
      housing: serializer.fromJson<String?>(json['housing']),
      caseSummary: serializer.fromJson<String?>(json['caseSummary']),
      status: serializer.fromJson<String>(json['status']),
      registeredBy: serializer.fromJson<String?>(json['registeredBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'nationalId': serializer.toJson<String?>(nationalId),
      'nationalIdSearch': serializer.toJson<String?>(nationalIdSearch),
      'phone': serializer.toJson<String?>(phone),
      'familySize': serializer.toJson<int>(familySize),
      'monthlyIncome': serializer.toJson<double>(monthlyIncome),
      'housing': serializer.toJson<String?>(housing),
      'caseSummary': serializer.toJson<String?>(caseSummary),
      'status': serializer.toJson<String>(status),
      'registeredBy': serializer.toJson<String?>(registeredBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Beneficiary copyWith(
          {String? id,
          String? fullName,
          Value<String?> nationalId = const Value.absent(),
          Value<String?> nationalIdSearch = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          int? familySize,
          double? monthlyIncome,
          Value<String?> housing = const Value.absent(),
          Value<String?> caseSummary = const Value.absent(),
          String? status,
          Value<String?> registeredBy = const Value.absent(),
          DateTime? createdAt}) =>
      Beneficiary(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        nationalId: nationalId.present ? nationalId.value : this.nationalId,
        nationalIdSearch: nationalIdSearch.present
            ? nationalIdSearch.value
            : this.nationalIdSearch,
        phone: phone.present ? phone.value : this.phone,
        familySize: familySize ?? this.familySize,
        monthlyIncome: monthlyIncome ?? this.monthlyIncome,
        housing: housing.present ? housing.value : this.housing,
        caseSummary: caseSummary.present ? caseSummary.value : this.caseSummary,
        status: status ?? this.status,
        registeredBy:
            registeredBy.present ? registeredBy.value : this.registeredBy,
        createdAt: createdAt ?? this.createdAt,
      );
  Beneficiary copyWithCompanion(BeneficiariesCompanion data) {
    return Beneficiary(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      nationalId:
          data.nationalId.present ? data.nationalId.value : this.nationalId,
      nationalIdSearch: data.nationalIdSearch.present
          ? data.nationalIdSearch.value
          : this.nationalIdSearch,
      phone: data.phone.present ? data.phone.value : this.phone,
      familySize:
          data.familySize.present ? data.familySize.value : this.familySize,
      monthlyIncome: data.monthlyIncome.present
          ? data.monthlyIncome.value
          : this.monthlyIncome,
      housing: data.housing.present ? data.housing.value : this.housing,
      caseSummary:
          data.caseSummary.present ? data.caseSummary.value : this.caseSummary,
      status: data.status.present ? data.status.value : this.status,
      registeredBy: data.registeredBy.present
          ? data.registeredBy.value
          : this.registeredBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Beneficiary(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('nationalId: $nationalId, ')
          ..write('nationalIdSearch: $nationalIdSearch, ')
          ..write('phone: $phone, ')
          ..write('familySize: $familySize, ')
          ..write('monthlyIncome: $monthlyIncome, ')
          ..write('housing: $housing, ')
          ..write('caseSummary: $caseSummary, ')
          ..write('status: $status, ')
          ..write('registeredBy: $registeredBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      fullName,
      nationalId,
      nationalIdSearch,
      phone,
      familySize,
      monthlyIncome,
      housing,
      caseSummary,
      status,
      registeredBy,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Beneficiary &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.nationalId == this.nationalId &&
          other.nationalIdSearch == this.nationalIdSearch &&
          other.phone == this.phone &&
          other.familySize == this.familySize &&
          other.monthlyIncome == this.monthlyIncome &&
          other.housing == this.housing &&
          other.caseSummary == this.caseSummary &&
          other.status == this.status &&
          other.registeredBy == this.registeredBy &&
          other.createdAt == this.createdAt);
}

class BeneficiariesCompanion extends UpdateCompanion<Beneficiary> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String?> nationalId;
  final Value<String?> nationalIdSearch;
  final Value<String?> phone;
  final Value<int> familySize;
  final Value<double> monthlyIncome;
  final Value<String?> housing;
  final Value<String?> caseSummary;
  final Value<String> status;
  final Value<String?> registeredBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BeneficiariesCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.nationalIdSearch = const Value.absent(),
    this.phone = const Value.absent(),
    this.familySize = const Value.absent(),
    this.monthlyIncome = const Value.absent(),
    this.housing = const Value.absent(),
    this.caseSummary = const Value.absent(),
    this.status = const Value.absent(),
    this.registeredBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BeneficiariesCompanion.insert({
    required String id,
    required String fullName,
    this.nationalId = const Value.absent(),
    this.nationalIdSearch = const Value.absent(),
    this.phone = const Value.absent(),
    this.familySize = const Value.absent(),
    this.monthlyIncome = const Value.absent(),
    this.housing = const Value.absent(),
    this.caseSummary = const Value.absent(),
    this.status = const Value.absent(),
    this.registeredBy = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fullName = Value(fullName),
        createdAt = Value(createdAt);
  static Insertable<Beneficiary> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? nationalId,
    Expression<String>? nationalIdSearch,
    Expression<String>? phone,
    Expression<int>? familySize,
    Expression<double>? monthlyIncome,
    Expression<String>? housing,
    Expression<String>? caseSummary,
    Expression<String>? status,
    Expression<String>? registeredBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (nationalId != null) 'national_id': nationalId,
      if (nationalIdSearch != null) 'national_id_search': nationalIdSearch,
      if (phone != null) 'phone': phone,
      if (familySize != null) 'family_size': familySize,
      if (monthlyIncome != null) 'monthly_income': monthlyIncome,
      if (housing != null) 'housing': housing,
      if (caseSummary != null) 'case_summary': caseSummary,
      if (status != null) 'status': status,
      if (registeredBy != null) 'registered_by': registeredBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BeneficiariesCompanion copyWith(
      {Value<String>? id,
      Value<String>? fullName,
      Value<String?>? nationalId,
      Value<String?>? nationalIdSearch,
      Value<String?>? phone,
      Value<int>? familySize,
      Value<double>? monthlyIncome,
      Value<String?>? housing,
      Value<String?>? caseSummary,
      Value<String>? status,
      Value<String?>? registeredBy,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BeneficiariesCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      nationalIdSearch: nationalIdSearch ?? this.nationalIdSearch,
      phone: phone ?? this.phone,
      familySize: familySize ?? this.familySize,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      housing: housing ?? this.housing,
      caseSummary: caseSummary ?? this.caseSummary,
      status: status ?? this.status,
      registeredBy: registeredBy ?? this.registeredBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (nationalIdSearch.present) {
      map['national_id_search'] = Variable<String>(nationalIdSearch.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (familySize.present) {
      map['family_size'] = Variable<int>(familySize.value);
    }
    if (monthlyIncome.present) {
      map['monthly_income'] = Variable<double>(monthlyIncome.value);
    }
    if (housing.present) {
      map['housing'] = Variable<String>(housing.value);
    }
    if (caseSummary.present) {
      map['case_summary'] = Variable<String>(caseSummary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (registeredBy.present) {
      map['registered_by'] = Variable<String>(registeredBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BeneficiariesCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('nationalId: $nationalId, ')
          ..write('nationalIdSearch: $nationalIdSearch, ')
          ..write('phone: $phone, ')
          ..write('familySize: $familySize, ')
          ..write('monthlyIncome: $monthlyIncome, ')
          ..write('housing: $housing, ')
          ..write('caseSummary: $caseSummary, ')
          ..write('status: $status, ')
          ..write('registeredBy: $registeredBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeriodicAidsTable extends PeriodicAids
    with TableInfo<$PeriodicAidsTable, PeriodicAid> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodicAidsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
      'beneficiary_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _monthlyAmountMeta =
      const VerificationMeta('monthlyAmount');
  @override
  late final GeneratedColumn<double> monthlyAmount = GeneratedColumn<double>(
      'monthly_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _startedOnMeta =
      const VerificationMeta('startedOn');
  @override
  late final GeneratedColumn<String> startedOn = GeneratedColumn<String>(
      'started_on', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _lastPaidPeriodMeta =
      const VerificationMeta('lastPaidPeriod');
  @override
  late final GeneratedColumn<String> lastPaidPeriod = GeneratedColumn<String>(
      'last_paid_period', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        beneficiaryId,
        monthlyAmount,
        startedOn,
        status,
        lastPaidPeriod,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'periodic_aids';
  @override
  VerificationContext validateIntegrity(Insertable<PeriodicAid> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('monthly_amount')) {
      context.handle(
          _monthlyAmountMeta,
          monthlyAmount.isAcceptableOrUnknown(
              data['monthly_amount']!, _monthlyAmountMeta));
    } else if (isInserting) {
      context.missing(_monthlyAmountMeta);
    }
    if (data.containsKey('started_on')) {
      context.handle(_startedOnMeta,
          startedOn.isAcceptableOrUnknown(data['started_on']!, _startedOnMeta));
    } else if (isInserting) {
      context.missing(_startedOnMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('last_paid_period')) {
      context.handle(
          _lastPaidPeriodMeta,
          lastPaidPeriod.isAcceptableOrUnknown(
              data['last_paid_period']!, _lastPaidPeriodMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeriodicAid map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodicAid(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}beneficiary_id'])!,
      monthlyAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monthly_amount'])!,
      startedOn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}started_on'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      lastPaidPeriod: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_paid_period']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PeriodicAidsTable createAlias(String alias) {
    return $PeriodicAidsTable(attachedDatabase, alias);
  }
}

class PeriodicAid extends DataClass implements Insertable<PeriodicAid> {
  final String id;
  final String beneficiaryId;
  final double monthlyAmount;
  final String startedOn;
  final String status;
  final String? lastPaidPeriod;
  final String? notes;
  final DateTime createdAt;
  const PeriodicAid(
      {required this.id,
      required this.beneficiaryId,
      required this.monthlyAmount,
      required this.startedOn,
      required this.status,
      this.lastPaidPeriod,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['beneficiary_id'] = Variable<String>(beneficiaryId);
    map['monthly_amount'] = Variable<double>(monthlyAmount);
    map['started_on'] = Variable<String>(startedOn);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastPaidPeriod != null) {
      map['last_paid_period'] = Variable<String>(lastPaidPeriod);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PeriodicAidsCompanion toCompanion(bool nullToAbsent) {
    return PeriodicAidsCompanion(
      id: Value(id),
      beneficiaryId: Value(beneficiaryId),
      monthlyAmount: Value(monthlyAmount),
      startedOn: Value(startedOn),
      status: Value(status),
      lastPaidPeriod: lastPaidPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPaidPeriod),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory PeriodicAid.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodicAid(
      id: serializer.fromJson<String>(json['id']),
      beneficiaryId: serializer.fromJson<String>(json['beneficiaryId']),
      monthlyAmount: serializer.fromJson<double>(json['monthlyAmount']),
      startedOn: serializer.fromJson<String>(json['startedOn']),
      status: serializer.fromJson<String>(json['status']),
      lastPaidPeriod: serializer.fromJson<String?>(json['lastPaidPeriod']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'beneficiaryId': serializer.toJson<String>(beneficiaryId),
      'monthlyAmount': serializer.toJson<double>(monthlyAmount),
      'startedOn': serializer.toJson<String>(startedOn),
      'status': serializer.toJson<String>(status),
      'lastPaidPeriod': serializer.toJson<String?>(lastPaidPeriod),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PeriodicAid copyWith(
          {String? id,
          String? beneficiaryId,
          double? monthlyAmount,
          String? startedOn,
          String? status,
          Value<String?> lastPaidPeriod = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      PeriodicAid(
        id: id ?? this.id,
        beneficiaryId: beneficiaryId ?? this.beneficiaryId,
        monthlyAmount: monthlyAmount ?? this.monthlyAmount,
        startedOn: startedOn ?? this.startedOn,
        status: status ?? this.status,
        lastPaidPeriod:
            lastPaidPeriod.present ? lastPaidPeriod.value : this.lastPaidPeriod,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  PeriodicAid copyWithCompanion(PeriodicAidsCompanion data) {
    return PeriodicAid(
      id: data.id.present ? data.id.value : this.id,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      monthlyAmount: data.monthlyAmount.present
          ? data.monthlyAmount.value
          : this.monthlyAmount,
      startedOn: data.startedOn.present ? data.startedOn.value : this.startedOn,
      status: data.status.present ? data.status.value : this.status,
      lastPaidPeriod: data.lastPaidPeriod.present
          ? data.lastPaidPeriod.value
          : this.lastPaidPeriod,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodicAid(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('monthlyAmount: $monthlyAmount, ')
          ..write('startedOn: $startedOn, ')
          ..write('status: $status, ')
          ..write('lastPaidPeriod: $lastPaidPeriod, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, beneficiaryId, monthlyAmount, startedOn,
      status, lastPaidPeriod, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodicAid &&
          other.id == this.id &&
          other.beneficiaryId == this.beneficiaryId &&
          other.monthlyAmount == this.monthlyAmount &&
          other.startedOn == this.startedOn &&
          other.status == this.status &&
          other.lastPaidPeriod == this.lastPaidPeriod &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PeriodicAidsCompanion extends UpdateCompanion<PeriodicAid> {
  final Value<String> id;
  final Value<String> beneficiaryId;
  final Value<double> monthlyAmount;
  final Value<String> startedOn;
  final Value<String> status;
  final Value<String?> lastPaidPeriod;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PeriodicAidsCompanion({
    this.id = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.monthlyAmount = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.status = const Value.absent(),
    this.lastPaidPeriod = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeriodicAidsCompanion.insert({
    required String id,
    required String beneficiaryId,
    required double monthlyAmount,
    required String startedOn,
    this.status = const Value.absent(),
    this.lastPaidPeriod = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        beneficiaryId = Value(beneficiaryId),
        monthlyAmount = Value(monthlyAmount),
        startedOn = Value(startedOn),
        createdAt = Value(createdAt);
  static Insertable<PeriodicAid> custom({
    Expression<String>? id,
    Expression<String>? beneficiaryId,
    Expression<double>? monthlyAmount,
    Expression<String>? startedOn,
    Expression<String>? status,
    Expression<String>? lastPaidPeriod,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (monthlyAmount != null) 'monthly_amount': monthlyAmount,
      if (startedOn != null) 'started_on': startedOn,
      if (status != null) 'status': status,
      if (lastPaidPeriod != null) 'last_paid_period': lastPaidPeriod,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeriodicAidsCompanion copyWith(
      {Value<String>? id,
      Value<String>? beneficiaryId,
      Value<double>? monthlyAmount,
      Value<String>? startedOn,
      Value<String>? status,
      Value<String?>? lastPaidPeriod,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PeriodicAidsCompanion(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      startedOn: startedOn ?? this.startedOn,
      status: status ?? this.status,
      lastPaidPeriod: lastPaidPeriod ?? this.lastPaidPeriod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId.value);
    }
    if (monthlyAmount.present) {
      map['monthly_amount'] = Variable<double>(monthlyAmount.value);
    }
    if (startedOn.present) {
      map['started_on'] = Variable<String>(startedOn.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastPaidPeriod.present) {
      map['last_paid_period'] = Variable<String>(lastPaidPeriod.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodicAidsCompanion(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('monthlyAmount: $monthlyAmount, ')
          ..write('startedOn: $startedOn, ')
          ..write('status: $status, ')
          ..write('lastPaidPeriod: $lastPaidPeriod, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InKindItemsTable extends InKindItems
    with TableInfo<$InKindItemsTable, InKindItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InKindItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('قطعة'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reorderLevelMeta =
      const VerificationMeta('reorderLevel');
  @override
  late final GeneratedColumn<double> reorderLevel = GeneratedColumn<double>(
      'reorder_level', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, unit, quantity, reorderLevel, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'in_kind_items';
  @override
  VerificationContext validateIntegrity(Insertable<InKindItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
          _reorderLevelMeta,
          reorderLevel.isAcceptableOrUnknown(
              data['reorder_level']!, _reorderLevelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InKindItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InKindItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      reorderLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}reorder_level'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InKindItemsTable createAlias(String alias) {
    return $InKindItemsTable(attachedDatabase, alias);
  }
}

class InKindItem extends DataClass implements Insertable<InKindItem> {
  final String id;
  final String name;
  final String unit;
  final double quantity;
  final double reorderLevel;
  final DateTime createdAt;
  const InKindItem(
      {required this.id,
      required this.name,
      required this.unit,
      required this.quantity,
      required this.reorderLevel,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['quantity'] = Variable<double>(quantity);
    map['reorder_level'] = Variable<double>(reorderLevel);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InKindItemsCompanion toCompanion(bool nullToAbsent) {
    return InKindItemsCompanion(
      id: Value(id),
      name: Value(name),
      unit: Value(unit),
      quantity: Value(quantity),
      reorderLevel: Value(reorderLevel),
      createdAt: Value(createdAt),
    );
  }

  factory InKindItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InKindItem(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      quantity: serializer.fromJson<double>(json['quantity']),
      reorderLevel: serializer.fromJson<double>(json['reorderLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'quantity': serializer.toJson<double>(quantity),
      'reorderLevel': serializer.toJson<double>(reorderLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InKindItem copyWith(
          {String? id,
          String? name,
          String? unit,
          double? quantity,
          double? reorderLevel,
          DateTime? createdAt}) =>
      InKindItem(
        id: id ?? this.id,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        quantity: quantity ?? this.quantity,
        reorderLevel: reorderLevel ?? this.reorderLevel,
        createdAt: createdAt ?? this.createdAt,
      );
  InKindItem copyWithCompanion(InKindItemsCompanion data) {
    return InKindItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InKindItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, unit, quantity, reorderLevel, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InKindItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.quantity == this.quantity &&
          other.reorderLevel == this.reorderLevel &&
          other.createdAt == this.createdAt);
}

class InKindItemsCompanion extends UpdateCompanion<InKindItem> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> unit;
  final Value<double> quantity;
  final Value<double> reorderLevel;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InKindItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InKindItemsCompanion.insert({
    required String id,
    required String name,
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<InKindItem> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<double>? quantity,
    Expression<double>? reorderLevel,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (quantity != null) 'quantity': quantity,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InKindItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? unit,
      Value<double>? quantity,
      Value<double>? reorderLevel,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return InKindItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<double>(reorderLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InKindItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InKindMovementsTable extends InKindMovements
    with TableInfo<$InKindMovementsTable, InKindMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InKindMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _movementDateMeta =
      const VerificationMeta('movementDate');
  @override
  late final GeneratedColumn<String> movementDate = GeneratedColumn<String>(
      'movement_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
      'beneficiary_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aidIdMeta = const VerificationMeta('aidId');
  @override
  late final GeneratedColumn<String> aidId = GeneratedColumn<String>(
      'aid_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _campaignIdMeta =
      const VerificationMeta('campaignId');
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
      'campaign_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _byUserIdMeta =
      const VerificationMeta('byUserId');
  @override
  late final GeneratedColumn<String> byUserId = GeneratedColumn<String>(
      'by_user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        direction,
        quantity,
        movementDate,
        beneficiaryId,
        aidId,
        campaignId,
        note,
        byUserId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'in_kind_movements';
  @override
  VerificationContext validateIntegrity(Insertable<InKindMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('movement_date')) {
      context.handle(
          _movementDateMeta,
          movementDate.isAcceptableOrUnknown(
              data['movement_date']!, _movementDateMeta));
    } else if (isInserting) {
      context.missing(_movementDateMeta);
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    }
    if (data.containsKey('aid_id')) {
      context.handle(
          _aidIdMeta, aidId.isAcceptableOrUnknown(data['aid_id']!, _aidIdMeta));
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
          _campaignIdMeta,
          campaignId.isAcceptableOrUnknown(
              data['campaign_id']!, _campaignIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('by_user_id')) {
      context.handle(_byUserIdMeta,
          byUserId.isAcceptableOrUnknown(data['by_user_id']!, _byUserIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InKindMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InKindMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      movementDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}movement_date'])!,
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}beneficiary_id']),
      aidId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aid_id']),
      campaignId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}campaign_id']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      byUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}by_user_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InKindMovementsTable createAlias(String alias) {
    return $InKindMovementsTable(attachedDatabase, alias);
  }
}

class InKindMovement extends DataClass implements Insertable<InKindMovement> {
  final String id;
  final String itemId;
  final String direction;
  final double quantity;
  final String movementDate;
  final String? beneficiaryId;
  final String? aidId;
  final String? campaignId;
  final String? note;
  final String? byUserId;
  final DateTime createdAt;
  const InKindMovement(
      {required this.id,
      required this.itemId,
      required this.direction,
      required this.quantity,
      required this.movementDate,
      this.beneficiaryId,
      this.aidId,
      this.campaignId,
      this.note,
      this.byUserId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['direction'] = Variable<String>(direction);
    map['quantity'] = Variable<double>(quantity);
    map['movement_date'] = Variable<String>(movementDate);
    if (!nullToAbsent || beneficiaryId != null) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId);
    }
    if (!nullToAbsent || aidId != null) {
      map['aid_id'] = Variable<String>(aidId);
    }
    if (!nullToAbsent || campaignId != null) {
      map['campaign_id'] = Variable<String>(campaignId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || byUserId != null) {
      map['by_user_id'] = Variable<String>(byUserId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InKindMovementsCompanion toCompanion(bool nullToAbsent) {
    return InKindMovementsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      direction: Value(direction),
      quantity: Value(quantity),
      movementDate: Value(movementDate),
      beneficiaryId: beneficiaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(beneficiaryId),
      aidId:
          aidId == null && nullToAbsent ? const Value.absent() : Value(aidId),
      campaignId: campaignId == null && nullToAbsent
          ? const Value.absent()
          : Value(campaignId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      byUserId: byUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(byUserId),
      createdAt: Value(createdAt),
    );
  }

  factory InKindMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InKindMovement(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      direction: serializer.fromJson<String>(json['direction']),
      quantity: serializer.fromJson<double>(json['quantity']),
      movementDate: serializer.fromJson<String>(json['movementDate']),
      beneficiaryId: serializer.fromJson<String?>(json['beneficiaryId']),
      aidId: serializer.fromJson<String?>(json['aidId']),
      campaignId: serializer.fromJson<String?>(json['campaignId']),
      note: serializer.fromJson<String?>(json['note']),
      byUserId: serializer.fromJson<String?>(json['byUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'direction': serializer.toJson<String>(direction),
      'quantity': serializer.toJson<double>(quantity),
      'movementDate': serializer.toJson<String>(movementDate),
      'beneficiaryId': serializer.toJson<String?>(beneficiaryId),
      'aidId': serializer.toJson<String?>(aidId),
      'campaignId': serializer.toJson<String?>(campaignId),
      'note': serializer.toJson<String?>(note),
      'byUserId': serializer.toJson<String?>(byUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InKindMovement copyWith(
          {String? id,
          String? itemId,
          String? direction,
          double? quantity,
          String? movementDate,
          Value<String?> beneficiaryId = const Value.absent(),
          Value<String?> aidId = const Value.absent(),
          Value<String?> campaignId = const Value.absent(),
          Value<String?> note = const Value.absent(),
          Value<String?> byUserId = const Value.absent(),
          DateTime? createdAt}) =>
      InKindMovement(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        direction: direction ?? this.direction,
        quantity: quantity ?? this.quantity,
        movementDate: movementDate ?? this.movementDate,
        beneficiaryId:
            beneficiaryId.present ? beneficiaryId.value : this.beneficiaryId,
        aidId: aidId.present ? aidId.value : this.aidId,
        campaignId: campaignId.present ? campaignId.value : this.campaignId,
        note: note.present ? note.value : this.note,
        byUserId: byUserId.present ? byUserId.value : this.byUserId,
        createdAt: createdAt ?? this.createdAt,
      );
  InKindMovement copyWithCompanion(InKindMovementsCompanion data) {
    return InKindMovement(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      direction: data.direction.present ? data.direction.value : this.direction,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      movementDate: data.movementDate.present
          ? data.movementDate.value
          : this.movementDate,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      aidId: data.aidId.present ? data.aidId.value : this.aidId,
      campaignId:
          data.campaignId.present ? data.campaignId.value : this.campaignId,
      note: data.note.present ? data.note.value : this.note,
      byUserId: data.byUserId.present ? data.byUserId.value : this.byUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InKindMovement(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('direction: $direction, ')
          ..write('quantity: $quantity, ')
          ..write('movementDate: $movementDate, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('aidId: $aidId, ')
          ..write('campaignId: $campaignId, ')
          ..write('note: $note, ')
          ..write('byUserId: $byUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, direction, quantity, movementDate,
      beneficiaryId, aidId, campaignId, note, byUserId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InKindMovement &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.direction == this.direction &&
          other.quantity == this.quantity &&
          other.movementDate == this.movementDate &&
          other.beneficiaryId == this.beneficiaryId &&
          other.aidId == this.aidId &&
          other.campaignId == this.campaignId &&
          other.note == this.note &&
          other.byUserId == this.byUserId &&
          other.createdAt == this.createdAt);
}

class InKindMovementsCompanion extends UpdateCompanion<InKindMovement> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> direction;
  final Value<double> quantity;
  final Value<String> movementDate;
  final Value<String?> beneficiaryId;
  final Value<String?> aidId;
  final Value<String?> campaignId;
  final Value<String?> note;
  final Value<String?> byUserId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InKindMovementsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.direction = const Value.absent(),
    this.quantity = const Value.absent(),
    this.movementDate = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.aidId = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.note = const Value.absent(),
    this.byUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InKindMovementsCompanion.insert({
    required String id,
    required String itemId,
    required String direction,
    required double quantity,
    required String movementDate,
    this.beneficiaryId = const Value.absent(),
    this.aidId = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.note = const Value.absent(),
    this.byUserId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        direction = Value(direction),
        quantity = Value(quantity),
        movementDate = Value(movementDate),
        createdAt = Value(createdAt);
  static Insertable<InKindMovement> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? direction,
    Expression<double>? quantity,
    Expression<String>? movementDate,
    Expression<String>? beneficiaryId,
    Expression<String>? aidId,
    Expression<String>? campaignId,
    Expression<String>? note,
    Expression<String>? byUserId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (direction != null) 'direction': direction,
      if (quantity != null) 'quantity': quantity,
      if (movementDate != null) 'movement_date': movementDate,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (aidId != null) 'aid_id': aidId,
      if (campaignId != null) 'campaign_id': campaignId,
      if (note != null) 'note': note,
      if (byUserId != null) 'by_user_id': byUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InKindMovementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String>? direction,
      Value<double>? quantity,
      Value<String>? movementDate,
      Value<String?>? beneficiaryId,
      Value<String?>? aidId,
      Value<String?>? campaignId,
      Value<String?>? note,
      Value<String?>? byUserId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return InKindMovementsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      direction: direction ?? this.direction,
      quantity: quantity ?? this.quantity,
      movementDate: movementDate ?? this.movementDate,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      aidId: aidId ?? this.aidId,
      campaignId: campaignId ?? this.campaignId,
      note: note ?? this.note,
      byUserId: byUserId ?? this.byUserId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (movementDate.present) {
      map['movement_date'] = Variable<String>(movementDate.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId.value);
    }
    if (aidId.present) {
      map['aid_id'] = Variable<String>(aidId.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (byUserId.present) {
      map['by_user_id'] = Variable<String>(byUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InKindMovementsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('direction: $direction, ')
          ..write('quantity: $quantity, ')
          ..write('movementDate: $movementDate, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('aidId: $aidId, ')
          ..write('campaignId: $campaignId, ')
          ..write('note: $note, ')
          ..write('byUserId: $byUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plannedAmountMeta =
      const VerificationMeta('plannedAmount');
  @override
  late final GeneratedColumn<double> plannedAmount = GeneratedColumn<double>(
      'planned_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, period, accountId, plannedAmount, createdBy, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<Budget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('planned_amount')) {
      context.handle(
          _plannedAmountMeta,
          plannedAmount.isAcceptableOrUnknown(
              data['planned_amount']!, _plannedAmountMeta));
    } else if (isInserting) {
      context.missing(_plannedAmountMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      plannedAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}planned_amount'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String period;
  final String accountId;
  final double plannedAmount;
  final String? createdBy;
  final DateTime createdAt;
  const Budget(
      {required this.id,
      required this.period,
      required this.accountId,
      required this.plannedAmount,
      this.createdBy,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['period'] = Variable<String>(period);
    map['account_id'] = Variable<String>(accountId);
    map['planned_amount'] = Variable<double>(plannedAmount);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      period: Value(period),
      accountId: Value(accountId),
      plannedAmount: Value(plannedAmount),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      period: serializer.fromJson<String>(json['period']),
      accountId: serializer.fromJson<String>(json['accountId']),
      plannedAmount: serializer.fromJson<double>(json['plannedAmount']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'period': serializer.toJson<String>(period),
      'accountId': serializer.toJson<String>(accountId),
      'plannedAmount': serializer.toJson<double>(plannedAmount),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Budget copyWith(
          {String? id,
          String? period,
          String? accountId,
          double? plannedAmount,
          Value<String?> createdBy = const Value.absent(),
          DateTime? createdAt}) =>
      Budget(
        id: id ?? this.id,
        period: period ?? this.period,
        accountId: accountId ?? this.accountId,
        plannedAmount: plannedAmount ?? this.plannedAmount,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        createdAt: createdAt ?? this.createdAt,
      );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      period: data.period.present ? data.period.value : this.period,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      plannedAmount: data.plannedAmount.present
          ? data.plannedAmount.value
          : this.plannedAmount,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('period: $period, ')
          ..write('accountId: $accountId, ')
          ..write('plannedAmount: $plannedAmount, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, period, accountId, plannedAmount, createdBy, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.period == this.period &&
          other.accountId == this.accountId &&
          other.plannedAmount == this.plannedAmount &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> period;
  final Value<String> accountId;
  final Value<double> plannedAmount;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.period = const Value.absent(),
    this.accountId = const Value.absent(),
    this.plannedAmount = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String period,
    required String accountId,
    required double plannedAmount,
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        period = Value(period),
        accountId = Value(accountId),
        plannedAmount = Value(plannedAmount),
        createdAt = Value(createdAt);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? period,
    Expression<String>? accountId,
    Expression<double>? plannedAmount,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (period != null) 'period': period,
      if (accountId != null) 'account_id': accountId,
      if (plannedAmount != null) 'planned_amount': plannedAmount,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? period,
      Value<String>? accountId,
      Value<double>? plannedAmount,
      Value<String?>? createdBy,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      period: period ?? this.period,
      accountId: accountId ?? this.accountId,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (plannedAmount.present) {
      map['planned_amount'] = Variable<double>(plannedAmount.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('period: $period, ')
          ..write('accountId: $accountId, ')
          ..write('plannedAmount: $plannedAmount, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OtpCodesTable extends OtpCodes with TableInfo<$OtpCodesTable, OtpCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OtpCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeHashMeta =
      const VerificationMeta('codeHash');
  @override
  late final GeneratedColumn<String> codeHash = GeneratedColumn<String>(
      'code_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _consumedMeta =
      const VerificationMeta('consumed');
  @override
  late final GeneratedColumn<bool> consumed = GeneratedColumn<bool>(
      'consumed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("consumed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, token, userId, codeHash, expiresAt, consumed, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'otp_codes';
  @override
  VerificationContext validateIntegrity(Insertable<OtpCode> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('code_hash')) {
      context.handle(_codeHashMeta,
          codeHash.isAcceptableOrUnknown(data['code_hash']!, _codeHashMeta));
    } else if (isInserting) {
      context.missing(_codeHashMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('consumed')) {
      context.handle(_consumedMeta,
          consumed.isAcceptableOrUnknown(data['consumed']!, _consumedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OtpCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OtpCode(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      codeHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code_hash'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
      consumed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}consumed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OtpCodesTable createAlias(String alias) {
    return $OtpCodesTable(attachedDatabase, alias);
  }
}

class OtpCode extends DataClass implements Insertable<OtpCode> {
  final String id;
  final String token;
  final String userId;
  final String codeHash;
  final DateTime expiresAt;
  final bool consumed;
  final DateTime createdAt;
  const OtpCode(
      {required this.id,
      required this.token,
      required this.userId,
      required this.codeHash,
      required this.expiresAt,
      required this.consumed,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['token'] = Variable<String>(token);
    map['user_id'] = Variable<String>(userId);
    map['code_hash'] = Variable<String>(codeHash);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['consumed'] = Variable<bool>(consumed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OtpCodesCompanion toCompanion(bool nullToAbsent) {
    return OtpCodesCompanion(
      id: Value(id),
      token: Value(token),
      userId: Value(userId),
      codeHash: Value(codeHash),
      expiresAt: Value(expiresAt),
      consumed: Value(consumed),
      createdAt: Value(createdAt),
    );
  }

  factory OtpCode.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OtpCode(
      id: serializer.fromJson<String>(json['id']),
      token: serializer.fromJson<String>(json['token']),
      userId: serializer.fromJson<String>(json['userId']),
      codeHash: serializer.fromJson<String>(json['codeHash']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      consumed: serializer.fromJson<bool>(json['consumed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'token': serializer.toJson<String>(token),
      'userId': serializer.toJson<String>(userId),
      'codeHash': serializer.toJson<String>(codeHash),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'consumed': serializer.toJson<bool>(consumed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OtpCode copyWith(
          {String? id,
          String? token,
          String? userId,
          String? codeHash,
          DateTime? expiresAt,
          bool? consumed,
          DateTime? createdAt}) =>
      OtpCode(
        id: id ?? this.id,
        token: token ?? this.token,
        userId: userId ?? this.userId,
        codeHash: codeHash ?? this.codeHash,
        expiresAt: expiresAt ?? this.expiresAt,
        consumed: consumed ?? this.consumed,
        createdAt: createdAt ?? this.createdAt,
      );
  OtpCode copyWithCompanion(OtpCodesCompanion data) {
    return OtpCode(
      id: data.id.present ? data.id.value : this.id,
      token: data.token.present ? data.token.value : this.token,
      userId: data.userId.present ? data.userId.value : this.userId,
      codeHash: data.codeHash.present ? data.codeHash.value : this.codeHash,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      consumed: data.consumed.present ? data.consumed.value : this.consumed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OtpCode(')
          ..write('id: $id, ')
          ..write('token: $token, ')
          ..write('userId: $userId, ')
          ..write('codeHash: $codeHash, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('consumed: $consumed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, token, userId, codeHash, expiresAt, consumed, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OtpCode &&
          other.id == this.id &&
          other.token == this.token &&
          other.userId == this.userId &&
          other.codeHash == this.codeHash &&
          other.expiresAt == this.expiresAt &&
          other.consumed == this.consumed &&
          other.createdAt == this.createdAt);
}

class OtpCodesCompanion extends UpdateCompanion<OtpCode> {
  final Value<String> id;
  final Value<String> token;
  final Value<String> userId;
  final Value<String> codeHash;
  final Value<DateTime> expiresAt;
  final Value<bool> consumed;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OtpCodesCompanion({
    this.id = const Value.absent(),
    this.token = const Value.absent(),
    this.userId = const Value.absent(),
    this.codeHash = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.consumed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OtpCodesCompanion.insert({
    required String id,
    required String token,
    required String userId,
    required String codeHash,
    required DateTime expiresAt,
    this.consumed = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        token = Value(token),
        userId = Value(userId),
        codeHash = Value(codeHash),
        expiresAt = Value(expiresAt),
        createdAt = Value(createdAt);
  static Insertable<OtpCode> custom({
    Expression<String>? id,
    Expression<String>? token,
    Expression<String>? userId,
    Expression<String>? codeHash,
    Expression<DateTime>? expiresAt,
    Expression<bool>? consumed,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      if (userId != null) 'user_id': userId,
      if (codeHash != null) 'code_hash': codeHash,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (consumed != null) 'consumed': consumed,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OtpCodesCompanion copyWith(
      {Value<String>? id,
      Value<String>? token,
      Value<String>? userId,
      Value<String>? codeHash,
      Value<DateTime>? expiresAt,
      Value<bool>? consumed,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return OtpCodesCompanion(
      id: id ?? this.id,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      codeHash: codeHash ?? this.codeHash,
      expiresAt: expiresAt ?? this.expiresAt,
      consumed: consumed ?? this.consumed,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (codeHash.present) {
      map['code_hash'] = Variable<String>(codeHash.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (consumed.present) {
      map['consumed'] = Variable<bool>(consumed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OtpCodesCompanion(')
          ..write('id: $id, ')
          ..write('token: $token, ')
          ..write('userId: $userId, ')
          ..write('codeHash: $codeHash, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('consumed: $consumed, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefreshSessionsTable extends RefreshSessions
    with TableInfo<$RefreshSessionsTable, RefreshSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefreshSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tokenHashMeta =
      const VerificationMeta('tokenHash');
  @override
  late final GeneratedColumn<String> tokenHash = GeneratedColumn<String>(
      'token_hash', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ipAddressMeta =
      const VerificationMeta('ipAddress');
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
      'ip_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _revokedMeta =
      const VerificationMeta('revoked');
  @override
  late final GeneratedColumn<bool> revoked = GeneratedColumn<bool>(
      'revoked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("revoked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        tokenHash,
        deviceId,
        ipAddress,
        expiresAt,
        revoked,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'refresh_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<RefreshSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('token_hash')) {
      context.handle(_tokenHashMeta,
          tokenHash.isAcceptableOrUnknown(data['token_hash']!, _tokenHashMeta));
    } else if (isInserting) {
      context.missing(_tokenHashMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('ip_address')) {
      context.handle(_ipAddressMeta,
          ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('revoked')) {
      context.handle(_revokedMeta,
          revoked.isAcceptableOrUnknown(data['revoked']!, _revokedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RefreshSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefreshSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      tokenHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token_hash'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      ipAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ip_address']),
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
      revoked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}revoked'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RefreshSessionsTable createAlias(String alias) {
    return $RefreshSessionsTable(attachedDatabase, alias);
  }
}

class RefreshSession extends DataClass implements Insertable<RefreshSession> {
  final String id;
  final String userId;
  final String tokenHash;
  final String? deviceId;
  final String? ipAddress;
  final DateTime expiresAt;
  final bool revoked;
  final DateTime createdAt;
  const RefreshSession(
      {required this.id,
      required this.userId,
      required this.tokenHash,
      this.deviceId,
      this.ipAddress,
      required this.expiresAt,
      required this.revoked,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['token_hash'] = Variable<String>(tokenHash);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || ipAddress != null) {
      map['ip_address'] = Variable<String>(ipAddress);
    }
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['revoked'] = Variable<bool>(revoked);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RefreshSessionsCompanion toCompanion(bool nullToAbsent) {
    return RefreshSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      tokenHash: Value(tokenHash),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      ipAddress: ipAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(ipAddress),
      expiresAt: Value(expiresAt),
      revoked: Value(revoked),
      createdAt: Value(createdAt),
    );
  }

  factory RefreshSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefreshSession(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      tokenHash: serializer.fromJson<String>(json['tokenHash']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      ipAddress: serializer.fromJson<String?>(json['ipAddress']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      revoked: serializer.fromJson<bool>(json['revoked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'tokenHash': serializer.toJson<String>(tokenHash),
      'deviceId': serializer.toJson<String?>(deviceId),
      'ipAddress': serializer.toJson<String?>(ipAddress),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'revoked': serializer.toJson<bool>(revoked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RefreshSession copyWith(
          {String? id,
          String? userId,
          String? tokenHash,
          Value<String?> deviceId = const Value.absent(),
          Value<String?> ipAddress = const Value.absent(),
          DateTime? expiresAt,
          bool? revoked,
          DateTime? createdAt}) =>
      RefreshSession(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        tokenHash: tokenHash ?? this.tokenHash,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        ipAddress: ipAddress.present ? ipAddress.value : this.ipAddress,
        expiresAt: expiresAt ?? this.expiresAt,
        revoked: revoked ?? this.revoked,
        createdAt: createdAt ?? this.createdAt,
      );
  RefreshSession copyWithCompanion(RefreshSessionsCompanion data) {
    return RefreshSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      tokenHash: data.tokenHash.present ? data.tokenHash.value : this.tokenHash,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      revoked: data.revoked.present ? data.revoked.value : this.revoked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefreshSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('deviceId: $deviceId, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('revoked: $revoked, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, tokenHash, deviceId, ipAddress,
      expiresAt, revoked, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefreshSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.tokenHash == this.tokenHash &&
          other.deviceId == this.deviceId &&
          other.ipAddress == this.ipAddress &&
          other.expiresAt == this.expiresAt &&
          other.revoked == this.revoked &&
          other.createdAt == this.createdAt);
}

class RefreshSessionsCompanion extends UpdateCompanion<RefreshSession> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> tokenHash;
  final Value<String?> deviceId;
  final Value<String?> ipAddress;
  final Value<DateTime> expiresAt;
  final Value<bool> revoked;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RefreshSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.tokenHash = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.revoked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefreshSessionsCompanion.insert({
    required String id,
    required String userId,
    required String tokenHash,
    this.deviceId = const Value.absent(),
    this.ipAddress = const Value.absent(),
    required DateTime expiresAt,
    this.revoked = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        tokenHash = Value(tokenHash),
        expiresAt = Value(expiresAt),
        createdAt = Value(createdAt);
  static Insertable<RefreshSession> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? tokenHash,
    Expression<String>? deviceId,
    Expression<String>? ipAddress,
    Expression<DateTime>? expiresAt,
    Expression<bool>? revoked,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (tokenHash != null) 'token_hash': tokenHash,
      if (deviceId != null) 'device_id': deviceId,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (revoked != null) 'revoked': revoked,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefreshSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? tokenHash,
      Value<String?>? deviceId,
      Value<String?>? ipAddress,
      Value<DateTime>? expiresAt,
      Value<bool>? revoked,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RefreshSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tokenHash: tokenHash ?? this.tokenHash,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      expiresAt: expiresAt ?? this.expiresAt,
      revoked: revoked ?? this.revoked,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (tokenHash.present) {
      map['token_hash'] = Variable<String>(tokenHash.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (revoked.present) {
      map['revoked'] = Variable<bool>(revoked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefreshSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('deviceId: $deviceId, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('revoked: $revoked, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceTokensTable extends DeviceTokens
    with TableInfo<$DeviceTokensTable, DeviceToken> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceTokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUsedAtMeta =
      const VerificationMeta('lastUsedAt');
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
      'last_used_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, token, platform, createdAt, lastUsedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_tokens';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceToken> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
          _lastUsedAtMeta,
          lastUsedAt.isAcceptableOrUnknown(
              data['last_used_at']!, _lastUsedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceToken map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceToken(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUsedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used_at'])!,
    );
  }

  @override
  $DeviceTokensTable createAlias(String alias) {
    return $DeviceTokensTable(attachedDatabase, alias);
  }
}

class DeviceToken extends DataClass implements Insertable<DeviceToken> {
  final String id;
  final String userId;
  final String token;
  final String? platform;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  const DeviceToken(
      {required this.id,
      required this.userId,
      required this.token,
      this.platform,
      required this.createdAt,
      required this.lastUsedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['token'] = Variable<String>(token);
    if (!nullToAbsent || platform != null) {
      map['platform'] = Variable<String>(platform);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    return map;
  }

  DeviceTokensCompanion toCompanion(bool nullToAbsent) {
    return DeviceTokensCompanion(
      id: Value(id),
      userId: Value(userId),
      token: Value(token),
      platform: platform == null && nullToAbsent
          ? const Value.absent()
          : Value(platform),
      createdAt: Value(createdAt),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory DeviceToken.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceToken(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      token: serializer.fromJson<String>(json['token']),
      platform: serializer.fromJson<String?>(json['platform']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'token': serializer.toJson<String>(token),
      'platform': serializer.toJson<String?>(platform),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
    };
  }

  DeviceToken copyWith(
          {String? id,
          String? userId,
          String? token,
          Value<String?> platform = const Value.absent(),
          DateTime? createdAt,
          DateTime? lastUsedAt}) =>
      DeviceToken(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        token: token ?? this.token,
        platform: platform.present ? platform.value : this.platform,
        createdAt: createdAt ?? this.createdAt,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      );
  DeviceToken copyWithCompanion(DeviceTokensCompanion data) {
    return DeviceToken(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      token: data.token.present ? data.token.value : this.token,
      platform: data.platform.present ? data.platform.value : this.platform,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt:
          data.lastUsedAt.present ? data.lastUsedAt.value : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceToken(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('token: $token, ')
          ..write('platform: $platform, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, token, platform, createdAt, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceToken &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.token == this.token &&
          other.platform == this.platform &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class DeviceTokensCompanion extends UpdateCompanion<DeviceToken> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> token;
  final Value<String?> platform;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUsedAt;
  final Value<int> rowid;
  const DeviceTokensCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.token = const Value.absent(),
    this.platform = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceTokensCompanion.insert({
    required String id,
    required String userId,
    required String token,
    this.platform = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastUsedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        token = Value(token),
        createdAt = Value(createdAt),
        lastUsedAt = Value(lastUsedAt);
  static Insertable<DeviceToken> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? token,
    Expression<String>? platform,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (token != null) 'token': token,
      if (platform != null) 'platform': platform,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceTokensCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? token,
      Value<String?>? platform,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUsedAt,
      Value<int>? rowid}) {
    return DeviceTokensCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceTokensCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('token: $token, ')
          ..write('platform: $platform, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userNameMeta =
      const VerificationMeta('userName');
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
      'user_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resourceTypeMeta =
      const VerificationMeta('resourceType');
  @override
  late final GeneratedColumn<String> resourceType = GeneratedColumn<String>(
      'resource_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resourceIdMeta =
      const VerificationMeta('resourceId');
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
      'resource_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _changesMeta =
      const VerificationMeta('changes');
  @override
  late final GeneratedColumn<String> changes = GeneratedColumn<String>(
      'changes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ipAddressMeta =
      const VerificationMeta('ipAddress');
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
      'ip_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        timestamp,
        userId,
        userName,
        action,
        resourceType,
        resourceId,
        summary,
        changes,
        ipAddress,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('user_name')) {
      context.handle(_userNameMeta,
          userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta));
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('resource_type')) {
      context.handle(
          _resourceTypeMeta,
          resourceType.isAcceptableOrUnknown(
              data['resource_type']!, _resourceTypeMeta));
    } else if (isInserting) {
      context.missing(_resourceTypeMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
          _resourceIdMeta,
          resourceId.isAcceptableOrUnknown(
              data['resource_id']!, _resourceIdMeta));
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('changes')) {
      context.handle(_changesMeta,
          changes.isAcceptableOrUnknown(data['changes']!, _changesMeta));
    }
    if (data.containsKey('ip_address')) {
      context.handle(_ipAddressMeta,
          ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      userName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_name']),
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      resourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resource_type'])!,
      resourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resource_id']),
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary']),
      changes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changes']),
      ipAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ip_address']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final DateTime timestamp;
  final String? userId;
  final String? userName;
  final String action;
  final String resourceType;
  final String? resourceId;
  final String? summary;
  final String? changes;
  final String? ipAddress;
  final String? deviceId;
  const AuditLog(
      {required this.id,
      required this.timestamp,
      this.userId,
      this.userName,
      required this.action,
      required this.resourceType,
      this.resourceId,
      this.summary,
      this.changes,
      this.ipAddress,
      this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    map['action'] = Variable<String>(action);
    map['resource_type'] = Variable<String>(resourceType);
    if (!nullToAbsent || resourceId != null) {
      map['resource_id'] = Variable<String>(resourceId);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || changes != null) {
      map['changes'] = Variable<String>(changes);
    }
    if (!nullToAbsent || ipAddress != null) {
      map['ip_address'] = Variable<String>(ipAddress);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
      action: Value(action),
      resourceType: Value(resourceType),
      resourceId: resourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceId),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      changes: changes == null && nullToAbsent
          ? const Value.absent()
          : Value(changes),
      ipAddress: ipAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(ipAddress),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory AuditLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      userId: serializer.fromJson<String?>(json['userId']),
      userName: serializer.fromJson<String?>(json['userName']),
      action: serializer.fromJson<String>(json['action']),
      resourceType: serializer.fromJson<String>(json['resourceType']),
      resourceId: serializer.fromJson<String?>(json['resourceId']),
      summary: serializer.fromJson<String?>(json['summary']),
      changes: serializer.fromJson<String?>(json['changes']),
      ipAddress: serializer.fromJson<String?>(json['ipAddress']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'userId': serializer.toJson<String?>(userId),
      'userName': serializer.toJson<String?>(userName),
      'action': serializer.toJson<String>(action),
      'resourceType': serializer.toJson<String>(resourceType),
      'resourceId': serializer.toJson<String?>(resourceId),
      'summary': serializer.toJson<String?>(summary),
      'changes': serializer.toJson<String?>(changes),
      'ipAddress': serializer.toJson<String?>(ipAddress),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  AuditLog copyWith(
          {String? id,
          DateTime? timestamp,
          Value<String?> userId = const Value.absent(),
          Value<String?> userName = const Value.absent(),
          String? action,
          String? resourceType,
          Value<String?> resourceId = const Value.absent(),
          Value<String?> summary = const Value.absent(),
          Value<String?> changes = const Value.absent(),
          Value<String?> ipAddress = const Value.absent(),
          Value<String?> deviceId = const Value.absent()}) =>
      AuditLog(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        userId: userId.present ? userId.value : this.userId,
        userName: userName.present ? userName.value : this.userName,
        action: action ?? this.action,
        resourceType: resourceType ?? this.resourceType,
        resourceId: resourceId.present ? resourceId.value : this.resourceId,
        summary: summary.present ? summary.value : this.summary,
        changes: changes.present ? changes.value : this.changes,
        ipAddress: ipAddress.present ? ipAddress.value : this.ipAddress,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
      );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      userId: data.userId.present ? data.userId.value : this.userId,
      userName: data.userName.present ? data.userName.value : this.userName,
      action: data.action.present ? data.action.value : this.action,
      resourceType: data.resourceType.present
          ? data.resourceType.value
          : this.resourceType,
      resourceId:
          data.resourceId.present ? data.resourceId.value : this.resourceId,
      summary: data.summary.present ? data.summary.value : this.summary,
      changes: data.changes.present ? data.changes.value : this.changes,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('action: $action, ')
          ..write('resourceType: $resourceType, ')
          ..write('resourceId: $resourceId, ')
          ..write('summary: $summary, ')
          ..write('changes: $changes, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timestamp, userId, userName, action,
      resourceType, resourceId, summary, changes, ipAddress, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.userId == this.userId &&
          other.userName == this.userName &&
          other.action == this.action &&
          other.resourceType == this.resourceType &&
          other.resourceId == this.resourceId &&
          other.summary == this.summary &&
          other.changes == this.changes &&
          other.ipAddress == this.ipAddress &&
          other.deviceId == this.deviceId);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<DateTime> timestamp;
  final Value<String?> userId;
  final Value<String?> userName;
  final Value<String> action;
  final Value<String> resourceType;
  final Value<String?> resourceId;
  final Value<String?> summary;
  final Value<String?> changes;
  final Value<String?> ipAddress;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    this.action = const Value.absent(),
    this.resourceType = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.summary = const Value.absent(),
    this.changes = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required DateTime timestamp,
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    required String action,
    required String resourceType,
    this.resourceId = const Value.absent(),
    this.summary = const Value.absent(),
    this.changes = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        timestamp = Value(timestamp),
        action = Value(action),
        resourceType = Value(resourceType);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? userId,
    Expression<String>? userName,
    Expression<String>? action,
    Expression<String>? resourceType,
    Expression<String>? resourceId,
    Expression<String>? summary,
    Expression<String>? changes,
    Expression<String>? ipAddress,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (userId != null) 'user_id': userId,
      if (userName != null) 'user_name': userName,
      if (action != null) 'action': action,
      if (resourceType != null) 'resource_type': resourceType,
      if (resourceId != null) 'resource_id': resourceId,
      if (summary != null) 'summary': summary,
      if (changes != null) 'changes': changes,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? timestamp,
      Value<String?>? userId,
      Value<String?>? userName,
      Value<String>? action,
      Value<String>? resourceType,
      Value<String?>? resourceId,
      Value<String?>? summary,
      Value<String?>? changes,
      Value<String?>? ipAddress,
      Value<String?>? deviceId,
      Value<int>? rowid}) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      action: action ?? this.action,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      summary: summary ?? this.summary,
      changes: changes ?? this.changes,
      ipAddress: ipAddress ?? this.ipAddress,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (resourceType.present) {
      map['resource_type'] = Variable<String>(resourceType.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (changes.present) {
      map['changes'] = Variable<String>(changes.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('action: $action, ')
          ..write('resourceType: $resourceType, ')
          ..write('resourceId: $resourceId, ')
          ..write('summary: $summary, ')
          ..write('changes: $changes, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountersTable extends Counters with TableInfo<$CountersTable, Counter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
      'value', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counters';
  @override
  VerificationContext validateIntegrity(Insertable<Counter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  Counter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Counter(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $CountersTable createAlias(String alias) {
    return $CountersTable(attachedDatabase, alias);
  }
}

class Counter extends DataClass implements Insertable<Counter> {
  final String name;
  final int value;
  const Counter({required this.name, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['value'] = Variable<int>(value);
    return map;
  }

  CountersCompanion toCompanion(bool nullToAbsent) {
    return CountersCompanion(
      name: Value(name),
      value: Value(value),
    );
  }

  factory Counter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Counter(
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<int>(value),
    };
  }

  Counter copyWith({String? name, int? value}) => Counter(
        name: name ?? this.name,
        value: value ?? this.value,
      );
  Counter copyWithCompanion(CountersCompanion data) {
    return Counter(
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Counter(')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Counter &&
          other.name == this.name &&
          other.value == this.value);
}

class CountersCompanion extends UpdateCompanion<Counter> {
  final Value<String> name;
  final Value<int> value;
  final Value<int> rowid;
  const CountersCompanion({
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountersCompanion.insert({
    required String name,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Counter> custom({
    Expression<String>? name,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountersCompanion copyWith(
      {Value<String>? name, Value<int>? value, Value<int>? rowid}) {
    return CountersCompanion(
      name: name ?? this.name,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountersCompanion(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurrenciesTable extends Currencies
    with TableInfo<$CurrenciesTable, Currency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
      'name_ar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _decimalsMeta =
      const VerificationMeta('decimals');
  @override
  late final GeneratedColumn<int> decimals = GeneratedColumn<int>(
      'decimals', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2));
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
      'rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isLocalMeta =
      const VerificationMeta('isLocal');
  @override
  late final GeneratedColumn<bool> isLocal = GeneratedColumn<bool>(
      'is_local', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_local" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        code,
        nameAr,
        symbol,
        decimals,
        rate,
        isLocal,
        isDefault,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'currencies';
  @override
  VerificationContext validateIntegrity(Insertable<Currency> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(_nameArMeta,
          nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta));
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('decimals')) {
      context.handle(_decimalsMeta,
          decimals.isAcceptableOrUnknown(data['decimals']!, _decimalsMeta));
    }
    if (data.containsKey('rate')) {
      context.handle(
          _rateMeta, rate.isAcceptableOrUnknown(data['rate']!, _rateMeta));
    }
    if (data.containsKey('is_local')) {
      context.handle(_isLocalMeta,
          isLocal.isAcceptableOrUnknown(data['is_local']!, _isLocalMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Currency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Currency(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      nameAr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_ar'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      decimals: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}decimals'])!,
      rate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rate'])!,
      isLocal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_local'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CurrenciesTable createAlias(String alias) {
    return $CurrenciesTable(attachedDatabase, alias);
  }
}

class Currency extends DataClass implements Insertable<Currency> {
  final String id;
  final String code;
  final String nameAr;
  final String symbol;
  final int decimals;
  final double rate;
  final bool isLocal;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Currency(
      {required this.id,
      required this.code,
      required this.nameAr,
      required this.symbol,
      required this.decimals,
      required this.rate,
      required this.isLocal,
      required this.isDefault,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name_ar'] = Variable<String>(nameAr);
    map['symbol'] = Variable<String>(symbol);
    map['decimals'] = Variable<int>(decimals);
    map['rate'] = Variable<double>(rate);
    map['is_local'] = Variable<bool>(isLocal);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CurrenciesCompanion toCompanion(bool nullToAbsent) {
    return CurrenciesCompanion(
      id: Value(id),
      code: Value(code),
      nameAr: Value(nameAr),
      symbol: Value(symbol),
      decimals: Value(decimals),
      rate: Value(rate),
      isLocal: Value(isLocal),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Currency.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Currency(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
      symbol: serializer.fromJson<String>(json['symbol']),
      decimals: serializer.fromJson<int>(json['decimals']),
      rate: serializer.fromJson<double>(json['rate']),
      isLocal: serializer.fromJson<bool>(json['isLocal']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'nameAr': serializer.toJson<String>(nameAr),
      'symbol': serializer.toJson<String>(symbol),
      'decimals': serializer.toJson<int>(decimals),
      'rate': serializer.toJson<double>(rate),
      'isLocal': serializer.toJson<bool>(isLocal),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Currency copyWith(
          {String? id,
          String? code,
          String? nameAr,
          String? symbol,
          int? decimals,
          double? rate,
          bool? isLocal,
          bool? isDefault,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Currency(
        id: id ?? this.id,
        code: code ?? this.code,
        nameAr: nameAr ?? this.nameAr,
        symbol: symbol ?? this.symbol,
        decimals: decimals ?? this.decimals,
        rate: rate ?? this.rate,
        isLocal: isLocal ?? this.isLocal,
        isDefault: isDefault ?? this.isDefault,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Currency copyWithCompanion(CurrenciesCompanion data) {
    return Currency(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      decimals: data.decimals.present ? data.decimals.value : this.decimals,
      rate: data.rate.present ? data.rate.value : this.rate,
      isLocal: data.isLocal.present ? data.isLocal.value : this.isLocal,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Currency(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nameAr: $nameAr, ')
          ..write('symbol: $symbol, ')
          ..write('decimals: $decimals, ')
          ..write('rate: $rate, ')
          ..write('isLocal: $isLocal, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, nameAr, symbol, decimals, rate,
      isLocal, isDefault, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Currency &&
          other.id == this.id &&
          other.code == this.code &&
          other.nameAr == this.nameAr &&
          other.symbol == this.symbol &&
          other.decimals == this.decimals &&
          other.rate == this.rate &&
          other.isLocal == this.isLocal &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CurrenciesCompanion extends UpdateCompanion<Currency> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> nameAr;
  final Value<String> symbol;
  final Value<int> decimals;
  final Value<double> rate;
  final Value<bool> isLocal;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CurrenciesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.symbol = const Value.absent(),
    this.decimals = const Value.absent(),
    this.rate = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrenciesCompanion.insert({
    required String id,
    required String code,
    required String nameAr,
    required String symbol,
    this.decimals = const Value.absent(),
    this.rate = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        code = Value(code),
        nameAr = Value(nameAr),
        symbol = Value(symbol),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Currency> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? nameAr,
    Expression<String>? symbol,
    Expression<int>? decimals,
    Expression<double>? rate,
    Expression<bool>? isLocal,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (nameAr != null) 'name_ar': nameAr,
      if (symbol != null) 'symbol': symbol,
      if (decimals != null) 'decimals': decimals,
      if (rate != null) 'rate': rate,
      if (isLocal != null) 'is_local': isLocal,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrenciesCompanion copyWith(
      {Value<String>? id,
      Value<String>? code,
      Value<String>? nameAr,
      Value<String>? symbol,
      Value<int>? decimals,
      Value<double>? rate,
      Value<bool>? isLocal,
      Value<bool>? isDefault,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CurrenciesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      nameAr: nameAr ?? this.nameAr,
      symbol: symbol ?? this.symbol,
      decimals: decimals ?? this.decimals,
      rate: rate ?? this.rate,
      isLocal: isLocal ?? this.isLocal,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (decimals.present) {
      map['decimals'] = Variable<int>(decimals.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (isLocal.present) {
      map['is_local'] = Variable<bool>(isLocal.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrenciesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nameAr: $nameAr, ')
          ..write('symbol: $symbol, ')
          ..write('decimals: $decimals, ')
          ..write('rate: $rate, ')
          ..write('isLocal: $isLocal, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurrencyRatesTable extends CurrencyRates
    with TableInfo<$CurrencyRatesTable, CurrencyRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrencyRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
      'rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _changedByMeta =
      const VerificationMeta('changedBy');
  @override
  late final GeneratedColumn<String> changedBy = GeneratedColumn<String>(
      'changed_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, currencyCode, rate, changedBy, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'currency_rates';
  @override
  VerificationContext validateIntegrity(Insertable<CurrencyRate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
          _rateMeta, rate.isAcceptableOrUnknown(data['rate']!, _rateMeta));
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('changed_by')) {
      context.handle(_changedByMeta,
          changedBy.isAcceptableOrUnknown(data['changed_by']!, _changedByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CurrencyRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurrencyRate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      rate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rate'])!,
      changedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changed_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CurrencyRatesTable createAlias(String alias) {
    return $CurrencyRatesTable(attachedDatabase, alias);
  }
}

class CurrencyRate extends DataClass implements Insertable<CurrencyRate> {
  final String id;
  final String currencyCode;
  final double rate;
  final String? changedBy;
  final DateTime createdAt;
  const CurrencyRate(
      {required this.id,
      required this.currencyCode,
      required this.rate,
      this.changedBy,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['currency_code'] = Variable<String>(currencyCode);
    map['rate'] = Variable<double>(rate);
    if (!nullToAbsent || changedBy != null) {
      map['changed_by'] = Variable<String>(changedBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CurrencyRatesCompanion toCompanion(bool nullToAbsent) {
    return CurrencyRatesCompanion(
      id: Value(id),
      currencyCode: Value(currencyCode),
      rate: Value(rate),
      changedBy: changedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(changedBy),
      createdAt: Value(createdAt),
    );
  }

  factory CurrencyRate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurrencyRate(
      id: serializer.fromJson<String>(json['id']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      rate: serializer.fromJson<double>(json['rate']),
      changedBy: serializer.fromJson<String?>(json['changedBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'rate': serializer.toJson<double>(rate),
      'changedBy': serializer.toJson<String?>(changedBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CurrencyRate copyWith(
          {String? id,
          String? currencyCode,
          double? rate,
          Value<String?> changedBy = const Value.absent(),
          DateTime? createdAt}) =>
      CurrencyRate(
        id: id ?? this.id,
        currencyCode: currencyCode ?? this.currencyCode,
        rate: rate ?? this.rate,
        changedBy: changedBy.present ? changedBy.value : this.changedBy,
        createdAt: createdAt ?? this.createdAt,
      );
  CurrencyRate copyWithCompanion(CurrencyRatesCompanion data) {
    return CurrencyRate(
      id: data.id.present ? data.id.value : this.id,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      rate: data.rate.present ? data.rate.value : this.rate,
      changedBy: data.changedBy.present ? data.changedBy.value : this.changedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurrencyRate(')
          ..write('id: $id, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('rate: $rate, ')
          ..write('changedBy: $changedBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, currencyCode, rate, changedBy, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrencyRate &&
          other.id == this.id &&
          other.currencyCode == this.currencyCode &&
          other.rate == this.rate &&
          other.changedBy == this.changedBy &&
          other.createdAt == this.createdAt);
}

class CurrencyRatesCompanion extends UpdateCompanion<CurrencyRate> {
  final Value<String> id;
  final Value<String> currencyCode;
  final Value<double> rate;
  final Value<String?> changedBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CurrencyRatesCompanion({
    this.id = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.rate = const Value.absent(),
    this.changedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrencyRatesCompanion.insert({
    required String id,
    required String currencyCode,
    required double rate,
    this.changedBy = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        currencyCode = Value(currencyCode),
        rate = Value(rate),
        createdAt = Value(createdAt);
  static Insertable<CurrencyRate> custom({
    Expression<String>? id,
    Expression<String>? currencyCode,
    Expression<double>? rate,
    Expression<String>? changedBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (rate != null) 'rate': rate,
      if (changedBy != null) 'changed_by': changedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrencyRatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? currencyCode,
      Value<double>? rate,
      Value<String?>? changedBy,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CurrencyRatesCompanion(
      id: id ?? this.id,
      currencyCode: currencyCode ?? this.currencyCode,
      rate: rate ?? this.rate,
      changedBy: changedBy ?? this.changedBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (changedBy.present) {
      map['changed_by'] = Variable<String>(changedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrencyRatesCompanion(')
          ..write('id: $id, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('rate: $rate, ')
          ..write('changedBy: $changedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $MembersTable members = $MembersTable(this);
  late final $AidRequestsTable aidRequests = $AidRequestsTable(this);
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $TreasuryEntriesTable treasuryEntries =
      $TreasuryEntriesTable(this);
  late final $VouchersTable vouchers = $VouchersTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $FundSettingsTable fundSettings = $FundSettingsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $JournalLinesTable journalLines = $JournalLinesTable(this);
  late final $BankStatementLinesTable bankStatementLines =
      $BankStatementLinesTable(this);
  late final $DonorsTable donors = $DonorsTable(this);
  late final $PledgesTable pledges = $PledgesTable(this);
  late final $CampaignsTable campaigns = $CampaignsTable(this);
  late final $BeneficiariesTable beneficiaries = $BeneficiariesTable(this);
  late final $PeriodicAidsTable periodicAids = $PeriodicAidsTable(this);
  late final $InKindItemsTable inKindItems = $InKindItemsTable(this);
  late final $InKindMovementsTable inKindMovements =
      $InKindMovementsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $OtpCodesTable otpCodes = $OtpCodesTable(this);
  late final $RefreshSessionsTable refreshSessions =
      $RefreshSessionsTable(this);
  late final $DeviceTokensTable deviceTokens = $DeviceTokensTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $CountersTable counters = $CountersTable(this);
  late final $CurrenciesTable currencies = $CurrenciesTable(this);
  late final $CurrencyRatesTable currencyRates = $CurrencyRatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        members,
        aidRequests,
        subscriptions,
        treasuryEntries,
        vouchers,
        messages,
        events,
        fundSettings,
        accounts,
        journalEntries,
        journalLines,
        bankStatementLines,
        donors,
        pledges,
        campaigns,
        beneficiaries,
        periodicAids,
        inKindItems,
        inKindMovements,
        budgets,
        otpCodes,
        refreshSessions,
        deviceTokens,
        auditLogs,
        counters,
        currencies,
        currencyRates
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String username,
  required String passwordHash,
  required String fullName,
  Value<String> role,
  Value<String> avatarInitial,
  Value<bool> isActive,
  Value<String?> phone,
  Value<bool> otpEnabled,
  Value<bool> biometricEnabled,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> username,
  Value<String> passwordHash,
  Value<String> fullName,
  Value<String> role,
  Value<String> avatarInitial,
  Value<bool> isActive,
  Value<String?> phone,
  Value<bool> otpEnabled,
  Value<bool> biometricEnabled,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarInitial => $composableBuilder(
      column: $table.avatarInitial, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get otpEnabled => $composableBuilder(
      column: $table.otpEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarInitial => $composableBuilder(
      column: $table.avatarInitial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get otpEnabled => $composableBuilder(
      column: $table.otpEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get avatarInitial => $composableBuilder(
      column: $table.avatarInitial, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get otpEnabled => $composableBuilder(
      column: $table.otpEnabled, builder: (column) => column);

  GeneratedColumn<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> avatarInitial = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<bool> otpEnabled = const Value.absent(),
            Value<bool> biometricEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            username: username,
            passwordHash: passwordHash,
            fullName: fullName,
            role: role,
            avatarInitial: avatarInitial,
            isActive: isActive,
            phone: phone,
            otpEnabled: otpEnabled,
            biometricEnabled: biometricEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String username,
            required String passwordHash,
            required String fullName,
            Value<String> role = const Value.absent(),
            Value<String> avatarInitial = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<bool> otpEnabled = const Value.absent(),
            Value<bool> biometricEnabled = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            username: username,
            passwordHash: passwordHash,
            fullName: fullName,
            role: role,
            avatarInitial: avatarInitial,
            isActive: isActive,
            phone: phone,
            otpEnabled: otpEnabled,
            biometricEnabled: biometricEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  required String id,
  required String name,
  required String nationalId,
  Value<String?> nationalIdSearch,
  required String phone,
  Value<String?> email,
  Value<String?> city,
  Value<String?> joinDate,
  Value<String> status,
  Value<int> monthlySubscription,
  Value<int> totalPaid,
  Value<int> balanceDue,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> nationalId,
  Value<String?> nationalIdSearch,
  Value<String> phone,
  Value<String?> email,
  Value<String?> city,
  Value<String?> joinDate,
  Value<String> status,
  Value<int> monthlySubscription,
  Value<int> totalPaid,
  Value<int> balanceDue,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationalIdSearch => $composableBuilder(
      column: $table.nationalIdSearch,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get joinDate => $composableBuilder(
      column: $table.joinDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthlySubscription => $composableBuilder(
      column: $table.monthlySubscription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPaid => $composableBuilder(
      column: $table.totalPaid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get balanceDue => $composableBuilder(
      column: $table.balanceDue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationalIdSearch => $composableBuilder(
      column: $table.nationalIdSearch,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get joinDate => $composableBuilder(
      column: $table.joinDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthlySubscription => $composableBuilder(
      column: $table.monthlySubscription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPaid => $composableBuilder(
      column: $table.totalPaid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get balanceDue => $composableBuilder(
      column: $table.balanceDue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => column);

  GeneratedColumn<String> get nationalIdSearch => $composableBuilder(
      column: $table.nationalIdSearch, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get joinDate =>
      $composableBuilder(column: $table.joinDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get monthlySubscription => $composableBuilder(
      column: $table.monthlySubscription, builder: (column) => column);

  GeneratedColumn<int> get totalPaid =>
      $composableBuilder(column: $table.totalPaid, builder: (column) => column);

  GeneratedColumn<int> get balanceDue => $composableBuilder(
      column: $table.balanceDue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$MembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MembersTable,
    Member,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
    Member,
    PrefetchHooks Function()> {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nationalId = const Value.absent(),
            Value<String?> nationalIdSearch = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> joinDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> monthlySubscription = const Value.absent(),
            Value<int> totalPaid = const Value.absent(),
            Value<int> balanceDue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MembersCompanion(
            id: id,
            name: name,
            nationalId: nationalId,
            nationalIdSearch: nationalIdSearch,
            phone: phone,
            email: email,
            city: city,
            joinDate: joinDate,
            status: status,
            monthlySubscription: monthlySubscription,
            totalPaid: totalPaid,
            balanceDue: balanceDue,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String nationalId,
            Value<String?> nationalIdSearch = const Value.absent(),
            required String phone,
            Value<String?> email = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> joinDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> monthlySubscription = const Value.absent(),
            Value<int> totalPaid = const Value.absent(),
            Value<int> balanceDue = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MembersCompanion.insert(
            id: id,
            name: name,
            nationalId: nationalId,
            nationalIdSearch: nationalIdSearch,
            phone: phone,
            email: email,
            city: city,
            joinDate: joinDate,
            status: status,
            monthlySubscription: monthlySubscription,
            totalPaid: totalPaid,
            balanceDue: balanceDue,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MembersTable,
    Member,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
    Member,
    PrefetchHooks Function()>;
typedef $$AidRequestsTableCreateCompanionBuilder = AidRequestsCompanion
    Function({
  required String id,
  required String memberId,
  required String memberName,
  required String aidType,
  required int amount,
  Value<String?> currencyCode,
  Value<double?> originalAmount,
  Value<double?> exchangeRate,
  required String requestDate,
  Value<String> status,
  Value<String?> note,
  Value<String?> reviewerName,
  Value<String?> reviewerId,
  Value<String?> createdBy,
  Value<String?> beneficiaryId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$AidRequestsTableUpdateCompanionBuilder = AidRequestsCompanion
    Function({
  Value<String> id,
  Value<String> memberId,
  Value<String> memberName,
  Value<String> aidType,
  Value<int> amount,
  Value<String?> currencyCode,
  Value<double?> originalAmount,
  Value<double?> exchangeRate,
  Value<String> requestDate,
  Value<String> status,
  Value<String?> note,
  Value<String?> reviewerName,
  Value<String?> reviewerId,
  Value<String?> createdBy,
  Value<String?> beneficiaryId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$AidRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $AidRequestsTable> {
  $$AidRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberName => $composableBuilder(
      column: $table.memberName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aidType => $composableBuilder(
      column: $table.aidType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get requestDate => $composableBuilder(
      column: $table.requestDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reviewerName => $composableBuilder(
      column: $table.reviewerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reviewerId => $composableBuilder(
      column: $table.reviewerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$AidRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $AidRequestsTable> {
  $$AidRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberName => $composableBuilder(
      column: $table.memberName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aidType => $composableBuilder(
      column: $table.aidType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get requestDate => $composableBuilder(
      column: $table.requestDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reviewerName => $composableBuilder(
      column: $table.reviewerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reviewerId => $composableBuilder(
      column: $table.reviewerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$AidRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AidRequestsTable> {
  $$AidRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get memberName => $composableBuilder(
      column: $table.memberName, builder: (column) => column);

  GeneratedColumn<String> get aidType =>
      $composableBuilder(column: $table.aidType, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => column);

  GeneratedColumn<String> get requestDate => $composableBuilder(
      column: $table.requestDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get reviewerName => $composableBuilder(
      column: $table.reviewerName, builder: (column) => column);

  GeneratedColumn<String> get reviewerId => $composableBuilder(
      column: $table.reviewerId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$AidRequestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AidRequestsTable,
    AidRequest,
    $$AidRequestsTableFilterComposer,
    $$AidRequestsTableOrderingComposer,
    $$AidRequestsTableAnnotationComposer,
    $$AidRequestsTableCreateCompanionBuilder,
    $$AidRequestsTableUpdateCompanionBuilder,
    (AidRequest, BaseReferences<_$AppDatabase, $AidRequestsTable, AidRequest>),
    AidRequest,
    PrefetchHooks Function()> {
  $$AidRequestsTableTableManager(_$AppDatabase db, $AidRequestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AidRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AidRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AidRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> memberId = const Value.absent(),
            Value<String> memberName = const Value.absent(),
            Value<String> aidType = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> currencyCode = const Value.absent(),
            Value<double?> originalAmount = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<String> requestDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> reviewerName = const Value.absent(),
            Value<String?> reviewerId = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> beneficiaryId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AidRequestsCompanion(
            id: id,
            memberId: memberId,
            memberName: memberName,
            aidType: aidType,
            amount: amount,
            currencyCode: currencyCode,
            originalAmount: originalAmount,
            exchangeRate: exchangeRate,
            requestDate: requestDate,
            status: status,
            note: note,
            reviewerName: reviewerName,
            reviewerId: reviewerId,
            createdBy: createdBy,
            beneficiaryId: beneficiaryId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String memberId,
            required String memberName,
            required String aidType,
            required int amount,
            Value<String?> currencyCode = const Value.absent(),
            Value<double?> originalAmount = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            required String requestDate,
            Value<String> status = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> reviewerName = const Value.absent(),
            Value<String?> reviewerId = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> beneficiaryId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AidRequestsCompanion.insert(
            id: id,
            memberId: memberId,
            memberName: memberName,
            aidType: aidType,
            amount: amount,
            currencyCode: currencyCode,
            originalAmount: originalAmount,
            exchangeRate: exchangeRate,
            requestDate: requestDate,
            status: status,
            note: note,
            reviewerName: reviewerName,
            reviewerId: reviewerId,
            createdBy: createdBy,
            beneficiaryId: beneficiaryId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AidRequestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AidRequestsTable,
    AidRequest,
    $$AidRequestsTableFilterComposer,
    $$AidRequestsTableOrderingComposer,
    $$AidRequestsTableAnnotationComposer,
    $$AidRequestsTableCreateCompanionBuilder,
    $$AidRequestsTableUpdateCompanionBuilder,
    (AidRequest, BaseReferences<_$AppDatabase, $AidRequestsTable, AidRequest>),
    AidRequest,
    PrefetchHooks Function()>;
typedef $$SubscriptionsTableCreateCompanionBuilder = SubscriptionsCompanion
    Function({
  required String id,
  required String memberId,
  required String memberName,
  required int amount,
  Value<String?> currencyCode,
  Value<double?> originalAmount,
  Value<double?> exchangeRate,
  required String paymentDate,
  Value<String?> period,
  required String method,
  Value<String?> referenceNo,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$SubscriptionsTableUpdateCompanionBuilder = SubscriptionsCompanion
    Function({
  Value<String> id,
  Value<String> memberId,
  Value<String> memberName,
  Value<int> amount,
  Value<String?> currencyCode,
  Value<double?> originalAmount,
  Value<double?> exchangeRate,
  Value<String> paymentDate,
  Value<String?> period,
  Value<String> method,
  Value<String?> referenceNo,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$SubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberName => $composableBuilder(
      column: $table.memberName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberName => $composableBuilder(
      column: $table.memberName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get memberName => $composableBuilder(
      column: $table.memberName, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => column);

  GeneratedColumn<String> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$SubscriptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubscriptionsTable,
    Subscription,
    $$SubscriptionsTableFilterComposer,
    $$SubscriptionsTableOrderingComposer,
    $$SubscriptionsTableAnnotationComposer,
    $$SubscriptionsTableCreateCompanionBuilder,
    $$SubscriptionsTableUpdateCompanionBuilder,
    (
      Subscription,
      BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>
    ),
    Subscription,
    PrefetchHooks Function()> {
  $$SubscriptionsTableTableManager(_$AppDatabase db, $SubscriptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> memberId = const Value.absent(),
            Value<String> memberName = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> currencyCode = const Value.absent(),
            Value<double?> originalAmount = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<String> paymentDate = const Value.absent(),
            Value<String?> period = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String?> referenceNo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionsCompanion(
            id: id,
            memberId: memberId,
            memberName: memberName,
            amount: amount,
            currencyCode: currencyCode,
            originalAmount: originalAmount,
            exchangeRate: exchangeRate,
            paymentDate: paymentDate,
            period: period,
            method: method,
            referenceNo: referenceNo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String memberId,
            required String memberName,
            required int amount,
            Value<String?> currencyCode = const Value.absent(),
            Value<double?> originalAmount = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            required String paymentDate,
            Value<String?> period = const Value.absent(),
            required String method,
            Value<String?> referenceNo = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionsCompanion.insert(
            id: id,
            memberId: memberId,
            memberName: memberName,
            amount: amount,
            currencyCode: currencyCode,
            originalAmount: originalAmount,
            exchangeRate: exchangeRate,
            paymentDate: paymentDate,
            period: period,
            method: method,
            referenceNo: referenceNo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubscriptionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubscriptionsTable,
    Subscription,
    $$SubscriptionsTableFilterComposer,
    $$SubscriptionsTableOrderingComposer,
    $$SubscriptionsTableAnnotationComposer,
    $$SubscriptionsTableCreateCompanionBuilder,
    $$SubscriptionsTableUpdateCompanionBuilder,
    (
      Subscription,
      BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>
    ),
    Subscription,
    PrefetchHooks Function()>;
typedef $$TreasuryEntriesTableCreateCompanionBuilder = TreasuryEntriesCompanion
    Function({
  required String id,
  required String type,
  required String category,
  required String description,
  required int amount,
  Value<String?> currencyCode,
  Value<double?> originalAmount,
  Value<double?> exchangeRate,
  required String entryDate,
  Value<String?> referenceNo,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$TreasuryEntriesTableUpdateCompanionBuilder = TreasuryEntriesCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String> category,
  Value<String> description,
  Value<int> amount,
  Value<String?> currencyCode,
  Value<double?> originalAmount,
  Value<double?> exchangeRate,
  Value<String> entryDate,
  Value<String?> referenceNo,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$TreasuryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TreasuryEntriesTable> {
  $$TreasuryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$TreasuryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TreasuryEntriesTable> {
  $$TreasuryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$TreasuryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreasuryEntriesTable> {
  $$TreasuryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$TreasuryEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TreasuryEntriesTable,
    TreasuryEntry,
    $$TreasuryEntriesTableFilterComposer,
    $$TreasuryEntriesTableOrderingComposer,
    $$TreasuryEntriesTableAnnotationComposer,
    $$TreasuryEntriesTableCreateCompanionBuilder,
    $$TreasuryEntriesTableUpdateCompanionBuilder,
    (
      TreasuryEntry,
      BaseReferences<_$AppDatabase, $TreasuryEntriesTable, TreasuryEntry>
    ),
    TreasuryEntry,
    PrefetchHooks Function()> {
  $$TreasuryEntriesTableTableManager(
      _$AppDatabase db, $TreasuryEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreasuryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreasuryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreasuryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> currencyCode = const Value.absent(),
            Value<double?> originalAmount = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<String> entryDate = const Value.absent(),
            Value<String?> referenceNo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TreasuryEntriesCompanion(
            id: id,
            type: type,
            category: category,
            description: description,
            amount: amount,
            currencyCode: currencyCode,
            originalAmount: originalAmount,
            exchangeRate: exchangeRate,
            entryDate: entryDate,
            referenceNo: referenceNo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String category,
            required String description,
            required int amount,
            Value<String?> currencyCode = const Value.absent(),
            Value<double?> originalAmount = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            required String entryDate,
            Value<String?> referenceNo = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TreasuryEntriesCompanion.insert(
            id: id,
            type: type,
            category: category,
            description: description,
            amount: amount,
            currencyCode: currencyCode,
            originalAmount: originalAmount,
            exchangeRate: exchangeRate,
            entryDate: entryDate,
            referenceNo: referenceNo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TreasuryEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TreasuryEntriesTable,
    TreasuryEntry,
    $$TreasuryEntriesTableFilterComposer,
    $$TreasuryEntriesTableOrderingComposer,
    $$TreasuryEntriesTableAnnotationComposer,
    $$TreasuryEntriesTableCreateCompanionBuilder,
    $$TreasuryEntriesTableUpdateCompanionBuilder,
    (
      TreasuryEntry,
      BaseReferences<_$AppDatabase, $TreasuryEntriesTable, TreasuryEntry>
    ),
    TreasuryEntry,
    PrefetchHooks Function()>;
typedef $$VouchersTableCreateCompanionBuilder = VouchersCompanion Function({
  required String id,
  required String voucherNo,
  required String kind,
  Value<String?> memberId,
  Value<String?> memberName,
  Value<String?> donorId,
  Value<String?> beneficiaryId,
  Value<String?> partyName,
  required int amount,
  Value<String?> currencyCode,
  Value<double?> originalAmount,
  Value<double?> exchangeRate,
  required String voucherDate,
  required String method,
  required String description,
  required String issuedByName,
  Value<String?> issuedById,
  Value<String> status,
  Value<String?> treasuryAccountId,
  Value<String?> counterAccountId,
  Value<String?> journalEntryId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$VouchersTableUpdateCompanionBuilder = VouchersCompanion Function({
  Value<String> id,
  Value<String> voucherNo,
  Value<String> kind,
  Value<String?> memberId,
  Value<String?> memberName,
  Value<String?> donorId,
  Value<String?> beneficiaryId,
  Value<String?> partyName,
  Value<int> amount,
  Value<String?> currencyCode,
  Value<double?> originalAmount,
  Value<double?> exchangeRate,
  Value<String> voucherDate,
  Value<String> method,
  Value<String> description,
  Value<String> issuedByName,
  Value<String?> issuedById,
  Value<String> status,
  Value<String?> treasuryAccountId,
  Value<String?> counterAccountId,
  Value<String?> journalEntryId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$VouchersTableFilterComposer
    extends Composer<_$AppDatabase, $VouchersTable> {
  $$VouchersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voucherNo => $composableBuilder(
      column: $table.voucherNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberName => $composableBuilder(
      column: $table.memberName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get donorId => $composableBuilder(
      column: $table.donorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyName => $composableBuilder(
      column: $table.partyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voucherDate => $composableBuilder(
      column: $table.voucherDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get issuedByName => $composableBuilder(
      column: $table.issuedByName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get issuedById => $composableBuilder(
      column: $table.issuedById, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get treasuryAccountId => $composableBuilder(
      column: $table.treasuryAccountId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get counterAccountId => $composableBuilder(
      column: $table.counterAccountId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get journalEntryId => $composableBuilder(
      column: $table.journalEntryId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$VouchersTableOrderingComposer
    extends Composer<_$AppDatabase, $VouchersTable> {
  $$VouchersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voucherNo => $composableBuilder(
      column: $table.voucherNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberName => $composableBuilder(
      column: $table.memberName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get donorId => $composableBuilder(
      column: $table.donorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyName => $composableBuilder(
      column: $table.partyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voucherDate => $composableBuilder(
      column: $table.voucherDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get issuedByName => $composableBuilder(
      column: $table.issuedByName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get issuedById => $composableBuilder(
      column: $table.issuedById, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get treasuryAccountId => $composableBuilder(
      column: $table.treasuryAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get counterAccountId => $composableBuilder(
      column: $table.counterAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
      column: $table.journalEntryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$VouchersTableAnnotationComposer
    extends Composer<_$AppDatabase, $VouchersTable> {
  $$VouchersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get voucherNo =>
      $composableBuilder(column: $table.voucherNo, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get memberName => $composableBuilder(
      column: $table.memberName, builder: (column) => column);

  GeneratedColumn<String> get donorId =>
      $composableBuilder(column: $table.donorId, builder: (column) => column);

  GeneratedColumn<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<String> get partyName =>
      $composableBuilder(column: $table.partyName, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<double> get originalAmount => $composableBuilder(
      column: $table.originalAmount, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => column);

  GeneratedColumn<String> get voucherDate => $composableBuilder(
      column: $table.voucherDate, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get issuedByName => $composableBuilder(
      column: $table.issuedByName, builder: (column) => column);

  GeneratedColumn<String> get issuedById => $composableBuilder(
      column: $table.issuedById, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get treasuryAccountId => $composableBuilder(
      column: $table.treasuryAccountId, builder: (column) => column);

  GeneratedColumn<String> get counterAccountId => $composableBuilder(
      column: $table.counterAccountId, builder: (column) => column);

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
      column: $table.journalEntryId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$VouchersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VouchersTable,
    Voucher,
    $$VouchersTableFilterComposer,
    $$VouchersTableOrderingComposer,
    $$VouchersTableAnnotationComposer,
    $$VouchersTableCreateCompanionBuilder,
    $$VouchersTableUpdateCompanionBuilder,
    (Voucher, BaseReferences<_$AppDatabase, $VouchersTable, Voucher>),
    Voucher,
    PrefetchHooks Function()> {
  $$VouchersTableTableManager(_$AppDatabase db, $VouchersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VouchersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VouchersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VouchersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> voucherNo = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String?> memberId = const Value.absent(),
            Value<String?> memberName = const Value.absent(),
            Value<String?> donorId = const Value.absent(),
            Value<String?> beneficiaryId = const Value.absent(),
            Value<String?> partyName = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> currencyCode = const Value.absent(),
            Value<double?> originalAmount = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            Value<String> voucherDate = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> issuedByName = const Value.absent(),
            Value<String?> issuedById = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> treasuryAccountId = const Value.absent(),
            Value<String?> counterAccountId = const Value.absent(),
            Value<String?> journalEntryId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VouchersCompanion(
            id: id,
            voucherNo: voucherNo,
            kind: kind,
            memberId: memberId,
            memberName: memberName,
            donorId: donorId,
            beneficiaryId: beneficiaryId,
            partyName: partyName,
            amount: amount,
            currencyCode: currencyCode,
            originalAmount: originalAmount,
            exchangeRate: exchangeRate,
            voucherDate: voucherDate,
            method: method,
            description: description,
            issuedByName: issuedByName,
            issuedById: issuedById,
            status: status,
            treasuryAccountId: treasuryAccountId,
            counterAccountId: counterAccountId,
            journalEntryId: journalEntryId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String voucherNo,
            required String kind,
            Value<String?> memberId = const Value.absent(),
            Value<String?> memberName = const Value.absent(),
            Value<String?> donorId = const Value.absent(),
            Value<String?> beneficiaryId = const Value.absent(),
            Value<String?> partyName = const Value.absent(),
            required int amount,
            Value<String?> currencyCode = const Value.absent(),
            Value<double?> originalAmount = const Value.absent(),
            Value<double?> exchangeRate = const Value.absent(),
            required String voucherDate,
            required String method,
            required String description,
            required String issuedByName,
            Value<String?> issuedById = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> treasuryAccountId = const Value.absent(),
            Value<String?> counterAccountId = const Value.absent(),
            Value<String?> journalEntryId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VouchersCompanion.insert(
            id: id,
            voucherNo: voucherNo,
            kind: kind,
            memberId: memberId,
            memberName: memberName,
            donorId: donorId,
            beneficiaryId: beneficiaryId,
            partyName: partyName,
            amount: amount,
            currencyCode: currencyCode,
            originalAmount: originalAmount,
            exchangeRate: exchangeRate,
            voucherDate: voucherDate,
            method: method,
            description: description,
            issuedByName: issuedByName,
            issuedById: issuedById,
            status: status,
            treasuryAccountId: treasuryAccountId,
            counterAccountId: counterAccountId,
            journalEntryId: journalEntryId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VouchersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VouchersTable,
    Voucher,
    $$VouchersTableFilterComposer,
    $$VouchersTableOrderingComposer,
    $$VouchersTableAnnotationComposer,
    $$VouchersTableCreateCompanionBuilder,
    $$VouchersTableUpdateCompanionBuilder,
    (Voucher, BaseReferences<_$AppDatabase, $VouchersTable, Voucher>),
    Voucher,
    PrefetchHooks Function()>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String fromUserId,
  required String fromName,
  required String toUserId,
  required String toName,
  required String body,
  Value<bool> read,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> fromUserId,
  Value<String> fromName,
  Value<String> toUserId,
  Value<String> toName,
  Value<String> body,
  Value<bool> read,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromUserId => $composableBuilder(
      column: $table.fromUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromName => $composableBuilder(
      column: $table.fromName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toUserId => $composableBuilder(
      column: $table.toUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toName => $composableBuilder(
      column: $table.toName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get read => $composableBuilder(
      column: $table.read, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromUserId => $composableBuilder(
      column: $table.fromUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromName => $composableBuilder(
      column: $table.fromName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toUserId => $composableBuilder(
      column: $table.toUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toName => $composableBuilder(
      column: $table.toName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get read => $composableBuilder(
      column: $table.read, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromUserId => $composableBuilder(
      column: $table.fromUserId, builder: (column) => column);

  GeneratedColumn<String> get fromName =>
      $composableBuilder(column: $table.fromName, builder: (column) => column);

  GeneratedColumn<String> get toUserId =>
      $composableBuilder(column: $table.toUserId, builder: (column) => column);

  GeneratedColumn<String> get toName =>
      $composableBuilder(column: $table.toName, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fromUserId = const Value.absent(),
            Value<String> fromName = const Value.absent(),
            Value<String> toUserId = const Value.absent(),
            Value<String> toName = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<bool> read = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            fromUserId: fromUserId,
            fromName: fromName,
            toUserId: toUserId,
            toName: toName,
            body: body,
            read: read,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fromUserId,
            required String fromName,
            required String toUserId,
            required String toName,
            required String body,
            Value<bool> read = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            fromUserId: fromUserId,
            fromName: fromName,
            toUserId: toUserId,
            toName: toName,
            body: body,
            read: read,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String title,
  required String eventDate,
  Value<String?> eventTime,
  Value<String?> place,
  Value<String?> type,
  Value<String> color,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> eventDate,
  Value<String?> eventTime,
  Value<String?> place,
  Value<String?> type,
  Value<String> color,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventTime => $composableBuilder(
      column: $table.eventTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get place => $composableBuilder(
      column: $table.place, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventTime => $composableBuilder(
      column: $table.eventTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get place => $composableBuilder(
      column: $table.place, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get eventTime =>
      $composableBuilder(column: $table.eventTime, builder: (column) => column);

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$EventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
    Event,
    PrefetchHooks Function()> {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> eventDate = const Value.absent(),
            Value<String?> eventTime = const Value.absent(),
            Value<String?> place = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            title: title,
            eventDate: eventDate,
            eventTime: eventTime,
            place: place,
            type: type,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String eventDate,
            Value<String?> eventTime = const Value.absent(),
            Value<String?> place = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String> color = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            title: title,
            eventDate: eventDate,
            eventTime: eventTime,
            place: place,
            type: type,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
    Event,
    PrefetchHooks Function()>;
typedef $$FundSettingsTableCreateCompanionBuilder = FundSettingsCompanion
    Function({
  required String id,
  Value<String> name,
  Value<String?> logoBase64,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<String?> registrationNo,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$FundSettingsTableUpdateCompanionBuilder = FundSettingsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> logoBase64,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<String?> registrationNo,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$FundSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $FundSettingsTable> {
  $$FundSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoBase64 => $composableBuilder(
      column: $table.logoBase64, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registrationNo => $composableBuilder(
      column: $table.registrationNo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$FundSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $FundSettingsTable> {
  $$FundSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoBase64 => $composableBuilder(
      column: $table.logoBase64, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registrationNo => $composableBuilder(
      column: $table.registrationNo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$FundSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FundSettingsTable> {
  $$FundSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logoBase64 => $composableBuilder(
      column: $table.logoBase64, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get registrationNo => $composableBuilder(
      column: $table.registrationNo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$FundSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FundSettingsTable,
    FundSetting,
    $$FundSettingsTableFilterComposer,
    $$FundSettingsTableOrderingComposer,
    $$FundSettingsTableAnnotationComposer,
    $$FundSettingsTableCreateCompanionBuilder,
    $$FundSettingsTableUpdateCompanionBuilder,
    (
      FundSetting,
      BaseReferences<_$AppDatabase, $FundSettingsTable, FundSetting>
    ),
    FundSetting,
    PrefetchHooks Function()> {
  $$FundSettingsTableTableManager(_$AppDatabase db, $FundSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FundSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FundSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FundSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> logoBase64 = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> registrationNo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FundSettingsCompanion(
            id: id,
            name: name,
            logoBase64: logoBase64,
            phone: phone,
            email: email,
            address: address,
            registrationNo: registrationNo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> name = const Value.absent(),
            Value<String?> logoBase64 = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> registrationNo = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FundSettingsCompanion.insert(
            id: id,
            name: name,
            logoBase64: logoBase64,
            phone: phone,
            email: email,
            address: address,
            registrationNo: registrationNo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FundSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FundSettingsTable,
    FundSetting,
    $$FundSettingsTableFilterComposer,
    $$FundSettingsTableOrderingComposer,
    $$FundSettingsTableAnnotationComposer,
    $$FundSettingsTableCreateCompanionBuilder,
    $$FundSettingsTableUpdateCompanionBuilder,
    (
      FundSetting,
      BaseReferences<_$AppDatabase, $FundSettingsTable, FundSetting>
    ),
    FundSetting,
    PrefetchHooks Function()>;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String code,
  required String name,
  required String type,
  Value<String?> parentId,
  Value<bool> isPostable,
  Value<int> level,
  Value<int> sortOrder,
  Value<String?> description,
  Value<bool> isBank,
  Value<bool> isCash,
  Value<bool> isWallet,
  Value<String?> bankName,
  Value<String?> accountNumber,
  Value<String> currency,
  Value<bool> isActive,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<String> name,
  Value<String> type,
  Value<String?> parentId,
  Value<bool> isPostable,
  Value<int> level,
  Value<int> sortOrder,
  Value<String?> description,
  Value<bool> isBank,
  Value<bool> isCash,
  Value<bool> isWallet,
  Value<String?> bankName,
  Value<String?> accountNumber,
  Value<String> currency,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPostable => $composableBuilder(
      column: $table.isPostable, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBank => $composableBuilder(
      column: $table.isBank, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCash => $composableBuilder(
      column: $table.isCash, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isWallet => $composableBuilder(
      column: $table.isWallet, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPostable => $composableBuilder(
      column: $table.isPostable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBank => $composableBuilder(
      column: $table.isBank, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCash => $composableBuilder(
      column: $table.isCash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isWallet => $composableBuilder(
      column: $table.isWallet, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<bool> get isPostable => $composableBuilder(
      column: $table.isPostable, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isBank =>
      $composableBuilder(column: $table.isBank, builder: (column) => column);

  GeneratedColumn<bool> get isCash =>
      $composableBuilder(column: $table.isCash, builder: (column) => column);

  GeneratedColumn<bool> get isWallet =>
      $composableBuilder(column: $table.isWallet, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<bool> isPostable = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isBank = const Value.absent(),
            Value<bool> isCash = const Value.absent(),
            Value<bool> isWallet = const Value.absent(),
            Value<String?> bankName = const Value.absent(),
            Value<String?> accountNumber = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            code: code,
            name: name,
            type: type,
            parentId: parentId,
            isPostable: isPostable,
            level: level,
            sortOrder: sortOrder,
            description: description,
            isBank: isBank,
            isCash: isCash,
            isWallet: isWallet,
            bankName: bankName,
            accountNumber: accountNumber,
            currency: currency,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String code,
            required String name,
            required String type,
            Value<String?> parentId = const Value.absent(),
            Value<bool> isPostable = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isBank = const Value.absent(),
            Value<bool> isCash = const Value.absent(),
            Value<bool> isWallet = const Value.absent(),
            Value<String?> bankName = const Value.absent(),
            Value<String?> accountNumber = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            code: code,
            name: name,
            type: type,
            parentId: parentId,
            isPostable: isPostable,
            level: level,
            sortOrder: sortOrder,
            description: description,
            isBank: isBank,
            isCash: isCash,
            isWallet: isWallet,
            bankName: bankName,
            accountNumber: accountNumber,
            currency: currency,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()>;
typedef $$JournalEntriesTableCreateCompanionBuilder = JournalEntriesCompanion
    Function({
  required String id,
  required String entryNo,
  required String entryDate,
  required String description,
  required String entryType,
  Value<String?> reference,
  Value<String> status,
  Value<String?> campaignId,
  Value<String?> donorId,
  Value<String?> memberId,
  Value<String?> aidId,
  Value<String?> beneficiaryId,
  Value<String?> voucherId,
  Value<String?> createdBy,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$JournalEntriesTableUpdateCompanionBuilder = JournalEntriesCompanion
    Function({
  Value<String> id,
  Value<String> entryNo,
  Value<String> entryDate,
  Value<String> description,
  Value<String> entryType,
  Value<String?> reference,
  Value<String> status,
  Value<String?> campaignId,
  Value<String?> donorId,
  Value<String?> memberId,
  Value<String?> aidId,
  Value<String?> beneficiaryId,
  Value<String?> voucherId,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryNo => $composableBuilder(
      column: $table.entryNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get donorId => $composableBuilder(
      column: $table.donorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aidId => $composableBuilder(
      column: $table.aidId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voucherId => $composableBuilder(
      column: $table.voucherId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryNo => $composableBuilder(
      column: $table.entryNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get donorId => $composableBuilder(
      column: $table.donorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aidId => $composableBuilder(
      column: $table.aidId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voucherId => $composableBuilder(
      column: $table.voucherId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryNo =>
      $composableBuilder(column: $table.entryNo, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => column);

  GeneratedColumn<String> get donorId =>
      $composableBuilder(column: $table.donorId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get aidId =>
      $composableBuilder(column: $table.aidId, builder: (column) => column);

  GeneratedColumn<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<String> get voucherId =>
      $composableBuilder(column: $table.voucherId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$JournalEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $JournalEntriesTable,
    JournalEntry,
    $$JournalEntriesTableFilterComposer,
    $$JournalEntriesTableOrderingComposer,
    $$JournalEntriesTableAnnotationComposer,
    $$JournalEntriesTableCreateCompanionBuilder,
    $$JournalEntriesTableUpdateCompanionBuilder,
    (
      JournalEntry,
      BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>
    ),
    JournalEntry,
    PrefetchHooks Function()> {
  $$JournalEntriesTableTableManager(
      _$AppDatabase db, $JournalEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entryNo = const Value.absent(),
            Value<String> entryDate = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> entryType = const Value.absent(),
            Value<String?> reference = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> campaignId = const Value.absent(),
            Value<String?> donorId = const Value.absent(),
            Value<String?> memberId = const Value.absent(),
            Value<String?> aidId = const Value.absent(),
            Value<String?> beneficiaryId = const Value.absent(),
            Value<String?> voucherId = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JournalEntriesCompanion(
            id: id,
            entryNo: entryNo,
            entryDate: entryDate,
            description: description,
            entryType: entryType,
            reference: reference,
            status: status,
            campaignId: campaignId,
            donorId: donorId,
            memberId: memberId,
            aidId: aidId,
            beneficiaryId: beneficiaryId,
            voucherId: voucherId,
            createdBy: createdBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entryNo,
            required String entryDate,
            required String description,
            required String entryType,
            Value<String?> reference = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> campaignId = const Value.absent(),
            Value<String?> donorId = const Value.absent(),
            Value<String?> memberId = const Value.absent(),
            Value<String?> aidId = const Value.absent(),
            Value<String?> beneficiaryId = const Value.absent(),
            Value<String?> voucherId = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              JournalEntriesCompanion.insert(
            id: id,
            entryNo: entryNo,
            entryDate: entryDate,
            description: description,
            entryType: entryType,
            reference: reference,
            status: status,
            campaignId: campaignId,
            donorId: donorId,
            memberId: memberId,
            aidId: aidId,
            beneficiaryId: beneficiaryId,
            voucherId: voucherId,
            createdBy: createdBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JournalEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $JournalEntriesTable,
    JournalEntry,
    $$JournalEntriesTableFilterComposer,
    $$JournalEntriesTableOrderingComposer,
    $$JournalEntriesTableAnnotationComposer,
    $$JournalEntriesTableCreateCompanionBuilder,
    $$JournalEntriesTableUpdateCompanionBuilder,
    (
      JournalEntry,
      BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>
    ),
    JournalEntry,
    PrefetchHooks Function()>;
typedef $$JournalLinesTableCreateCompanionBuilder = JournalLinesCompanion
    Function({
  required String id,
  required String entryId,
  required String accountId,
  Value<double> debit,
  Value<double> credit,
  Value<String?> memo,
  Value<int> rowid,
});
typedef $$JournalLinesTableUpdateCompanionBuilder = JournalLinesCompanion
    Function({
  Value<String> id,
  Value<String> entryId,
  Value<String> accountId,
  Value<double> debit,
  Value<double> credit,
  Value<String?> memo,
  Value<int> rowid,
});

class $$JournalLinesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalLinesTable> {
  $$JournalLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryId => $composableBuilder(
      column: $table.entryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get debit => $composableBuilder(
      column: $table.debit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get credit => $composableBuilder(
      column: $table.credit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));
}

class $$JournalLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalLinesTable> {
  $$JournalLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryId => $composableBuilder(
      column: $table.entryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get debit => $composableBuilder(
      column: $table.debit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get credit => $composableBuilder(
      column: $table.credit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));
}

class $$JournalLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalLinesTable> {
  $$JournalLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<double> get debit =>
      $composableBuilder(column: $table.debit, builder: (column) => column);

  GeneratedColumn<double> get credit =>
      $composableBuilder(column: $table.credit, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);
}

class $$JournalLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $JournalLinesTable,
    JournalLine,
    $$JournalLinesTableFilterComposer,
    $$JournalLinesTableOrderingComposer,
    $$JournalLinesTableAnnotationComposer,
    $$JournalLinesTableCreateCompanionBuilder,
    $$JournalLinesTableUpdateCompanionBuilder,
    (
      JournalLine,
      BaseReferences<_$AppDatabase, $JournalLinesTable, JournalLine>
    ),
    JournalLine,
    PrefetchHooks Function()> {
  $$JournalLinesTableTableManager(_$AppDatabase db, $JournalLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entryId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<double> debit = const Value.absent(),
            Value<double> credit = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JournalLinesCompanion(
            id: id,
            entryId: entryId,
            accountId: accountId,
            debit: debit,
            credit: credit,
            memo: memo,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entryId,
            required String accountId,
            Value<double> debit = const Value.absent(),
            Value<double> credit = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JournalLinesCompanion.insert(
            id: id,
            entryId: entryId,
            accountId: accountId,
            debit: debit,
            credit: credit,
            memo: memo,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JournalLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $JournalLinesTable,
    JournalLine,
    $$JournalLinesTableFilterComposer,
    $$JournalLinesTableOrderingComposer,
    $$JournalLinesTableAnnotationComposer,
    $$JournalLinesTableCreateCompanionBuilder,
    $$JournalLinesTableUpdateCompanionBuilder,
    (
      JournalLine,
      BaseReferences<_$AppDatabase, $JournalLinesTable, JournalLine>
    ),
    JournalLine,
    PrefetchHooks Function()>;
typedef $$BankStatementLinesTableCreateCompanionBuilder
    = BankStatementLinesCompanion Function({
  required String id,
  required String accountId,
  required String lineDate,
  required String description,
  required double amount,
  Value<String?> externalRef,
  Value<String?> matchedLineId,
  Value<String?> createdBy,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$BankStatementLinesTableUpdateCompanionBuilder
    = BankStatementLinesCompanion Function({
  Value<String> id,
  Value<String> accountId,
  Value<String> lineDate,
  Value<String> description,
  Value<double> amount,
  Value<String?> externalRef,
  Value<String?> matchedLineId,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$BankStatementLinesTableFilterComposer
    extends Composer<_$AppDatabase, $BankStatementLinesTable> {
  $$BankStatementLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lineDate => $composableBuilder(
      column: $table.lineDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalRef => $composableBuilder(
      column: $table.externalRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchedLineId => $composableBuilder(
      column: $table.matchedLineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BankStatementLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $BankStatementLinesTable> {
  $$BankStatementLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lineDate => $composableBuilder(
      column: $table.lineDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalRef => $composableBuilder(
      column: $table.externalRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchedLineId => $composableBuilder(
      column: $table.matchedLineId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BankStatementLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankStatementLinesTable> {
  $$BankStatementLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get lineDate =>
      $composableBuilder(column: $table.lineDate, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get externalRef => $composableBuilder(
      column: $table.externalRef, builder: (column) => column);

  GeneratedColumn<String> get matchedLineId => $composableBuilder(
      column: $table.matchedLineId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BankStatementLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BankStatementLinesTable,
    BankStatementLine,
    $$BankStatementLinesTableFilterComposer,
    $$BankStatementLinesTableOrderingComposer,
    $$BankStatementLinesTableAnnotationComposer,
    $$BankStatementLinesTableCreateCompanionBuilder,
    $$BankStatementLinesTableUpdateCompanionBuilder,
    (
      BankStatementLine,
      BaseReferences<_$AppDatabase, $BankStatementLinesTable, BankStatementLine>
    ),
    BankStatementLine,
    PrefetchHooks Function()> {
  $$BankStatementLinesTableTableManager(
      _$AppDatabase db, $BankStatementLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankStatementLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankStatementLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankStatementLinesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<String> lineDate = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> externalRef = const Value.absent(),
            Value<String?> matchedLineId = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BankStatementLinesCompanion(
            id: id,
            accountId: accountId,
            lineDate: lineDate,
            description: description,
            amount: amount,
            externalRef: externalRef,
            matchedLineId: matchedLineId,
            createdBy: createdBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String accountId,
            required String lineDate,
            required String description,
            required double amount,
            Value<String?> externalRef = const Value.absent(),
            Value<String?> matchedLineId = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BankStatementLinesCompanion.insert(
            id: id,
            accountId: accountId,
            lineDate: lineDate,
            description: description,
            amount: amount,
            externalRef: externalRef,
            matchedLineId: matchedLineId,
            createdBy: createdBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BankStatementLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BankStatementLinesTable,
    BankStatementLine,
    $$BankStatementLinesTableFilterComposer,
    $$BankStatementLinesTableOrderingComposer,
    $$BankStatementLinesTableAnnotationComposer,
    $$BankStatementLinesTableCreateCompanionBuilder,
    $$BankStatementLinesTableUpdateCompanionBuilder,
    (
      BankStatementLine,
      BaseReferences<_$AppDatabase, $BankStatementLinesTable, BankStatementLine>
    ),
    BankStatementLine,
    PrefetchHooks Function()>;
typedef $$DonorsTableCreateCompanionBuilder = DonorsCompanion Function({
  required String id,
  required String name,
  Value<String> donorType,
  Value<String> tier,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> notes,
  Value<bool> isActive,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$DonorsTableUpdateCompanionBuilder = DonorsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> donorType,
  Value<String> tier,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> notes,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DonorsTableFilterComposer
    extends Composer<_$AppDatabase, $DonorsTable> {
  $$DonorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get donorType => $composableBuilder(
      column: $table.donorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tier => $composableBuilder(
      column: $table.tier, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DonorsTableOrderingComposer
    extends Composer<_$AppDatabase, $DonorsTable> {
  $$DonorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get donorType => $composableBuilder(
      column: $table.donorType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tier => $composableBuilder(
      column: $table.tier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DonorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DonorsTable> {
  $$DonorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get donorType =>
      $composableBuilder(column: $table.donorType, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DonorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DonorsTable,
    Donor,
    $$DonorsTableFilterComposer,
    $$DonorsTableOrderingComposer,
    $$DonorsTableAnnotationComposer,
    $$DonorsTableCreateCompanionBuilder,
    $$DonorsTableUpdateCompanionBuilder,
    (Donor, BaseReferences<_$AppDatabase, $DonorsTable, Donor>),
    Donor,
    PrefetchHooks Function()> {
  $$DonorsTableTableManager(_$AppDatabase db, $DonorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DonorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DonorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DonorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> donorType = const Value.absent(),
            Value<String> tier = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DonorsCompanion(
            id: id,
            name: name,
            donorType: donorType,
            tier: tier,
            phone: phone,
            email: email,
            notes: notes,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> donorType = const Value.absent(),
            Value<String> tier = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DonorsCompanion.insert(
            id: id,
            name: name,
            donorType: donorType,
            tier: tier,
            phone: phone,
            email: email,
            notes: notes,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DonorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DonorsTable,
    Donor,
    $$DonorsTableFilterComposer,
    $$DonorsTableOrderingComposer,
    $$DonorsTableAnnotationComposer,
    $$DonorsTableCreateCompanionBuilder,
    $$DonorsTableUpdateCompanionBuilder,
    (Donor, BaseReferences<_$AppDatabase, $DonorsTable, Donor>),
    Donor,
    PrefetchHooks Function()>;
typedef $$PledgesTableCreateCompanionBuilder = PledgesCompanion Function({
  required String id,
  required String donorId,
  required double amount,
  Value<String> frequency,
  required String startDate,
  Value<String?> endDate,
  Value<String> status,
  Value<String?> lastFulfilledOn,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PledgesTableUpdateCompanionBuilder = PledgesCompanion Function({
  Value<String> id,
  Value<String> donorId,
  Value<double> amount,
  Value<String> frequency,
  Value<String> startDate,
  Value<String?> endDate,
  Value<String> status,
  Value<String?> lastFulfilledOn,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PledgesTableFilterComposer
    extends Composer<_$AppDatabase, $PledgesTable> {
  $$PledgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get donorId => $composableBuilder(
      column: $table.donorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastFulfilledOn => $composableBuilder(
      column: $table.lastFulfilledOn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PledgesTableOrderingComposer
    extends Composer<_$AppDatabase, $PledgesTable> {
  $$PledgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get donorId => $composableBuilder(
      column: $table.donorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastFulfilledOn => $composableBuilder(
      column: $table.lastFulfilledOn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PledgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PledgesTable> {
  $$PledgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get donorId =>
      $composableBuilder(column: $table.donorId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastFulfilledOn => $composableBuilder(
      column: $table.lastFulfilledOn, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PledgesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PledgesTable,
    Pledge,
    $$PledgesTableFilterComposer,
    $$PledgesTableOrderingComposer,
    $$PledgesTableAnnotationComposer,
    $$PledgesTableCreateCompanionBuilder,
    $$PledgesTableUpdateCompanionBuilder,
    (Pledge, BaseReferences<_$AppDatabase, $PledgesTable, Pledge>),
    Pledge,
    PrefetchHooks Function()> {
  $$PledgesTableTableManager(_$AppDatabase db, $PledgesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PledgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PledgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PledgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> donorId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> lastFulfilledOn = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PledgesCompanion(
            id: id,
            donorId: donorId,
            amount: amount,
            frequency: frequency,
            startDate: startDate,
            endDate: endDate,
            status: status,
            lastFulfilledOn: lastFulfilledOn,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String donorId,
            required double amount,
            Value<String> frequency = const Value.absent(),
            required String startDate,
            Value<String?> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> lastFulfilledOn = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PledgesCompanion.insert(
            id: id,
            donorId: donorId,
            amount: amount,
            frequency: frequency,
            startDate: startDate,
            endDate: endDate,
            status: status,
            lastFulfilledOn: lastFulfilledOn,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PledgesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PledgesTable,
    Pledge,
    $$PledgesTableFilterComposer,
    $$PledgesTableOrderingComposer,
    $$PledgesTableAnnotationComposer,
    $$PledgesTableCreateCompanionBuilder,
    $$PledgesTableUpdateCompanionBuilder,
    (Pledge, BaseReferences<_$AppDatabase, $PledgesTable, Pledge>),
    Pledge,
    PrefetchHooks Function()>;
typedef $$CampaignsTableCreateCompanionBuilder = CampaignsCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required double goalAmount,
  required String startDate,
  Value<String?> endDate,
  Value<String> status,
  Value<String?> createdBy,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CampaignsTableUpdateCompanionBuilder = CampaignsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<double> goalAmount,
  Value<String> startDate,
  Value<String?> endDate,
  Value<String> status,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CampaignsTableFilterComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get goalAmount => $composableBuilder(
      column: $table.goalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CampaignsTableOrderingComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get goalAmount => $composableBuilder(
      column: $table.goalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CampaignsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get goalAmount => $composableBuilder(
      column: $table.goalAmount, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CampaignsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CampaignsTable,
    Campaign,
    $$CampaignsTableFilterComposer,
    $$CampaignsTableOrderingComposer,
    $$CampaignsTableAnnotationComposer,
    $$CampaignsTableCreateCompanionBuilder,
    $$CampaignsTableUpdateCompanionBuilder,
    (Campaign, BaseReferences<_$AppDatabase, $CampaignsTable, Campaign>),
    Campaign,
    PrefetchHooks Function()> {
  $$CampaignsTableTableManager(_$AppDatabase db, $CampaignsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> goalAmount = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CampaignsCompanion(
            id: id,
            name: name,
            description: description,
            goalAmount: goalAmount,
            startDate: startDate,
            endDate: endDate,
            status: status,
            createdBy: createdBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required double goalAmount,
            required String startDate,
            Value<String?> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CampaignsCompanion.insert(
            id: id,
            name: name,
            description: description,
            goalAmount: goalAmount,
            startDate: startDate,
            endDate: endDate,
            status: status,
            createdBy: createdBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CampaignsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CampaignsTable,
    Campaign,
    $$CampaignsTableFilterComposer,
    $$CampaignsTableOrderingComposer,
    $$CampaignsTableAnnotationComposer,
    $$CampaignsTableCreateCompanionBuilder,
    $$CampaignsTableUpdateCompanionBuilder,
    (Campaign, BaseReferences<_$AppDatabase, $CampaignsTable, Campaign>),
    Campaign,
    PrefetchHooks Function()>;
typedef $$BeneficiariesTableCreateCompanionBuilder = BeneficiariesCompanion
    Function({
  required String id,
  required String fullName,
  Value<String?> nationalId,
  Value<String?> nationalIdSearch,
  Value<String?> phone,
  Value<int> familySize,
  Value<double> monthlyIncome,
  Value<String?> housing,
  Value<String?> caseSummary,
  Value<String> status,
  Value<String?> registeredBy,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$BeneficiariesTableUpdateCompanionBuilder = BeneficiariesCompanion
    Function({
  Value<String> id,
  Value<String> fullName,
  Value<String?> nationalId,
  Value<String?> nationalIdSearch,
  Value<String?> phone,
  Value<int> familySize,
  Value<double> monthlyIncome,
  Value<String?> housing,
  Value<String?> caseSummary,
  Value<String> status,
  Value<String?> registeredBy,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$BeneficiariesTableFilterComposer
    extends Composer<_$AppDatabase, $BeneficiariesTable> {
  $$BeneficiariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationalIdSearch => $composableBuilder(
      column: $table.nationalIdSearch,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get familySize => $composableBuilder(
      column: $table.familySize, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthlyIncome => $composableBuilder(
      column: $table.monthlyIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get housing => $composableBuilder(
      column: $table.housing, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caseSummary => $composableBuilder(
      column: $table.caseSummary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registeredBy => $composableBuilder(
      column: $table.registeredBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BeneficiariesTableOrderingComposer
    extends Composer<_$AppDatabase, $BeneficiariesTable> {
  $$BeneficiariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationalIdSearch => $composableBuilder(
      column: $table.nationalIdSearch,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get familySize => $composableBuilder(
      column: $table.familySize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthlyIncome => $composableBuilder(
      column: $table.monthlyIncome,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get housing => $composableBuilder(
      column: $table.housing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caseSummary => $composableBuilder(
      column: $table.caseSummary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registeredBy => $composableBuilder(
      column: $table.registeredBy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BeneficiariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BeneficiariesTable> {
  $$BeneficiariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => column);

  GeneratedColumn<String> get nationalIdSearch => $composableBuilder(
      column: $table.nationalIdSearch, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get familySize => $composableBuilder(
      column: $table.familySize, builder: (column) => column);

  GeneratedColumn<double> get monthlyIncome => $composableBuilder(
      column: $table.monthlyIncome, builder: (column) => column);

  GeneratedColumn<String> get housing =>
      $composableBuilder(column: $table.housing, builder: (column) => column);

  GeneratedColumn<String> get caseSummary => $composableBuilder(
      column: $table.caseSummary, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get registeredBy => $composableBuilder(
      column: $table.registeredBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BeneficiariesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BeneficiariesTable,
    Beneficiary,
    $$BeneficiariesTableFilterComposer,
    $$BeneficiariesTableOrderingComposer,
    $$BeneficiariesTableAnnotationComposer,
    $$BeneficiariesTableCreateCompanionBuilder,
    $$BeneficiariesTableUpdateCompanionBuilder,
    (
      Beneficiary,
      BaseReferences<_$AppDatabase, $BeneficiariesTable, Beneficiary>
    ),
    Beneficiary,
    PrefetchHooks Function()> {
  $$BeneficiariesTableTableManager(_$AppDatabase db, $BeneficiariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BeneficiariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BeneficiariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BeneficiariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String?> nationalId = const Value.absent(),
            Value<String?> nationalIdSearch = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<int> familySize = const Value.absent(),
            Value<double> monthlyIncome = const Value.absent(),
            Value<String?> housing = const Value.absent(),
            Value<String?> caseSummary = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> registeredBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BeneficiariesCompanion(
            id: id,
            fullName: fullName,
            nationalId: nationalId,
            nationalIdSearch: nationalIdSearch,
            phone: phone,
            familySize: familySize,
            monthlyIncome: monthlyIncome,
            housing: housing,
            caseSummary: caseSummary,
            status: status,
            registeredBy: registeredBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fullName,
            Value<String?> nationalId = const Value.absent(),
            Value<String?> nationalIdSearch = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<int> familySize = const Value.absent(),
            Value<double> monthlyIncome = const Value.absent(),
            Value<String?> housing = const Value.absent(),
            Value<String?> caseSummary = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> registeredBy = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BeneficiariesCompanion.insert(
            id: id,
            fullName: fullName,
            nationalId: nationalId,
            nationalIdSearch: nationalIdSearch,
            phone: phone,
            familySize: familySize,
            monthlyIncome: monthlyIncome,
            housing: housing,
            caseSummary: caseSummary,
            status: status,
            registeredBy: registeredBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BeneficiariesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BeneficiariesTable,
    Beneficiary,
    $$BeneficiariesTableFilterComposer,
    $$BeneficiariesTableOrderingComposer,
    $$BeneficiariesTableAnnotationComposer,
    $$BeneficiariesTableCreateCompanionBuilder,
    $$BeneficiariesTableUpdateCompanionBuilder,
    (
      Beneficiary,
      BaseReferences<_$AppDatabase, $BeneficiariesTable, Beneficiary>
    ),
    Beneficiary,
    PrefetchHooks Function()>;
typedef $$PeriodicAidsTableCreateCompanionBuilder = PeriodicAidsCompanion
    Function({
  required String id,
  required String beneficiaryId,
  required double monthlyAmount,
  required String startedOn,
  Value<String> status,
  Value<String?> lastPaidPeriod,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PeriodicAidsTableUpdateCompanionBuilder = PeriodicAidsCompanion
    Function({
  Value<String> id,
  Value<String> beneficiaryId,
  Value<double> monthlyAmount,
  Value<String> startedOn,
  Value<String> status,
  Value<String?> lastPaidPeriod,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PeriodicAidsTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodicAidsTable> {
  $$PeriodicAidsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthlyAmount => $composableBuilder(
      column: $table.monthlyAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startedOn => $composableBuilder(
      column: $table.startedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastPaidPeriod => $composableBuilder(
      column: $table.lastPaidPeriod,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PeriodicAidsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodicAidsTable> {
  $$PeriodicAidsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthlyAmount => $composableBuilder(
      column: $table.monthlyAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startedOn => $composableBuilder(
      column: $table.startedOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastPaidPeriod => $composableBuilder(
      column: $table.lastPaidPeriod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PeriodicAidsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodicAidsTable> {
  $$PeriodicAidsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<double> get monthlyAmount => $composableBuilder(
      column: $table.monthlyAmount, builder: (column) => column);

  GeneratedColumn<String> get startedOn =>
      $composableBuilder(column: $table.startedOn, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastPaidPeriod => $composableBuilder(
      column: $table.lastPaidPeriod, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PeriodicAidsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PeriodicAidsTable,
    PeriodicAid,
    $$PeriodicAidsTableFilterComposer,
    $$PeriodicAidsTableOrderingComposer,
    $$PeriodicAidsTableAnnotationComposer,
    $$PeriodicAidsTableCreateCompanionBuilder,
    $$PeriodicAidsTableUpdateCompanionBuilder,
    (
      PeriodicAid,
      BaseReferences<_$AppDatabase, $PeriodicAidsTable, PeriodicAid>
    ),
    PeriodicAid,
    PrefetchHooks Function()> {
  $$PeriodicAidsTableTableManager(_$AppDatabase db, $PeriodicAidsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodicAidsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodicAidsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodicAidsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> beneficiaryId = const Value.absent(),
            Value<double> monthlyAmount = const Value.absent(),
            Value<String> startedOn = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> lastPaidPeriod = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PeriodicAidsCompanion(
            id: id,
            beneficiaryId: beneficiaryId,
            monthlyAmount: monthlyAmount,
            startedOn: startedOn,
            status: status,
            lastPaidPeriod: lastPaidPeriod,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String beneficiaryId,
            required double monthlyAmount,
            required String startedOn,
            Value<String> status = const Value.absent(),
            Value<String?> lastPaidPeriod = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PeriodicAidsCompanion.insert(
            id: id,
            beneficiaryId: beneficiaryId,
            monthlyAmount: monthlyAmount,
            startedOn: startedOn,
            status: status,
            lastPaidPeriod: lastPaidPeriod,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PeriodicAidsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PeriodicAidsTable,
    PeriodicAid,
    $$PeriodicAidsTableFilterComposer,
    $$PeriodicAidsTableOrderingComposer,
    $$PeriodicAidsTableAnnotationComposer,
    $$PeriodicAidsTableCreateCompanionBuilder,
    $$PeriodicAidsTableUpdateCompanionBuilder,
    (
      PeriodicAid,
      BaseReferences<_$AppDatabase, $PeriodicAidsTable, PeriodicAid>
    ),
    PeriodicAid,
    PrefetchHooks Function()>;
typedef $$InKindItemsTableCreateCompanionBuilder = InKindItemsCompanion
    Function({
  required String id,
  required String name,
  Value<String> unit,
  Value<double> quantity,
  Value<double> reorderLevel,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$InKindItemsTableUpdateCompanionBuilder = InKindItemsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> unit,
  Value<double> quantity,
  Value<double> reorderLevel,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$InKindItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InKindItemsTable> {
  $$InKindItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$InKindItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InKindItemsTable> {
  $$InKindItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$InKindItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InKindItemsTable> {
  $$InKindItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InKindItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InKindItemsTable,
    InKindItem,
    $$InKindItemsTableFilterComposer,
    $$InKindItemsTableOrderingComposer,
    $$InKindItemsTableAnnotationComposer,
    $$InKindItemsTableCreateCompanionBuilder,
    $$InKindItemsTableUpdateCompanionBuilder,
    (InKindItem, BaseReferences<_$AppDatabase, $InKindItemsTable, InKindItem>),
    InKindItem,
    PrefetchHooks Function()> {
  $$InKindItemsTableTableManager(_$AppDatabase db, $InKindItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InKindItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InKindItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InKindItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> reorderLevel = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InKindItemsCompanion(
            id: id,
            name: name,
            unit: unit,
            quantity: quantity,
            reorderLevel: reorderLevel,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> unit = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> reorderLevel = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InKindItemsCompanion.insert(
            id: id,
            name: name,
            unit: unit,
            quantity: quantity,
            reorderLevel: reorderLevel,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InKindItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InKindItemsTable,
    InKindItem,
    $$InKindItemsTableFilterComposer,
    $$InKindItemsTableOrderingComposer,
    $$InKindItemsTableAnnotationComposer,
    $$InKindItemsTableCreateCompanionBuilder,
    $$InKindItemsTableUpdateCompanionBuilder,
    (InKindItem, BaseReferences<_$AppDatabase, $InKindItemsTable, InKindItem>),
    InKindItem,
    PrefetchHooks Function()>;
typedef $$InKindMovementsTableCreateCompanionBuilder = InKindMovementsCompanion
    Function({
  required String id,
  required String itemId,
  required String direction,
  required double quantity,
  required String movementDate,
  Value<String?> beneficiaryId,
  Value<String?> aidId,
  Value<String?> campaignId,
  Value<String?> note,
  Value<String?> byUserId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$InKindMovementsTableUpdateCompanionBuilder = InKindMovementsCompanion
    Function({
  Value<String> id,
  Value<String> itemId,
  Value<String> direction,
  Value<double> quantity,
  Value<String> movementDate,
  Value<String?> beneficiaryId,
  Value<String?> aidId,
  Value<String?> campaignId,
  Value<String?> note,
  Value<String?> byUserId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$InKindMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $InKindMovementsTable> {
  $$InKindMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get movementDate => $composableBuilder(
      column: $table.movementDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aidId => $composableBuilder(
      column: $table.aidId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get byUserId => $composableBuilder(
      column: $table.byUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$InKindMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $InKindMovementsTable> {
  $$InKindMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get movementDate => $composableBuilder(
      column: $table.movementDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aidId => $composableBuilder(
      column: $table.aidId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get byUserId => $composableBuilder(
      column: $table.byUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$InKindMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InKindMovementsTable> {
  $$InKindMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get movementDate => $composableBuilder(
      column: $table.movementDate, builder: (column) => column);

  GeneratedColumn<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<String> get aidId =>
      $composableBuilder(column: $table.aidId, builder: (column) => column);

  GeneratedColumn<String> get campaignId => $composableBuilder(
      column: $table.campaignId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get byUserId =>
      $composableBuilder(column: $table.byUserId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InKindMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InKindMovementsTable,
    InKindMovement,
    $$InKindMovementsTableFilterComposer,
    $$InKindMovementsTableOrderingComposer,
    $$InKindMovementsTableAnnotationComposer,
    $$InKindMovementsTableCreateCompanionBuilder,
    $$InKindMovementsTableUpdateCompanionBuilder,
    (
      InKindMovement,
      BaseReferences<_$AppDatabase, $InKindMovementsTable, InKindMovement>
    ),
    InKindMovement,
    PrefetchHooks Function()> {
  $$InKindMovementsTableTableManager(
      _$AppDatabase db, $InKindMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InKindMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InKindMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InKindMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> movementDate = const Value.absent(),
            Value<String?> beneficiaryId = const Value.absent(),
            Value<String?> aidId = const Value.absent(),
            Value<String?> campaignId = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> byUserId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InKindMovementsCompanion(
            id: id,
            itemId: itemId,
            direction: direction,
            quantity: quantity,
            movementDate: movementDate,
            beneficiaryId: beneficiaryId,
            aidId: aidId,
            campaignId: campaignId,
            note: note,
            byUserId: byUserId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            required String direction,
            required double quantity,
            required String movementDate,
            Value<String?> beneficiaryId = const Value.absent(),
            Value<String?> aidId = const Value.absent(),
            Value<String?> campaignId = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> byUserId = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InKindMovementsCompanion.insert(
            id: id,
            itemId: itemId,
            direction: direction,
            quantity: quantity,
            movementDate: movementDate,
            beneficiaryId: beneficiaryId,
            aidId: aidId,
            campaignId: campaignId,
            note: note,
            byUserId: byUserId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InKindMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InKindMovementsTable,
    InKindMovement,
    $$InKindMovementsTableFilterComposer,
    $$InKindMovementsTableOrderingComposer,
    $$InKindMovementsTableAnnotationComposer,
    $$InKindMovementsTableCreateCompanionBuilder,
    $$InKindMovementsTableUpdateCompanionBuilder,
    (
      InKindMovement,
      BaseReferences<_$AppDatabase, $InKindMovementsTable, InKindMovement>
    ),
    InKindMovement,
    PrefetchHooks Function()>;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String id,
  required String period,
  required String accountId,
  required double plannedAmount,
  Value<String?> createdBy,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String> period,
  Value<String> accountId,
  Value<double> plannedAmount,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get plannedAmount => $composableBuilder(
      column: $table.plannedAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get plannedAmount => $composableBuilder(
      column: $table.plannedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<double> get plannedAmount => $composableBuilder(
      column: $table.plannedAmount, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
    Budget,
    PrefetchHooks Function()> {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<double> plannedAmount = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            period: period,
            accountId: accountId,
            plannedAmount: plannedAmount,
            createdBy: createdBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String period,
            required String accountId,
            required double plannedAmount,
            Value<String?> createdBy = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            period: period,
            accountId: accountId,
            plannedAmount: plannedAmount,
            createdBy: createdBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
    Budget,
    PrefetchHooks Function()>;
typedef $$OtpCodesTableCreateCompanionBuilder = OtpCodesCompanion Function({
  required String id,
  required String token,
  required String userId,
  required String codeHash,
  required DateTime expiresAt,
  Value<bool> consumed,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$OtpCodesTableUpdateCompanionBuilder = OtpCodesCompanion Function({
  Value<String> id,
  Value<String> token,
  Value<String> userId,
  Value<String> codeHash,
  Value<DateTime> expiresAt,
  Value<bool> consumed,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$OtpCodesTableFilterComposer
    extends Composer<_$AppDatabase, $OtpCodesTable> {
  $$OtpCodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get codeHash => $composableBuilder(
      column: $table.codeHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get consumed => $composableBuilder(
      column: $table.consumed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OtpCodesTableOrderingComposer
    extends Composer<_$AppDatabase, $OtpCodesTable> {
  $$OtpCodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get codeHash => $composableBuilder(
      column: $table.codeHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get consumed => $composableBuilder(
      column: $table.consumed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OtpCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OtpCodesTable> {
  $$OtpCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get codeHash =>
      $composableBuilder(column: $table.codeHash, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get consumed =>
      $composableBuilder(column: $table.consumed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OtpCodesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OtpCodesTable,
    OtpCode,
    $$OtpCodesTableFilterComposer,
    $$OtpCodesTableOrderingComposer,
    $$OtpCodesTableAnnotationComposer,
    $$OtpCodesTableCreateCompanionBuilder,
    $$OtpCodesTableUpdateCompanionBuilder,
    (OtpCode, BaseReferences<_$AppDatabase, $OtpCodesTable, OtpCode>),
    OtpCode,
    PrefetchHooks Function()> {
  $$OtpCodesTableTableManager(_$AppDatabase db, $OtpCodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OtpCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OtpCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OtpCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> token = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> codeHash = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<bool> consumed = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OtpCodesCompanion(
            id: id,
            token: token,
            userId: userId,
            codeHash: codeHash,
            expiresAt: expiresAt,
            consumed: consumed,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String token,
            required String userId,
            required String codeHash,
            required DateTime expiresAt,
            Value<bool> consumed = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              OtpCodesCompanion.insert(
            id: id,
            token: token,
            userId: userId,
            codeHash: codeHash,
            expiresAt: expiresAt,
            consumed: consumed,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OtpCodesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OtpCodesTable,
    OtpCode,
    $$OtpCodesTableFilterComposer,
    $$OtpCodesTableOrderingComposer,
    $$OtpCodesTableAnnotationComposer,
    $$OtpCodesTableCreateCompanionBuilder,
    $$OtpCodesTableUpdateCompanionBuilder,
    (OtpCode, BaseReferences<_$AppDatabase, $OtpCodesTable, OtpCode>),
    OtpCode,
    PrefetchHooks Function()>;
typedef $$RefreshSessionsTableCreateCompanionBuilder = RefreshSessionsCompanion
    Function({
  required String id,
  required String userId,
  required String tokenHash,
  Value<String?> deviceId,
  Value<String?> ipAddress,
  required DateTime expiresAt,
  Value<bool> revoked,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$RefreshSessionsTableUpdateCompanionBuilder = RefreshSessionsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> tokenHash,
  Value<String?> deviceId,
  Value<String?> ipAddress,
  Value<DateTime> expiresAt,
  Value<bool> revoked,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$RefreshSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $RefreshSessionsTable> {
  $$RefreshSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tokenHash => $composableBuilder(
      column: $table.tokenHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ipAddress => $composableBuilder(
      column: $table.ipAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get revoked => $composableBuilder(
      column: $table.revoked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RefreshSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RefreshSessionsTable> {
  $$RefreshSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tokenHash => $composableBuilder(
      column: $table.tokenHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ipAddress => $composableBuilder(
      column: $table.ipAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get revoked => $composableBuilder(
      column: $table.revoked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RefreshSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RefreshSessionsTable> {
  $$RefreshSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get tokenHash =>
      $composableBuilder(column: $table.tokenHash, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get revoked =>
      $composableBuilder(column: $table.revoked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RefreshSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RefreshSessionsTable,
    RefreshSession,
    $$RefreshSessionsTableFilterComposer,
    $$RefreshSessionsTableOrderingComposer,
    $$RefreshSessionsTableAnnotationComposer,
    $$RefreshSessionsTableCreateCompanionBuilder,
    $$RefreshSessionsTableUpdateCompanionBuilder,
    (
      RefreshSession,
      BaseReferences<_$AppDatabase, $RefreshSessionsTable, RefreshSession>
    ),
    RefreshSession,
    PrefetchHooks Function()> {
  $$RefreshSessionsTableTableManager(
      _$AppDatabase db, $RefreshSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefreshSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RefreshSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RefreshSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> tokenHash = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> ipAddress = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<bool> revoked = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RefreshSessionsCompanion(
            id: id,
            userId: userId,
            tokenHash: tokenHash,
            deviceId: deviceId,
            ipAddress: ipAddress,
            expiresAt: expiresAt,
            revoked: revoked,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String tokenHash,
            Value<String?> deviceId = const Value.absent(),
            Value<String?> ipAddress = const Value.absent(),
            required DateTime expiresAt,
            Value<bool> revoked = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RefreshSessionsCompanion.insert(
            id: id,
            userId: userId,
            tokenHash: tokenHash,
            deviceId: deviceId,
            ipAddress: ipAddress,
            expiresAt: expiresAt,
            revoked: revoked,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RefreshSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RefreshSessionsTable,
    RefreshSession,
    $$RefreshSessionsTableFilterComposer,
    $$RefreshSessionsTableOrderingComposer,
    $$RefreshSessionsTableAnnotationComposer,
    $$RefreshSessionsTableCreateCompanionBuilder,
    $$RefreshSessionsTableUpdateCompanionBuilder,
    (
      RefreshSession,
      BaseReferences<_$AppDatabase, $RefreshSessionsTable, RefreshSession>
    ),
    RefreshSession,
    PrefetchHooks Function()>;
typedef $$DeviceTokensTableCreateCompanionBuilder = DeviceTokensCompanion
    Function({
  required String id,
  required String userId,
  required String token,
  Value<String?> platform,
  required DateTime createdAt,
  required DateTime lastUsedAt,
  Value<int> rowid,
});
typedef $$DeviceTokensTableUpdateCompanionBuilder = DeviceTokensCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> token,
  Value<String?> platform,
  Value<DateTime> createdAt,
  Value<DateTime> lastUsedAt,
  Value<int> rowid,
});

class $$DeviceTokensTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceTokensTable> {
  $$DeviceTokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnFilters(column));
}

class $$DeviceTokensTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceTokensTable> {
  $$DeviceTokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnOrderings(column));
}

class $$DeviceTokensTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceTokensTable> {
  $$DeviceTokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => column);
}

class $$DeviceTokensTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeviceTokensTable,
    DeviceToken,
    $$DeviceTokensTableFilterComposer,
    $$DeviceTokensTableOrderingComposer,
    $$DeviceTokensTableAnnotationComposer,
    $$DeviceTokensTableCreateCompanionBuilder,
    $$DeviceTokensTableUpdateCompanionBuilder,
    (
      DeviceToken,
      BaseReferences<_$AppDatabase, $DeviceTokensTable, DeviceToken>
    ),
    DeviceToken,
    PrefetchHooks Function()> {
  $$DeviceTokensTableTableManager(_$AppDatabase db, $DeviceTokensTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceTokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceTokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceTokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> token = const Value.absent(),
            Value<String?> platform = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUsedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeviceTokensCompanion(
            id: id,
            userId: userId,
            token: token,
            platform: platform,
            createdAt: createdAt,
            lastUsedAt: lastUsedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String token,
            Value<String?> platform = const Value.absent(),
            required DateTime createdAt,
            required DateTime lastUsedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DeviceTokensCompanion.insert(
            id: id,
            userId: userId,
            token: token,
            platform: platform,
            createdAt: createdAt,
            lastUsedAt: lastUsedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeviceTokensTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeviceTokensTable,
    DeviceToken,
    $$DeviceTokensTableFilterComposer,
    $$DeviceTokensTableOrderingComposer,
    $$DeviceTokensTableAnnotationComposer,
    $$DeviceTokensTableCreateCompanionBuilder,
    $$DeviceTokensTableUpdateCompanionBuilder,
    (
      DeviceToken,
      BaseReferences<_$AppDatabase, $DeviceTokensTable, DeviceToken>
    ),
    DeviceToken,
    PrefetchHooks Function()>;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  required String id,
  required DateTime timestamp,
  Value<String?> userId,
  Value<String?> userName,
  required String action,
  required String resourceType,
  Value<String?> resourceId,
  Value<String?> summary,
  Value<String?> changes,
  Value<String?> ipAddress,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<DateTime> timestamp,
  Value<String?> userId,
  Value<String?> userName,
  Value<String> action,
  Value<String> resourceType,
  Value<String?> resourceId,
  Value<String?> summary,
  Value<String?> changes,
  Value<String?> ipAddress,
  Value<String?> deviceId,
  Value<int> rowid,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resourceType => $composableBuilder(
      column: $table.resourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changes => $composableBuilder(
      column: $table.changes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ipAddress => $composableBuilder(
      column: $table.ipAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resourceType => $composableBuilder(
      column: $table.resourceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changes => $composableBuilder(
      column: $table.changes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ipAddress => $composableBuilder(
      column: $table.ipAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get resourceType => $composableBuilder(
      column: $table.resourceType, builder: (column) => column);

  GeneratedColumn<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get changes =>
      $composableBuilder(column: $table.changes, builder: (column) => column);

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$AuditLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogsTable,
    AuditLog,
    $$AuditLogsTableFilterComposer,
    $$AuditLogsTableOrderingComposer,
    $$AuditLogsTableAnnotationComposer,
    $$AuditLogsTableCreateCompanionBuilder,
    $$AuditLogsTableUpdateCompanionBuilder,
    (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
    AuditLog,
    PrefetchHooks Function()> {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> userName = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> resourceType = const Value.absent(),
            Value<String?> resourceId = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<String?> changes = const Value.absent(),
            Value<String?> ipAddress = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogsCompanion(
            id: id,
            timestamp: timestamp,
            userId: userId,
            userName: userName,
            action: action,
            resourceType: resourceType,
            resourceId: resourceId,
            summary: summary,
            changes: changes,
            ipAddress: ipAddress,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime timestamp,
            Value<String?> userId = const Value.absent(),
            Value<String?> userName = const Value.absent(),
            required String action,
            required String resourceType,
            Value<String?> resourceId = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<String?> changes = const Value.absent(),
            Value<String?> ipAddress = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogsCompanion.insert(
            id: id,
            timestamp: timestamp,
            userId: userId,
            userName: userName,
            action: action,
            resourceType: resourceType,
            resourceId: resourceId,
            summary: summary,
            changes: changes,
            ipAddress: ipAddress,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AuditLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditLogsTable,
    AuditLog,
    $$AuditLogsTableFilterComposer,
    $$AuditLogsTableOrderingComposer,
    $$AuditLogsTableAnnotationComposer,
    $$AuditLogsTableCreateCompanionBuilder,
    $$AuditLogsTableUpdateCompanionBuilder,
    (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
    AuditLog,
    PrefetchHooks Function()>;
typedef $$CountersTableCreateCompanionBuilder = CountersCompanion Function({
  required String name,
  Value<int> value,
  Value<int> rowid,
});
typedef $$CountersTableUpdateCompanionBuilder = CountersCompanion Function({
  Value<String> name,
  Value<int> value,
  Value<int> rowid,
});

class $$CountersTableFilterComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$CountersTableOrderingComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$CountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$CountersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CountersTable,
    Counter,
    $$CountersTableFilterComposer,
    $$CountersTableOrderingComposer,
    $$CountersTableAnnotationComposer,
    $$CountersTableCreateCompanionBuilder,
    $$CountersTableUpdateCompanionBuilder,
    (Counter, BaseReferences<_$AppDatabase, $CountersTable, Counter>),
    Counter,
    PrefetchHooks Function()> {
  $$CountersTableTableManager(_$AppDatabase db, $CountersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> name = const Value.absent(),
            Value<int> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountersCompanion(
            name: name,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String name,
            Value<int> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountersCompanion.insert(
            name: name,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CountersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CountersTable,
    Counter,
    $$CountersTableFilterComposer,
    $$CountersTableOrderingComposer,
    $$CountersTableAnnotationComposer,
    $$CountersTableCreateCompanionBuilder,
    $$CountersTableUpdateCompanionBuilder,
    (Counter, BaseReferences<_$AppDatabase, $CountersTable, Counter>),
    Counter,
    PrefetchHooks Function()>;
typedef $$CurrenciesTableCreateCompanionBuilder = CurrenciesCompanion Function({
  required String id,
  required String code,
  required String nameAr,
  required String symbol,
  Value<int> decimals,
  Value<double> rate,
  Value<bool> isLocal,
  Value<bool> isDefault,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CurrenciesTableUpdateCompanionBuilder = CurrenciesCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<String> nameAr,
  Value<String> symbol,
  Value<int> decimals,
  Value<double> rate,
  Value<bool> isLocal,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CurrenciesTableFilterComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameAr => $composableBuilder(
      column: $table.nameAr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get decimals => $composableBuilder(
      column: $table.decimals, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rate => $composableBuilder(
      column: $table.rate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLocal => $composableBuilder(
      column: $table.isLocal, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CurrenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameAr => $composableBuilder(
      column: $table.nameAr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get decimals => $composableBuilder(
      column: $table.decimals, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rate => $composableBuilder(
      column: $table.rate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLocal => $composableBuilder(
      column: $table.isLocal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CurrenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<int> get decimals =>
      $composableBuilder(column: $table.decimals, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<bool> get isLocal =>
      $composableBuilder(column: $table.isLocal, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CurrenciesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CurrenciesTable,
    Currency,
    $$CurrenciesTableFilterComposer,
    $$CurrenciesTableOrderingComposer,
    $$CurrenciesTableAnnotationComposer,
    $$CurrenciesTableCreateCompanionBuilder,
    $$CurrenciesTableUpdateCompanionBuilder,
    (Currency, BaseReferences<_$AppDatabase, $CurrenciesTable, Currency>),
    Currency,
    PrefetchHooks Function()> {
  $$CurrenciesTableTableManager(_$AppDatabase db, $CurrenciesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> nameAr = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<int> decimals = const Value.absent(),
            Value<double> rate = const Value.absent(),
            Value<bool> isLocal = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CurrenciesCompanion(
            id: id,
            code: code,
            nameAr: nameAr,
            symbol: symbol,
            decimals: decimals,
            rate: rate,
            isLocal: isLocal,
            isDefault: isDefault,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String code,
            required String nameAr,
            required String symbol,
            Value<int> decimals = const Value.absent(),
            Value<double> rate = const Value.absent(),
            Value<bool> isLocal = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CurrenciesCompanion.insert(
            id: id,
            code: code,
            nameAr: nameAr,
            symbol: symbol,
            decimals: decimals,
            rate: rate,
            isLocal: isLocal,
            isDefault: isDefault,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CurrenciesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CurrenciesTable,
    Currency,
    $$CurrenciesTableFilterComposer,
    $$CurrenciesTableOrderingComposer,
    $$CurrenciesTableAnnotationComposer,
    $$CurrenciesTableCreateCompanionBuilder,
    $$CurrenciesTableUpdateCompanionBuilder,
    (Currency, BaseReferences<_$AppDatabase, $CurrenciesTable, Currency>),
    Currency,
    PrefetchHooks Function()>;
typedef $$CurrencyRatesTableCreateCompanionBuilder = CurrencyRatesCompanion
    Function({
  required String id,
  required String currencyCode,
  required double rate,
  Value<String?> changedBy,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CurrencyRatesTableUpdateCompanionBuilder = CurrencyRatesCompanion
    Function({
  Value<String> id,
  Value<String> currencyCode,
  Value<double> rate,
  Value<String?> changedBy,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CurrencyRatesTableFilterComposer
    extends Composer<_$AppDatabase, $CurrencyRatesTable> {
  $$CurrencyRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rate => $composableBuilder(
      column: $table.rate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changedBy => $composableBuilder(
      column: $table.changedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CurrencyRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrencyRatesTable> {
  $$CurrencyRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rate => $composableBuilder(
      column: $table.rate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changedBy => $composableBuilder(
      column: $table.changedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CurrencyRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrencyRatesTable> {
  $$CurrencyRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<String> get changedBy =>
      $composableBuilder(column: $table.changedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CurrencyRatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CurrencyRatesTable,
    CurrencyRate,
    $$CurrencyRatesTableFilterComposer,
    $$CurrencyRatesTableOrderingComposer,
    $$CurrencyRatesTableAnnotationComposer,
    $$CurrencyRatesTableCreateCompanionBuilder,
    $$CurrencyRatesTableUpdateCompanionBuilder,
    (
      CurrencyRate,
      BaseReferences<_$AppDatabase, $CurrencyRatesTable, CurrencyRate>
    ),
    CurrencyRate,
    PrefetchHooks Function()> {
  $$CurrencyRatesTableTableManager(_$AppDatabase db, $CurrencyRatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrencyRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrencyRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrencyRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<double> rate = const Value.absent(),
            Value<String?> changedBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CurrencyRatesCompanion(
            id: id,
            currencyCode: currencyCode,
            rate: rate,
            changedBy: changedBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String currencyCode,
            required double rate,
            Value<String?> changedBy = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CurrencyRatesCompanion.insert(
            id: id,
            currencyCode: currencyCode,
            rate: rate,
            changedBy: changedBy,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CurrencyRatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CurrencyRatesTable,
    CurrencyRate,
    $$CurrencyRatesTableFilterComposer,
    $$CurrencyRatesTableOrderingComposer,
    $$CurrencyRatesTableAnnotationComposer,
    $$CurrencyRatesTableCreateCompanionBuilder,
    $$CurrencyRatesTableUpdateCompanionBuilder,
    (
      CurrencyRate,
      BaseReferences<_$AppDatabase, $CurrencyRatesTable, CurrencyRate>
    ),
    CurrencyRate,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$AidRequestsTableTableManager get aidRequests =>
      $$AidRequestsTableTableManager(_db, _db.aidRequests);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$TreasuryEntriesTableTableManager get treasuryEntries =>
      $$TreasuryEntriesTableTableManager(_db, _db.treasuryEntries);
  $$VouchersTableTableManager get vouchers =>
      $$VouchersTableTableManager(_db, _db.vouchers);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$FundSettingsTableTableManager get fundSettings =>
      $$FundSettingsTableTableManager(_db, _db.fundSettings);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$JournalLinesTableTableManager get journalLines =>
      $$JournalLinesTableTableManager(_db, _db.journalLines);
  $$BankStatementLinesTableTableManager get bankStatementLines =>
      $$BankStatementLinesTableTableManager(_db, _db.bankStatementLines);
  $$DonorsTableTableManager get donors =>
      $$DonorsTableTableManager(_db, _db.donors);
  $$PledgesTableTableManager get pledges =>
      $$PledgesTableTableManager(_db, _db.pledges);
  $$CampaignsTableTableManager get campaigns =>
      $$CampaignsTableTableManager(_db, _db.campaigns);
  $$BeneficiariesTableTableManager get beneficiaries =>
      $$BeneficiariesTableTableManager(_db, _db.beneficiaries);
  $$PeriodicAidsTableTableManager get periodicAids =>
      $$PeriodicAidsTableTableManager(_db, _db.periodicAids);
  $$InKindItemsTableTableManager get inKindItems =>
      $$InKindItemsTableTableManager(_db, _db.inKindItems);
  $$InKindMovementsTableTableManager get inKindMovements =>
      $$InKindMovementsTableTableManager(_db, _db.inKindMovements);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$OtpCodesTableTableManager get otpCodes =>
      $$OtpCodesTableTableManager(_db, _db.otpCodes);
  $$RefreshSessionsTableTableManager get refreshSessions =>
      $$RefreshSessionsTableTableManager(_db, _db.refreshSessions);
  $$DeviceTokensTableTableManager get deviceTokens =>
      $$DeviceTokensTableTableManager(_db, _db.deviceTokens);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db, _db.counters);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db, _db.currencies);
  $$CurrencyRatesTableTableManager get currencyRates =>
      $$CurrencyRatesTableTableManager(_db, _db.currencyRates);
}
