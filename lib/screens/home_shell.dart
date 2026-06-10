import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/user.dart';
import 'feed_screen.dart';
import 'my_events_screen.dart';
import 'create_opportunity_screen.dart';
import 'admin_panel_screen.dart';
import 'profile_screen.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
const _kNavBg        = Color(0xFF151C2C); // deep slate
const _kNavSurface   = Color(0xFF1E2A3A); // raised card tone
const _kAccent       = Color(0xFFF5A623); // warm amber
const _kAccentGlow   = Color(0x33F5A623); // amber @ 20 % opacity
const _kIconDefault  = Color(0xFF7A8FA6); // muted blue-grey
const _kIconActive   = Color(0xFFF5A623); // amber on select
const _kLabelActive  = Color(0xFFF5A623);
const _kLabelDefault = Color(0xFF7A8FA6);
const _kNavHeight    = 76.0;
const _kIndicatorH   = 40.0;
const _kIndicatorW   = 64.0;

// ─────────────────────────────────────────────
//  Shell
// ─────────────────────────────────────────────
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  int _index = 0;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _onTap(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
    _glowCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    final role = user?.role ?? UserRole.student;

    final tabs = <_NavTab>[
      _NavTab(const FeedScreen(),             Icons.explore_rounded,        'Explore'),
      _NavTab(const MyEventsScreen(),         Icons.event_available_rounded,'My Events'),
      if (role.canPost)
        _NavTab(const CreateOpportunityScreen(), Icons.add_rounded,         'Post'),
      if (role == UserRole.admin)
        _NavTab(const AdminPanelScreen(),     Icons.verified_user_rounded,  'Admin'),
      _NavTab(const ProfileScreen(),          Icons.person_rounded,         'Profile'),
    ];

    final safeIndex = _index.clamp(0, tabs.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1520),
      body: IndexedStack(
        index: safeIndex,
        children: tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: _CustomNavBar(
        tabs: tabs,
        selectedIndex: safeIndex,
        glowAnim: _glowAnim,
        onTap: _onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Custom bottom nav bar
// ─────────────────────────────────────────────
class _CustomNavBar extends StatelessWidget {
  const _CustomNavBar({
    required this.tabs,
    required this.selectedIndex,
    required this.glowAnim,
    required this.onTap,
  });

  final List<_NavTab> tabs;
  final int selectedIndex;
  final Animation<double> glowAnim;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      height: _kNavHeight + bottomInset,
      decoration: const BoxDecoration(
        color: _kNavBg,
        border: Border(top: BorderSide(color: Color(0xFF253040), width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (i) {
            return Expanded(
              child: _NavItem(
                tab: tabs[i],
                isSelected: i == selectedIndex,
                glowAnim: i == selectedIndex ? glowAnim : kAlwaysDismissedAnimation,
                onTap: () => onTap(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Individual nav item
// ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.glowAnim,
    required this.onTap,
  });

  final _NavTab tab;
  final bool isSelected;
  final Animation<double> glowAnim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: _kNavHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: glowAnim,
              builder: (_, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow pulse (fades in then out)
                    if (isSelected)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _kIndicatorW,
                        height: _kIndicatorH,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: _kAccentGlow,
                        ),
                      ),
                    // Outer expanding ring (one-shot on select)
                    if (isSelected)
                      Transform.scale(
                        scale: 0.8 + glowAnim.value * 0.5,
                        child: Opacity(
                          opacity: (1 - glowAnim.value).clamp(0.0, 1.0),
                          child: Container(
                            width: _kIndicatorW,
                            height: _kIndicatorH,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _kAccent, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    child!,
                  ],
                );
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  tab.icon,
                  key: ValueKey(isSelected),
                  size: isSelected ? 24 : 22,
                  color: isSelected ? _kIconActive : _kIconDefault,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 10.5 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? _kLabelActive : _kLabelDefault,
                letterSpacing: isSelected ? 0.4 : 0,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data model
// ─────────────────────────────────────────────
class _NavTab {
  final Widget screen;
  final IconData icon;
  final String label;
  const _NavTab(this.screen, this.icon, this.label);
}