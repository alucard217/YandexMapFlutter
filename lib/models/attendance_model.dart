class Attendance {
  final String id;
  final String fieldId;
  final String date;
  final int count;

  Attendance({
    required this.id,
    required this.fieldId,
    required this.date,
    required this.count,
  });

  factory Attendance.fromMap(String id, Map<String, dynamic> data) {
    return Attendance(
      id: id,
      fieldId: data['fieldId'] ?? '',
      date: data['date'] ?? '',
      count: data['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fieldId': fieldId,
      'date': date,
      'count': count,
    };
  }
}
