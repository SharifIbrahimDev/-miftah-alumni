import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/project_provider.dart';
import '../../../domain/entities/contribution.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/glass_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/shimmer_list_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  List<ProjectContribution> _contributions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContributions();
  }

  Future<void> _fetchContributions() async {
    final contribs = await context.read<ProjectProvider>().getProjectContributions(widget.project.id);
    if (mounted) {
      setState(() {
        _contributions = contribs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.project.raisedAmount / (widget.project.targetAmount > 0 ? widget.project.targetAmount : 1);
    final percentage = (progress * 100).clamp(0, 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.project.name,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    baseColor: AppColors.primary,
                    opacity: 0.15,
                    child: Column(
                      children: [
                        Text(
                          'GOAL: ₦${widget.project.targetAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Raised: ₦${widget.project.raisedAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$percentage%',
                              style: GoogleFonts.inter(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Description',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.project.description,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Contributions',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(child: ShimmerListWidget(itemCount: 3))
          else if (_contributions.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyStateWidget(
                icon: Icons.volunteer_activism_outlined,
                title: 'No Contributions Yet',
                subtitle: 'Be the first to donate to this project!',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final contrib = _contributions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        opacity: 0.05,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                            child: Text(
                              contrib.userName[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contrib.userName,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM d, yyyy - h:mm a').format(contrib.createdAt),
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₦${contrib.amount.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.success),
                          ),
                        ],
                      ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.05, curve: Curves.easeOutQuint);
                  },
                  childCount: _contributions.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
