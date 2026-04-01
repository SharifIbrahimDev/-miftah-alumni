import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/auth_provider.dart';

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
    Future.microtask(() => context.read<ContributionProvider>().fetchMyContributions());
  }

  void _showRecordPaymentDialog() {
    final amountController = TextEditingController(text: '2500');
    final monthController = TextEditingController(text: DateFormat('MMMM yyyy').format(DateTime.now()));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Record Payment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(monthController, 'Contribution Month', Icons.calendar_month_outlined),
              _buildDialogField(amountController, 'Amount (₦)', Icons.payments_outlined, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final success = await context.read<ContributionProvider>().recordContribution(
                auth.user!.id,
                double.parse(amountController.text),
                monthController.text,
                'paid',
              );
              if (success) {
                Navigator.pop(context);
                context.read<ContributionProvider>().fetchMyContributions();
              }
            },
            child: const Text('Record Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canRecord = auth.user?.isPresident == true || auth.user?.isCashier == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Monthly Ledger'),
      ),
      floatingActionButton: canRecord
          ? FloatingActionButton.extended(
              onPressed: _showRecordPaymentDialog,
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

          final contributions = provider.myContributions;
          final totalPaid = contributions.fold(0.0, (sum, item) => sum + (item.isPaid ? item.amount : 0));

          return Column(
            children: [
              _buildSummaryHeader(totalPaid),
              _buildYearFilter(),
              Expanded(
                child: contributions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: contributions.length,
                        itemBuilder: (context, index) {
                          final contribution = contributions[index];
                          final isPaid = contribution.isPaid;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.surfaceVariant),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isPaid ? AppColors.success : AppColors.error).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                                  color: isPaid ? AppColors.success : AppColors.error,
                                ),
                              ),
                              title: Text(
                                contribution.month,
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(isPaid ? 'Payment Verified' : 'Awaiting Payment', style: const TextStyle(fontSize: 12)),
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
                                      color: (isPaid ? AppColors.success : AppColors.error).withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
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
          Text('TOTAL CONTRIBUTED IN $_selectedYear', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, letterSpacing: 1)),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('No records found for this year.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

