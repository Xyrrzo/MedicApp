import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;

  const AppointmentCard({super.key, required this.appointment, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final isCancelled = appointment.status == 'cancelled';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          Icons.event,
          color: isCancelled ? Colors.grey : Colors.teal,
        ),
        title: Text(
          '${appointment.type.toUpperCase()} — ${appointment.healthUnitName ?? ''}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isCancelled ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${appointment.date} at ${appointment.time}\nStatus: ${appointment.status}'),
        isThreeLine: true,
        trailing: isCancelled
            ? null
            : TextButton(
                onPressed: onCancel,
                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
      ),
    );
  }
}