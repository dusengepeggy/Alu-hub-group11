import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import 'opportunity_detail_screen.dart';

// ─────────────────────────────────────────────
//  Feed Screen
// ─────────────────────────────────────────────
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final feed  = state.feed;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FeedHeader(),
            _FilterBar(active: state.activeFilter, onSelect: state.setFilter),
            Expanded(
              child: feed.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: feed.length,
                      itemBuilder: (context, i) => _OpportunityCard(
                        opportunity: feed[i],
                        heroTag: 'opp_${feed[i].id}',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Header
// ─────────────────────────────────────────────
class _FeedHeader extends StatelessWidget {
  const _FeedHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Opportunities',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _kBody,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Discover what's happening around campus',
                style: TextStyle(fontSize: 13, color: _kSubtle),
              ),
            ],
          ),
          const Spacer(),
          // Search icon button
          _IconBtn(
            icon: Icons.search_rounded,
            onTap: () {}, // hook up search later
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kCardBorder),
        ),
        child: Icon(icon, size: 20, color: _kSubtle),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Filter Bar
// ─────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final OpportunityType? active;
  final ValueChanged<OpportunityType?> onSelect;
  const _FilterBar({required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        children: [
          _FilterChip(
            label: 'All',
            accent: _kAmber,
            icon: Icons.apps_rounded,
            selected: active == null,
            onTap: () => onSelect(null),
          ),
          ...OpportunityType.values.map(
            (t) => _FilterChip(
              label: t.label,
              accent: _accentFor(t),
              icon: t.icon,
              selected: active == t,
              onTap: () => onSelect(t),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.accent,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.15) : const Color(0xFF161F30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.6) : _kCardBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: selected ? accent : _kMuted),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? accent : _kSubtle,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Opportunity Card  ← the signature element
//  Left-edge color bar that bleeds the type
//  accent; dark glass card surface.
// ─────────────────────────────────────────────
class _OpportunityCard extends StatefulWidget {
  final Opportunity opportunity;
  final String heroTag;
  const _OpportunityCard({required this.opportunity, required this.heroTag});

  @override
  State<_OpportunityCard> createState() => _OpportunityCardState();
}

class _OpportunityCardState extends State<_OpportunityCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final o      = widget.opportunity;
    final accent = _accentFor(o.type);
    final dimmed = _accentDimFor(o.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) => setState(() => _pressed = false),
        onTapCancel: ()  => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OpportunityDetailScreen(opportunityId: o.id),
            ),
          );
        },
        child: AnimatedScale(
          scale: _pressed ? 0.975 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kCardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Signature: left accent bar ──
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [accent, accent.withValues(alpha: 0.3)],
                        ),
                      ),
                    ),

                    // ── Card content ──
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: type pill + verified badge
                            Row(
                              children: [
                                _TypePill(
                                  label: o.type.label,
                                  icon: o.type.icon,
                                  accent: accent,
                                  dimmed: dimmed,
                                ),
                                const Spacer(),
                                if (o.isVerified) const _VerifiedBadge(),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Title
                            Text(
                              o.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _kBody,
                                height: 1.25,
                                letterSpacing: -0.2,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Poster · location
                            Row(
                              children: [
                                Icon(Icons.storefront_outlined,
                                    size: 13, color: _kMuted),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${o.posterName} · ${o.location}',
                                    style: const TextStyle(
                                        fontSize: 12, color: _kSubtle),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Footer: attendees + arrow
                            Row(
                              children: [
                                _AvatarStack(count: o.attendeeCount),
                                const SizedBox(width: 8),
                                Text(
                                  '${o.attendeeCount} going',
                                  style: const TextStyle(
                                      fontSize: 12, color: _kSubtle),
                                ),
                                const Spacer(),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Type pill
// ─────────────────────────────────────────────
class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.label,
    required this.icon,
    required this.accent,
    required this.dimmed,
  });

  final String   label;
  final IconData icon;
  final Color    accent;
  final Color    dimmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dimmed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Verified badge — redesigned
// ─────────────────────────────────────────────
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: _kVerifiedBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _kVerifiedFg.withValues(alpha: 0.35),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 12, color: _kVerifiedFg),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _kVerifiedFg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Mini avatar stack (decorative)
// ─────────────────────────────────────────────
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF2EC4B6),
      const Color(0xFFF5A623),
      const Color(0xFFFF6B8A),
    ];
    final show = count > 0 ? colors.take(3).toList() : <Color>[];
    return SizedBox(
      width: show.length * 14.0 + 4,
      height: 20,
      child: Stack(
        children: show.asMap().entries.map((e) {
          return Positioned(
            left: e.key * 14.0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: e.value.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: _kCardBg, width: 1.5),
              ),
              child: Center(
                child: Icon(Icons.person_rounded,
                    size: 10, color: e.value),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kAmberDim,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.explore_off_rounded,
                size: 36, color: _kAmber),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nothing here yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kbody,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back soon — new opportunities\nare posted regularly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _kSubtle, height: 1.5),
          ),
        ],
      ),
    );
  }
}