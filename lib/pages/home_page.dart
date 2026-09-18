import 'package:flutter/material.dart';
import '../main.dart';
import '../models/profile.dart';
import 'admin_page.dart';
import 'announcements_page.dart';
import 'directory_page.dart';
import 'emergency_page.dart';
import 'schedule_page.dart';
import 'login_page.dart';
import '../services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profile = SessionContext.currentProfile;
    final isStaff = profile?.isStaff ?? false;
    final isAdmin = profile?.isAdmin ?? false;

    final pages = <Widget>[
      const SchedulePage(),
      const EmergencyPage(),
      const DirectoryPage(),
      const AnnouncementsPage(),
      if (isStaff) AdminPage(isAdmin: isAdmin),
    ];

    final destinations = <Widget>[
      const NavigationDestination(icon: Icon(Icons.event_note), label: 'Schedule'),
      const NavigationDestination(icon: Icon(Icons.sos), label: 'Emergency'),
      const NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Directory'),
      const NavigationDestination(icon: Icon(Icons.campaign), label: 'Advisories'),
      if (isStaff)
        NavigationDestination(
          icon: Icon(isAdmin ? Icons.admin_panel_settings : Icons.badge),
          label: isAdmin ? 'Admin' : 'Officer',
        ),
    ];

    return Scaffold(
      appBar: GradientAppBar(
        title: isAdmin
            ? 'MedAlert — Admin'
            : (isStaff ? 'MedAlert — Health Officer' : 'MedAlert'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await SupabaseService.instance.signOut();
              SessionContext.currentProfile = null;
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: pages[_currentIndex.clamp(0, pages.length - 1)],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex.clamp(0, pages.length - 1),
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: destinations,
      ),
    );
  }
}