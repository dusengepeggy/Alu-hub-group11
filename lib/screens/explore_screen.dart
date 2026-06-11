import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import 'opportunity_detail_screen.dart';

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
    final all = state.feed;

    // state.feed already applies activeFilter from AppState,
    // so we only filter by search query here
    final filtered = all.where((o) {
      return _query.isEmpty ||
          o.title.toLowerCase().contains(_query) ||
          o.location.toLowerCase().contains(_query);
    }).toList();

    final recommended = all.where((o) => o.isVerified).take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search events, clubs, opportunities...',
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
          ),

          // ── Category filter chips ───────────────────
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip(context, 'All', state.activeFilter == null,
                    () => state.setFilter(null)),
                ...OpportunityType.values.map(
                  (type) => _chip(
                    context,
                    type.label,
                    state.activeFilter == type,
                    () => state.setFilter(type),
                  ),
                ),
              ],
            ),
          ),

          // ── Main content ────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Nothing found.'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Recommended section (only on "All" tab, no search)
                      if (state.activeFilter == null &&
                          _query.isEmpty &&
                          recommended.isNotEmpty) ...[
                        const Text(
                          'Recommended for you',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 160,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommended.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) =>
                                _RecommendedCard(opportunity: recommended[i]),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'All Activity',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Full list
                      ...filtered.map(
                        (o) => _OpportunityCard(opportunity: o),
                      ),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

// ── Recommended horizontal card ──────────────────

class _RecommendedCard extends StatelessWidget {
  final Opportunity opportunity;
  const _RecommendedCard({required this.opportunity});

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
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.gold.withOpacity(0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(o.type.icon, color: AppTheme.gold, size: 22),
            const SizedBox(height: 8),
            Text(
              o.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    o.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── List card ────────────────────────────────────

class _OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  const _OpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OpportunityDetailScreen(opportunityId: o.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(o.type.icon, size: 18, color: AppTheme.gold),
                  const SizedBox(width: 6),
                  Text(
                    o.type.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (o.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 13, color: AppTheme.navy),
                          SizedBox(width: 3),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                o.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${o.posterName} · ${o.location}',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.people_outline,
                      size: 15, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${o.attendeeCount} going',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}