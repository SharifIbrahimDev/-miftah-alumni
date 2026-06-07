import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/services/notification_service.dart';
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
    final amountController = TextEditingController();
    CustomDialogBox.show(
      context: context,
      title: 'Donate to ${project.name}',
      content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the amount you wish to contribute to this project.',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildDialogField(amountController, 'Amount (₦)', Icons.payments_outlined, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          SizedBox(
            width: 140,
            child: CustomButton(
              text: 'Donate',
              onPressed: () async {
                if (amountController.text.isEmpty) return;
                final auth = context.read<AuthProvider>();
                final success = await context.read<ProjectProvider>().recordContribution(
                      project.id,
                      auth.user!.id,
                      double.parse(amountController.text),
                    );
                if (success) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  NotificationService.notifyProjectContribution(project.name, double.parse(amountController.text));
                  ToastService.showSuccess(context, 'Thank you for your contribution!');
                }
              },
            ),
          ),
        ],
      );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomTextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        label: label,
        prefixIcon: icon,
      ),
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
