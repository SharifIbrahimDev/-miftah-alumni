import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProjectContributionScreen extends StatelessWidget {
  const ProjectContributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Contributions'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volunteer_activism, color: AppColors.accent),
              ),
              title: const Text('Hall Renovation'),
              subtitle: const Text('Jan 28, 2026'),
              trailing: const Text(
                '₦10,000',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
