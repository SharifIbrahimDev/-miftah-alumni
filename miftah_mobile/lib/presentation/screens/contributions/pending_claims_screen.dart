import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/utils/toast_service.dart';
import '../../providers/contribution_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/shimmer_list_widget.dart';

class PendingClaimsScreen extends StatefulWidget {
  const PendingClaimsScreen({super.key});

  @override
  State<PendingClaimsScreen> createState() => _PendingClaimsScreenState();
}

class _PendingClaimsScreenState extends State<PendingClaimsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContributionProvider>().fetchPendingClaims();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Pending Claims'),
      body: Consumer<ContributionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.pendingClaims.isEmpty) {
            return const ShimmerListWidget();
          }

          if (provider.pendingClaims.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.check_circle_outline_rounded,
              title: 'All caught up!',
              subtitle: 'There are no pending claims to review.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchPendingClaims(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.pendingClaims.length,
              itemBuilder: (context, index) {
                final claim = provider.pendingClaims[index];
                final isMonthly = claim.type == 'monthly';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isMonthly ? AppColors.primary : AppColors.accent).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isMonthly ? 'MONTHLY DUE' : 'PROJECT DONATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: isMonthly ? AppColors.primary : AppColors.accent,
                                ),
                              ),
                            ),
                            Text(
                              '₦${claim.amount.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          claim.userName,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isMonthly ? 'Month: ${claim.referenceId}' : 'Project ID: ${claim.referenceId}',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  final success = await provider.processClaim(claim, false);
                                  if (success && mounted) {
                                    ToastService.showError(context, 'Claim rejected.');
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final success = await provider.processClaim(claim, true);
                                  if (success && mounted) {
                                    ToastService.showSuccess(context, 'Claim approved successfully!');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
