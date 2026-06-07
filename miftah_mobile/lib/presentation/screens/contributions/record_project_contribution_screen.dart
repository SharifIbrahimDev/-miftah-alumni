import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/project_provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/utils/toast_service.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/contribution.dart';

class RecordProjectContributionScreen extends StatefulWidget {
  const RecordProjectContributionScreen({super.key});

  @override
  State<RecordProjectContributionScreen> createState() => _RecordProjectContributionScreenState();
}

class _RecordProjectContributionScreenState extends State<RecordProjectContributionScreen> {
  final _amountController = TextEditingController();
  User? _selectedUser;
  Project? _selectedProject;
  TextEditingController? _autoCompleteController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserProvider>().fetchUsers();
      context.read<ProjectProvider>().fetchProjects();
    });
  }

  Future<void> _recordPayment() async {
    if (_selectedUser == null) {
      ToastService.showError(context, 'Please select a member');
      return;
    }
    if (_selectedProject == null) {
      ToastService.showError(context, 'Please select a project');
      return;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ToastService.showError(context, 'Please enter a valid amount');
      return;
    }

    final success = await context.read<ProjectProvider>().recordContribution(
          _selectedProject!.id,
          _selectedUser!.id,
          amount,
        );

    if (success && mounted) {
      ToastService.showSuccess(context, 'Recorded ₦${amount.toStringAsFixed(0)} for ${_selectedUser!.name}');
      Navigator.pop(context);
    } else if (mounted) {
      ToastService.showError(context, 'Failed to record payment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProjectProvider>().isLoading;
    final users = context.watch<UserProvider>().users;
    final projects = context.watch<ProjectProvider>().projects;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Project Donation',
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
                  _selectedUser = selection;
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
            if (_selectedUser != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Chip(
                  label: Text(_selectedUser!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _selectedUser = null;
                      _autoCompleteController?.clear();
                    });
                  },
                ),
              ),
            
            const SizedBox(height: 24),
            Text(
              'Select Project',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Project>(
              value: _selectedProject,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.rocket_launch_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              hint: const Text('Choose a campaign'),
              items: projects.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
              onChanged: (val) => setState(() => _selectedProject = val),
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
              text: 'R E C O R D  D O N A T I O N',
              isLoading: isLoading,
              onPressed: _recordPayment,
            ),
          ],
        ),
      ),
    );
  }
}
