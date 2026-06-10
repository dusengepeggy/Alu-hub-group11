import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/user.dart';
import 'feed_screen.dart';
import 'my_events_screen.dart';
import 'create_opportunity_screen.dart';
import 'admin_panel_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    final role = user?.role ?? UserRole.student;

    final tabs = <_NavTab>[
      _NavTab(
        const FeedScreen(),
        Icons.explore_outlined,
        'Feed',
      ),
      _NavTab(
        const MyEventsScreen(),
        Icons.event_available_outlined,
        'My Events',
      ),
      if (role.canPost)
        _NavTab(
          const CreateOpportunityScreen(),
          Icons.add_circle_outline,
          'Post',
        ),
      if (role == UserRole.admin)
        _NavTab(
          const AdminPanelScreen(),
          Icons.shield_outlined,
          'Admin',
        ),
      _NavTab(
        const ProfileScreen(),
        Icons.person_outline,
        'Profile',
      ),
    ];

    final safeIndex = _index.clamp(0, tabs.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
        destinations: tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavTab {
  final Widget screen;
  final IconData icon;
  final String label;

  _NavTab(
    this.screen,
    this.icon,
    this.label,
  );
}