import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/contribution_provider.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Financial Audit Trail', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ContributionProvider>(
        builder: (context, provider, _) {
          final contributions = provider.allContributions.where((c) => c.status == 'paid').toList();
          final expenses = provider.expenses;
          
          // Unify into a single list of objects or a helper class
          final allTransactions = [
            ...contributions.map((c) => _TransactionItem(
                  title: 'Monthly Due: ${c.userName}',
                  subtitle: c.month,
                  amount: c.amount,
                  isCredit: true,
                  date: c.createdAt,
                )),
            ...expenses.map((e) => _TransactionItem(
                  title: e.description,
                  subtitle: e.category,
                  amount: e.amount,
                  isCredit: false,
                  date: e.createdAt,
                )),
          ];

          // Sort by date descending
          allTransactions.sort((a, b) => b.date.compareTo(a.date));

          if (allTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('No financial records found.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: allTransactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = allTransactions[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (tx.isCredit ? AppColors.success : AppColors.error).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tx.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: tx.isCredit ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    tx.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    tx.subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${tx.isCredit ? "+" : "-"} ₦${tx.amount.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: tx.isCredit ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(tx.date),
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TransactionItem {
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final DateTime date;

  _TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.date,
  });
}

