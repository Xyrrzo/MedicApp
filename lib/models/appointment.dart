class Appointment {
  final int id;
  final String type;
  final String date;
  final String time;
  final String status;
  final String? healthUnitName;
  final String? notes;
  // Staff-only fields (patient info, populated when staff queries all appointments)
  final String? patientName;
  final String? patientPhone;

  Appointment({
    required this.id,
    required this.type,
    required this.date,
    required this.time,
    required this.status,
    this.healthUnitName,
    this.notes,
    this.patientName,
    this.patientPhone,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'],
        type: json['appointment_type'],
        date: json['appointment_date'],
        time: json['appointment_time'],
        status: json['status'],
        healthUnitName: json['health_units']?['name'],
        notes: json['notes'],
        patientName: json['profiles']?['full_name'],
        patientPhone: json['profiles']?['phone'],
      );
}