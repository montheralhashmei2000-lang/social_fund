import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/events_repository.dart';
import '../middleware.dart';

class EventsRoutes {
  final AppDatabase db;
  EventsRoutes(this.db);

  Router get router {
    final r = Router();
    final repo = EventsRepository(db);

    r.get('/events', (Request req) async {
      final list = await repo.list();
      return jsonOk(list.map(_toJson).toList());
    });

    r.post('/events', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final title = (b['title'] ?? '').toString();
      final date = (b['event_date'] ?? '').toString();
      if (title.isEmpty || date.isEmpty) return jsonErr(400, 'title and event_date required');
      final e = await repo.create(
        title: title, eventDate: date,
        eventTime: b['event_time'] as String?, place: b['place'] as String?,
        type: b['type'] as String?, color: (b['color'] ?? '#1B5E20').toString(),
      );
      return jsonOk(_toJson(e));
    });

    r.delete('/events/<id>', (Request req, String id) async {
      await repo.softDelete(id);
      return jsonOk({'ok': true});
    });

    return r;
  }

  static Map<String, dynamic> _toJson(Event e) => {
    'id': e.id, 'title': e.title, 'event_date': e.eventDate,
    'event_time': e.eventTime, 'place': e.place, 'type': e.type, 'color': e.color,
  };
}
