import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/directory_controller.dart';
import '../utils/constants.dart';
import '../widgets/health_unit_card.dart';

class DirectoryPage extends StatefulWidget {
  const DirectoryPage({super.key});

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  final _controller = DirectoryController();

  @override
  void initState() {
    super.initState();
    _controller.loadUnits();
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.error != null) {
          return Center(child: Text('Error: ${_controller.error}'));
        }
        return RefreshIndicator(
          color: AppConstants.redPrimary,
          onRefresh: _controller.loadUnits,
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Nearby Health Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ..._controller.units.map(
                (u) => HealthUnitCard(unit: u, onCall: () => _call(u.phone)),
              ),
            ],
          ),
        );
      },
    );
  }
}