import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/contribution.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/utils/toast_service.dart';
import '../../widgets/empty_state_widget.dart';
import 'record_contribution_screen.dart';

class MonthlyContributionScreen extends StatefulWidget {
  const MonthlyContributionScreen({super.key});

  @override
  State<MonthlyContributionScreen> createState() => _MonthlyContributionScreenState();
}

class _MonthlyContributionScreenState extends State<MonthlyContributionScreen> {
  String _selectedYear = '2026';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      final provider = context.read<ContributionProvider>();
      provider.fetchMyContributions();
      if (auth.user?.isPresident == true || auth.user?.isCashier == true) {
        provider.fetchAllContributions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isCashier = auth.user?.isCashier == true;
    final isAdmin = auth.user?.isPresident == true || isCashier;

    return DefaultTabController(
      length: isAdmin ? 2 : 1,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Monthly Ledger',
          bottom: isAdmin
              ? const TabBar(
                  indicatorColor: AppColors.accent,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'My Ledger'),
                    Tab(text: 'All Records'),
                  ],
                )
              : null,
        ),
        floatingActionButton: isCashier
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecordContributionScreen()),
                  );
                },
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                label: const Text('New Entry', style: TextStyle(fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.add_task_rounded),
              )
            : null,
        body: Consumer<ContributionProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (isAdmin) {
              return TabBarView(
                children: [
                  _buildList(provider.myContributions),
                  _buildList(provider.allContributions, isAllRecords: true),
                ],
              );
            } else {
              return _buildList(provider.myContributions);
            }
          },
        ),
      ),
    );
  }

  Widget _buildList(List contributions, {bool isAllRecords = false}) {
    // Filter contributions by selected year
    final filteredContributions = contributions.where((c) => c.month.contains(_selectedYear)).toList();
    final totalPaid = filteredContributions.fold(0.0, (sum, item) => sum + (item.isPaid ? item.amount : 0));

    return Column(
      children: [
        _buildSummaryHeader(totalPaid),
        _buildYearFilter(),
        Expanded(
          child: filteredContributions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredContributions.length,
                  itemBuilder: (context, index) {
                    final contribution = filteredContributions[index];
                    final isPaid = contribution.isPaid;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: ListTile(
                        onTap: isPaid ? null : () => _showPaymentInfoDialog(contribution),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isPaid ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                            color: isPaid ? AppColors.success : AppColors.error,
                          ),
                        ),
                        title: Text(
                          isAllRecords ? '${contribution.userName} - ${contribution.month}' : contribution.month,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(isPaid ? 'Payment Verified' : 'Awaiting Payment - Tap to pay', style: const TextStyle(fontSize: 12)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₦${contribution.amount.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: isPaid ? AppColors.success : AppColors.error,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPaid ? 'PAID' : 'DUE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: (isPaid ? AppColors.success : AppColors.error).withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: (index * 50).ms).slideX(begin: -0.1, curve: Curves.easeOutQuint);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(double total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF023E23)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text('TOTAL CONTRIBUTED IN $_selectedYear', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(
            '₦${total.toStringAsFixed(0)}',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Payment Records', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedYear,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
            items: ['2024', '2025', '2026'].map((year) {
              return DropdownMenuItem(value: year, child: Text(year, style: const TextStyle(fontWeight: FontWeight.bold)));
            }).toList(),
            onChanged: (val) => setState(() => _selectedYear = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      icon: Icons.history_edu_rounded,
      title: 'No records',
      subtitle: 'No records found for this year.',
    );
  }

  void _showPaymentInfoDialog(MonthlyContribution contribution) {
    final amountController = TextEditingController(text: contribution.amount.toStringAsFixed(0));
    CustomDialogBox.show(
      context: context,
      title: 'Pay Monthly Dues',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please transfer your monthly dues to the account below, then submit a claim. Your record will update once the Cashier approves it.',
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
            const SizedBox(height: 24),
            CustomTextField(
              controller: amountController,
              label: 'Amount Paid (₦)',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.payments_outlined,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        SizedBox(
          width: 150,
          child: CustomButton(
            text: 'Submit Claim',
            onPressed: () async {
              if (amountController.text.isEmpty) return;
              final auth = context.read<AuthProvider>();
              final success = await context.read<ContributionProvider>().submitClaim(
                    auth.user!.id,
                    double.parse(amountController.text),
                    'monthly',
                    contribution.month,
                  );
              if (success) {
                if (!mounted) return;
                Navigator.pop(context);
                ToastService.showSuccess(context, 'Claim submitted! Awaiting Cashier approval.');
              }
            },
          ),
        ),
      ],
    );
  }
}
