import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A single slot in [AppBottomNav]. When [isCreate] is true the slot renders
/// as a raised gold "+" action button instead of an icon+label.
class AppNavItem {
  final IconData icon;
  final String label;
  final bool isCreate;

  const AppNavItem({
    required this.icon,
    required this.label,
    this.isCreate = false,
  });
}

/// Custom bottom navigation bar matching the reference design: a deep navy
/// bar with a raised gold rounded-square action button in the middle.
class AppBottomNav extends StatelessWidget {
  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.navySurface,
        border: Border(
          top: BorderSide(color: Color(0x1AFFFFFF)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: items[i].isCreate
                      ? _CreateButton(
                          selected: currentIndex == i,
                          onTap: () => onTap(i),
                        )
                      : _NavButton(
                          item: items[i],
                          selected: currentIndex == i,
                          onTap: () => onTap(i),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.gold : AppTheme.textMuted;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _CreateButton({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: selected
                ? Border.all(color: AppTheme.textLight, width: 2)
                : null,
          ),
          child: const Icon(
            Icons.add,
            color: AppTheme.navy,
            size: 28,
          ),
        ),
      ),
    );
  }
}
