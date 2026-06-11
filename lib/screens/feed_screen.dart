import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/opportunity_meta.dart';
import 'discover_screen.dart';
import 'opportunity_detail_screen.dart';

/// The "Explore" home feed: greeting, search entry, a featured opportunity,
/// category filter chips and the latest opportunities.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final feed = state.feed;
    final user = state.currentUser;
    final featured = feed.isNotEmpty ? feed.first : null;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            // Greeting.
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Good morning 👋',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textMuted)),
                      Text(
                        user?.name.split(' ').first ?? 'there',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: AppTheme.gold,
                  child: Text(
                    user?.initials ?? '?',
                    style: const TextStyle(
                        color: AppTheme.navy, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search entry → Discover.
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiscoverScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.navySurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: AppTheme.textMuted),
                    SizedBox(width: 10),
                    Text('Search opportunities, events…',
                        style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (featured != null) ...[
              const Row(
                children: [
                  Text('Featured',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('🔥 Hot this week',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.gold)),
                ],
              ),
              const SizedBox(height: 10),
              _FeaturedCard(opportunity: featured),
              const SizedBox(height: 20),
            ],
            _FilterBar(
              active: state.activeFilter,
              onSelect: state.setFilter,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Latest Opportunities',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${feed.length} found',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),
            if (feed.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No opportunities here yet.')),
              )
            else
              for (final o in feed) OpportunityCard(opportunity: o),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Opportunity opportunity;
  const _FeaturedCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OpportunityDetailScreen(opportunityId: o.id),
        ),
      ),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: o.type.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                OpportunityTypeChip(type: o.type),
                const Spacer(),
                if (o.isVerified) const VerifiedBadge(),
              ],
            ),
            const Spacer(),
            Text(
              o.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.event, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(formatDate(o.date),
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70)),
                const SizedBox(width: 12),
                const Icon(Icons.people_outline,
                    size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  '${o.interestedCount > 0 ? o.interestedCount : o.attendeeCount} going',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final OpportunityType? active;
  final ValueChanged<OpportunityType?> onSelect;

  const _FilterBar({required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(context, 'All', active == null, () => onSelect(null)),
          ...OpportunityType.values.map(
            (type) => _chip(
              context,
              type.label,
              active == type,
              () => onSelect(type),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
