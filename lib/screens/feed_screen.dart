import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import 'opportunity_detail_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final feed = state.feed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunities'),
      ),
      body: Column(
        children: [
          _FilterBar(
            active: state.activeFilter,
            onSelect: state.setFilter,
          ),
          Expanded(
            child: feed.isEmpty
                ? const Center(
                    child: Text('No opportunities here yet.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: feed.length,
                    itemBuilder: (context, index) {
                      return _OpportunityCard(
                        opportunity: feed[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final OpportunityType? active;
  final ValueChanged<OpportunityType?> onSelect;

  const _FilterBar({
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _chip(
            context,
            'All',
            active == null,
            () => onSelect(null),
          ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 8,
      ),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;

  const _OpportunityCard({
    required this.opportunity,
  });

  @override
  Widget build(BuildContext context) {
    final o = opportunity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OpportunityDetailScreen(
                opportunityId: o.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    o.type.icon,
                    size: 18,
                    color: AppTheme.gold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    o.type.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (o.isVerified) const _VerifiedBadge(),
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
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 15,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${o.attendeeCount} going',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
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

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 14,
            color: AppTheme.navy,
          ),
          SizedBox(width: 4),
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
    );
  }
}