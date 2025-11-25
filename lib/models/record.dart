import 'package:uuid/uuid.dart';

class Record {
  final String id;
  final String type; // 'resisted' or 'smoked'
  final int? start; // timestamp in seconds
  final int? end; // timestamp in seconds
  final int? duration; // in seconds
  final String? reason;

  Record({
    required this.id,
    required this.type,
    this.start,
    this.end,
    this.duration,
    this.reason,
  });

  factory Record.resisted({required int start, required int end}) {
    return Record(
      id: const Uuid().v4(),
      type: 'resisted',
      start: start,
      end: end,
      duration: end - start,
    );
  }

  factory Record.smoked({String? reason}) {
    return Record(
      id: const Uuid().v4(),
      type: 'smoked',
      start: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      reason: reason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'start': start,
      'end': end,
      'duration': duration,
      'reason': reason,
    };
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'],
      type: json['type'],
      start: json['start'],
      end: json['end'],
      duration: json['duration'],
      reason: json['reason'],
    );
  }
}
