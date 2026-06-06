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
  final List<User> _selectedUsers = [];
  TextEditingController? _autoCompleteController;
  final List<String> _selectedMonths = [];
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
    _selectedMonths.add(_months[now.month - 1]);
    _selectedYear = now.year.toString();
    if (!_years.contains(_selectedYear)) {
      _years.add(_selectedYear);
    }
    Future.microtask(() => context.read<UserProvider>().fetchUsers());
  }

  Future<void> _recordPayment() async {
    if (_selectedUsers.isEmpty) {
      ToastService.showError(context, 'Please select at least one member');
      return;
    }
    if (_selectedMonths.isEmpty) {
      ToastService.showError(context, 'Please select at least one month');
      return;
    }
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ToastService.showError(context, 'Please enter a valid amount');
      return;
    }

    bool hasError = false;

    for (final user in _selectedUsers) {
      for (final month in _selectedMonths) {
        final monthString = '$month $_selectedYear';
        final success = await context.read<ContributionProvider>().recordContribution(
              user.id,
              amount,
              monthString,
              'paid',
            );
        if (!success) {
          hasError = true;
        }
      }
    }

    if (!hasError && mounted) {
      ToastService.showSuccess(context, 'Payments recorded successfully for ${_selectedUsers.length} member(s) across ${_selectedMonths.length} month(s)');
      Navigator.pop(context);
    } else if (mounted) {
      ToastService.showError(context, 'Failed to record one or more payments');
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
                setState(() {
                  if (!_selectedUsers.any((u) => u.id == selection.id)) {
                    _selectedUsers.add(selection);
                  }
                });
                // Delay clearing slightly so Autocomplete completes its internal state update
                Future.microtask(() {
                  _autoCompleteController?.clear();
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                _autoCompleteController = controller;
                return CustomTextField(
                  controller: controller,
                  focusNode: focusNode,
                  label: 'Search by name or email',
                  prefixIcon: Icons.search_rounded,
                );
              },
            ),
            if (_selectedUsers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedUsers.map((user) {
                    return Chip(
                      label: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedUsers.removeWhere((u) => u.id == user.id);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            
            const SizedBox(height: 24),
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
            
            const SizedBox(height: 24),
            Text(
              'Months',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _months.map((month) {
                final isSelected = _selectedMonths.contains(month);
                return FilterChip(
                  label: Text(month, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMonths.add(month);
                      } else {
                        _selectedMonths.remove(month);
                      }
                    });
                  },
                  selectedColor: AppColors.accent.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.accent,
                );
              }).toList(),
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
