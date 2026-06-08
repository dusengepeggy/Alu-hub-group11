import 'package:flutter/material.dart';

/// Create-opportunity form. Only reachable by organizers/admins (the tab is
/// hidden otherwise). STUB.
///
/// TODO(team): build a form (title, type dropdown, description, date picker,
/// location) and call state.createOpportunity(...). It returns null on
/// success or an error string — show that error to the user. Validate input.
class CreateOpportunityScreen extends StatelessWidget {
  const CreateOpportunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post an Opportunity')),
      body: const Center(
        child: Text('TODO: build the create-opportunity form',
            style: TextStyle(color: Colors.black38)),
      ),
    );
  }
}
