import 'package:flutter/material.dart';

/// horizontal circle avatar
class ActiveGroupItem extends StatelessWidget {
  final String initials;
  final String name;
  final Color color;
  final int badgeCount;

  const ActiveGroupItem({
    super.key,
    required this.initials,
    required this.name,
    required this.color,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // allow overlaying notification count
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              // draw notification flag if there's unread items
              if (badgeCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Color(0xFFFFB800), shape: BoxShape.circle),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// individual conversation preview
class MessageCard extends StatelessWidget {
  final String initials;
  final Color avatarColor;
  final String title;
  final String subtitle;
  final String time;
  final String? tagText;
  final int badgeCount;
  final bool isRead;
  final bool isSelected;
  final Color cardBg;
  final Color accentYellow;
  final VoidCallback onTap;

  const MessageCard({
    super.key,
    required this.initials,
    required this.avatarColor,
    required this.title,
    required this.subtitle,
    required this.time,
    this.tagText,
    this.badgeCount = 0,
    required this.isRead,
    required this.isSelected,
    required this.cardBg,
    required this.accentYellow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // enable animations on clicks
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          // highlight card border
          border: Border.all(
            color: isSelected ? accentYellow.withOpacity(0.8) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // group initials profile badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: accentYellow, shape: BoxShape.circle),
                      child: Text('$badgeCount', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // content preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: isRead ? Colors.grey : Colors.white.withOpacity(0.8), fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // show optional group member tags if present
                  if (tagText != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF2C2514), borderRadius: BorderRadius.circular(6)),
                      child: Text(tagText!, style: TextStyle(color: accentYellow, fontSize: 11, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

