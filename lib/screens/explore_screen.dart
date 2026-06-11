import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/opportunity_meta.dart';
import 'opportunity_detail_screen.dart';

/// Explore: a searchable feed with a featured opportunity, category filter
/// chips and the rich opportunity cards.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final all = state.feed; // already respects the active category filter

    final filtered = all.where((o) {
      if (_query.isEmpty) return true;
      return o.title.toLowerCase().contains(_query) ||
          o.location.toLowerCase().contains(_query) ||
          o.organizer.toLowerCase().contains(_query);
    }).toList();

    final showFeatured =
        _query.isEmpty && state.activeFilter == null && all.isNotEmpty;

    final user = state.currentUser;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            // ── Greeting ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hi, ${user?.name.split(' ').first ?? 'there'} 👋',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight),
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

            // ── Search ───────────────────────────────────
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search opportunities, events…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // ── Featured ─────────────────────────────────
            if (showFeatured) ...[
              const Row(
                children: [
                  Text('Featured',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('🔥 Hot this week',
                      style: TextStyle(fontSize: 12, color: AppTheme.gold)),
                ],
              ),
              const SizedBox(height: 10),
              _FeaturedCard(opportunity: all.first),
              const SizedBox(height: 20),
            ],

            // ── Category filters ─────────────────────────
            _FilterBar(
              active: state.activeFilter,
              onSelect: state.setFilter,
            ),
            const SizedBox(height: 8),

            // ── List ─────────────────────────────────────
            Row(
              children: [
                const Text('Latest Opportunities',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${filtered.length} found',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('Nothing found.',
                      style: TextStyle(color: AppTheme.textMuted)),
                ),
              )
            else
              for (final o in filtered) OpportunityCard(opportunity: o),
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
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(width: 12),
                const Icon(Icons.people_outline,
                    size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  '${o.interestedCount > 0 ? o.interestedCount : o.attendeeCount} going',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
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
