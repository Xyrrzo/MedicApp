import 'package:flutter/material.dart';
import '../models/health_unit.dart';

class HealthUnitCard extends StatelessWidget {
  final HealthUnit unit;
  final VoidCallback? onCall;

  const HealthUnitCard({super.key, required this.unit, this.onCall});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          Icons.local_hospital,
          color: unit.isOpen ? Colors.green : Colors.grey,
        ),
        title: Text(unit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${unit.address}\n${unit.openTime} - ${unit.closeTime}'),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.teal),
          onPressed: onCall,
        ),
      ),
    );
  }
}