import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'explore_screen.dart';
import 'my_events_screen.dart';
import 'create_opportunity_screen.dart';
import 'profile.dart';
import 'chats.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Layout: Feed · My Events · [+] · Chats · Profile.
    // Any signed-in ALU member can post, so the center "+" is always shown.
    final tabs = <_NavTab>[
      _NavTab(const ExploreScreen(), Icons.explore_outlined, 'Feed'),
      _NavTab(const MyEventsScreen(), Icons.event_available_outlined, 'My Events'),
      _NavTab(
        const CreateOpportunityScreen(),
        Icons.add,
        'Post',
        isCreate: true,
      ),
      _NavTab(
        const ChatsPage(),
        Icons.chat_bubble_outline,
        'Chats',
      ),
      _NavTab(
        const ProfilePage(),
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
