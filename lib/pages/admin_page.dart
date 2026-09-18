import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/admin_controller.dart';
import '../models/health_unit.dart';
import '../utils/constants.dart';

/// Dashboard for health officers and admins.
/// Admin additionally gets: delete health units + delete announcements.
class AdminPage extends StatefulWidget {
  final bool isAdmin;
  const AdminPage({super.key, required this.isAdmin});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _controller = AdminController();

  @override
  void initState() {
    super.initState();
    _controller.loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) return const Center(child: CircularProgressIndicator());
        return DefaultTabController(
          length: 4,
          child: Column(
            children: [
              const TabBar(
                isScrollable: true,
                labelColor: AppConstants.redPrimary,
                tabs: [
                  Tab(text: 'Queue'),
                  Tab(text: 'Emergency'),
                  Tab(text: 'Units'),
                  Tab(text: 'Publish'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _QueueTab(controller: _controller),
                    _EmergencyReportsTab(controller: _controller),
                    _UnitsTab(controller: _controller, isAdmin: widget.isAdmin),
                    _PublishTab(controller: _controller, isAdmin: widget.isAdmin),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============ TAB 1: APPOINTMENT QUEUE ============
class _QueueTab extends StatelessWidget {
  final AdminController controller;
  const _QueueTab({required this.controller});

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.allAppointments.isEmpty) {
      return const Center(child: Text('No appointments yet.'));
    }
    return ListView.builder(
      itemCount: controller.allAppointments.length,
      itemBuilder: (context, i) {
        final a = controller.allAppointments[i];
        final isPending = a.status == 'pending';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _statusColor(a.status).withOpacity(0.15),
              child: Icon(Icons.person, color: _statusColor(a.status)),
            ),
            title: Text('${a.patientName ?? 'Patient'} — ${a.type.toUpperCase()}'),
            subtitle: Text('${a.healthUnitName ?? ''}\n${a.date} at ${a.time}  •  ${a.status.toUpperCase()}'),
            isThreeLine: true,
            trailing: isPending
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Confirm',
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => controller.setStatus(a.id, 'confirmed'),
                      ),
                      IconButton(
                        tooltip: 'Complete',
                        icon: const Icon(Icons.done_all, color: Colors.blue),
                        onPressed: () => controller.setStatus(a.id, 'completed'),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}

// ============ TAB 2: EMERGENCY SYMPTOM REPORTS ============
class _EmergencyReportsTab extends StatelessWidget {
  final AdminController controller;
  const _EmergencyReportsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.symptomReports.isEmpty) {
      return const Center(child: Text('No emergency reports.'));
    }
    return ListView.builder(
      itemCount: controller.symptomReports.length,
      itemBuilder: (context, i) {
        final r = controller.symptomReports[i];
        final symptoms = (r['symptoms'] as Map).entries
            .where((e) => e.value == true)
            .map((e) => e.key)
            .join(', ');
        final handled = r['handled'] == true;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: Icon(
              handled ? Icons.mark_email_read : Icons.priority_high,
              color: handled ? Colors.grey : AppConstants.redPrimary,
            ),
            title: Text('${r['profiles']?['full_name'] ?? 'Unknown'} — ${r['severity'].toString().toUpperCase()}'),
            subtitle: Text(
              '${DateFormat('MMM d, h:mm a').format(DateTime.parse(r['created_at']).toLocal())}\n'
              'Symptoms: ${symptoms.isEmpty ? 'none specified' : symptoms}'
              '${r['notes'] != null ? '\nNotes: ${r['notes']}' : ''}',
            ),
            isThreeLine: true,
            trailing: handled
                ? const Text('Handled', style: TextStyle(color: Colors.grey))
                : TextButton(
                    onPressed: () => controller.markHandled(r['id']),
                    child: const Text('Mark handled'),
                  ),
          ),
        );
      },
    );
  }
}

// ============ TAB 3: HEALTH UNIT MANAGEMENT ============
class _UnitsTab extends StatelessWidget {
  final AdminController controller;
  final bool isAdmin;
  const _UnitsTab({required this.controller, required this.isAdmin});

  Future<void> _showUnitDialog(BuildContext context, {HealthUnit? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name);
    final addrCtrl = TextEditingController(text: existing?.address);
    final phoneCtrl = TextEditingController(text: existing?.phone);
    final openCtrl = TextEditingController(text: existing?.openTime ?? '08:00');
    final closeCtrl = TextEditingController(text: existing?.closeTime ?? '17:00');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Health Unit' : 'Edit Health Unit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: openCtrl, decoration: const InputDecoration(labelText: 'Opens (HH:MM)')),
              TextField(controller: closeCtrl, decoration: const InputDecoration(labelText: 'Closes (HH:MM)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok == true) {
      final fields = {
        'name': nameCtrl.text,
        'address': addrCtrl.text,
        'phone': phoneCtrl.text,
        'open_time': openCtrl.text,
        'close_time': closeCtrl.text,
      };
      if (existing == null) {
        await controller.addUnit(
          name: nameCtrl.text,
          address: addrCtrl.text,
          phone: phoneCtrl.text,
          openTime: openCtrl.text,
          closeTime: closeCtrl.text,
        );
      } else {
        await controller.updateUnit(existing.id, fields);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.redPrimary,
        foregroundColor: Colors.white,
        onPressed: () => _showUnitDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: controller.units.length,
        itemBuilder: (context, i) {
          final u = controller.units[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: Icon(Icons.local_hospital, color: u.isOpen ? Colors.green : Colors.grey),
              title: Text(u.name),
              subtitle: Text('${u.address}\n${u.openTime} - ${u.closeTime} • ${u.phone}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: u.isOpen ? 'Close now' : 'Open now',
                    icon: Icon(u.isOpen ? Icons.toggle_on : Icons.toggle_off,
                        color: u.isOpen ? Colors.green : Colors.grey),
                    onPressed: () => controller.toggleUnitOpen(u.id, !u.isOpen),
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showUnitDialog(context, existing: u),
                  ),
                  if (isAdmin)
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.deleteUnit(u.id),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============ TAB 4: PUBLISH ADVISORY ============
class _PublishTab extends StatefulWidget {
  final AdminController controller;
  final bool isAdmin;
  const _PublishTab({required this.controller, required this.isAdmin});

  @override
  State<_PublishTab> createState() => _PublishTabState();
}

class _PublishTabState extends State<_PublishTab> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _category = 'general';
  bool _busy = false;

  Future<void> _publish() async {
    setState(() => _busy = true);
    final ok = await widget.controller.postAnnouncement(
      title: _titleCtrl.text,
      body: _bodyCtrl.text,
      category: _category,
    );
    setState(() => _busy = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Advisory published!' : 'Failed to publish.')),
    );
    if (ok) {
      _titleCtrl.clear();
      _bodyCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Publish a Health Advisory',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bodyCtrl,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Body',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
          items: AppConstants.announcementCategories
              .map((c) => DropdownMenuItem(
                  value: c, child: Text(c.replaceAll('_', ' ').toUpperCase())))
              .toList(),
          onChanged: (v) => setState(() => _category = v!),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _busy ? null : _publish,
            icon: const Icon(Icons.send),
            label: const Text('Publish'),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Manage Advisories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...widget.controller.announcements.map((ann) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(ann.title),
                subtitle: Text(ann.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: widget.isAdmin
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => widget.controller.deleteAnnouncement(ann.id),
                      )
                    : null,
              ),
            )),
      ],
    );
  }
}