import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/user.dart';
import '../widgets/app_bottom_nav.dart';
import 'feed_screen.dart';
import 'explore_screen.dart';
import 'my_events_screen.dart';
import 'admin_panel_screen.dart';
import 'create_opportunity_screen.dart';
import 'profile_screen.dart';
import 'message_screen.dart';

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

    // Layout matches the reference design (Explore · 2nd · [+] · Chats · Profile).
    // The 2nd slot is role-respective and the center "+" is for posters only.
    final tabs = <_NavTab>[
      _NavTab(const FeedScreen(), Icons.explore_outlined, 'Feed'),
      _NavTab(const ExploreScreen(), Icons.search_outlined, 'Explore'),
      _NavTab(const MyEventsScreen(), Icons.event_available_outlined, 'My Events'),
      if (role.canPost)
        _NavTab(
          const CreateOpportunityScreen(),
          Icons.add,
          'Post',
          isCreate: true,
        ),
      _NavTab(
        const MessageScreen(),
        Icons.chat_bubble_outline,
        'Chats',
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: safeIndex,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
        items: tabs
            .map(
              (tab) => AppNavItem(
                icon: tab.icon,
                label: tab.label,
                isCreate: tab.isCreate,
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
  final bool isCreate;

  _NavTab(
    this.screen,
    this.icon,
    this.label, {
    this.isCreate = false,
  });
}
