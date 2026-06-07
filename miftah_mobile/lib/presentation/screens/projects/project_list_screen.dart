import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/shimmer_list_widget.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/utils/toast_service.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProjectProvider>().fetchProjects());
  }

  void _showDonationDialog(project) {
    CustomDialogBox.show(
      context: context,
      title: 'Support ${project.name}',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please transfer your contribution to the account below. Contact a Cashier to verify and record your donation.',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BANK NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Text('OPAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('ACCOUNT NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: '8061909049'));
                      ToastService.showSuccess(context, 'Account number copied!');
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('8061909049', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2)),
                          const SizedBox(width: 8),
                          Icon(Icons.copy_rounded, size: 16, color: AppColors.primary.withValues(alpha: 0.7)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('ACCOUNT NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Text('ALIYU AHMAD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Ongoing Projects',
      ),
      floatingActionButton: auth.user?.isPresident == true
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
                );
              },
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              label: const Text('Launch Campaign', style: TextStyle(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.rocket_launch_rounded),
            )
          : null,
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const ShimmerListWidget(itemCount: 5);
          }

          final projects = provider.projects;

          if (projects.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.rocket_launch_outlined,
              title: 'No Projects Yet',
              subtitle: 'There are no active projects to display right now. Check back later!',
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ProjectProvider>().fetchProjects(),
            color: AppColors.accent,
            backgroundColor: AppColors.primary,
            child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final progress = project.raisedAmount / (project.targetAmount > 0 ? project.targetAmount : 1);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.surfaceVariant),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
                    );
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 140,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, Color(0xFF023E23)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Icon(Icons.rocket_launch_rounded, size: 120, color: Colors.white.withOpacity(0.1)),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'GOAL: ₦${project.targetAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  project.name,
                                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            project.description,
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('RAISED SO FAR', style: TextStyle(fontSize: 10, letterSpacing: 1, color: AppColors.textSecondary)),
                                  Text('₦${project.raisedAmount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success)),
                                ],
                              ),
                              SizedBox(
                                width: 120,
                                child: CustomButton(
                                  text: 'DONATE',
                                  color: AppColors.accent,
                                  onPressed: () => _showDonationDialog(project),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(progress >= 1.0 ? AppColors.success : AppColors.primary),
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms).slideY(begin: 0.2, curve: Curves.easeOutQuint);
          },
        ),
      );
      },
    ),
  );
  }
}
