import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/contribution_provider.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/utils/toast_service.dart';
import '../../../domain/entities/user.dart';

class RecordContributionScreen extends StatefulWidget {
  const RecordContributionScreen({super.key});

  @override
  State<RecordContributionScreen> createState() => _RecordContributionScreenState();
}

class _RecordContributionScreenState extends State<RecordContributionScreen> {
  final _amountController = TextEditingController(text: '2500');
  User? _selectedUser;
  String _selectedMonth = 'January';
  String _selectedYear = '2026';

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _years = ['2024', '2025', '2026'];

  @override
  void initState() {
    super.initState();
    // Default to current month/year
    final now = DateTime.now();
    _selectedMonth = _months[now.month - 1];
    _selectedYear = now.year.toString();
    if (!_years.contains(_selectedYear)) {
      _years.add(_selectedYear);
    }
    Future.microtask(() => context.read<UserProvider>().fetchUsers());
  }

  Future<void> _recordPayment() async {
    if (_selectedUser == null) {
      ToastService.showError(context, 'Please select a member first');
      return;
    }
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ToastService.showError(context, 'Please enter a valid amount');
      return;
    }

    final monthString = '$_selectedMonth $_selectedYear';
    final success = await context.read<ContributionProvider>().recordContribution(
          _selectedUser!.id,
          amount,
          monthString,
          'paid',
        );

    if (success && mounted) {
      ToastService.showSuccess(context, 'Payment recorded for ${_selectedUser!.name}');
      Navigator.pop(context);
    } else if (mounted) {
      ToastService.showError(context, 'Failed to record payment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ContributionProvider>().isLoading;
    final users = context.watch<UserProvider>().users;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Record Payment',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Member',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Autocomplete<User>(
              displayStringForOption: (User option) => '${option.name} (${option.email})',
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<User>.empty();
                }
                final query = textEditingValue.text.toLowerCase();
                return users.where((User user) {
                  return user.name.toLowerCase().contains(query) || user.email.toLowerCase().contains(query);
                });
              },
              onSelected: (User selection) {
                setState(() => _selectedUser = selection);
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return CustomTextField(
                  controller: controller,
                  focusNode: focusNode,
                  label: 'Search by name or email',
                  prefixIcon: Icons.search_rounded,
                );
              },
            ),
            if (_selectedUser != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Selected: ${_selectedUser!.name}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Month',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedMonth,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_month_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) => setState(() => _selectedMonth = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Year',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedYear,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                        onChanged: (val) => setState(() => _selectedYear = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            Text(
              'Amount (₦)',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _amountController,
              label: 'Enter Amount',
              prefixIcon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 48),
            CustomButton(
              text: 'R E C O R D  P A Y M E N T',
              isLoading: isLoading,
              onPressed: _recordPayment,
            ),
          ],
        ),
      ),
    );
  }
}
