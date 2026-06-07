import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/project_provider.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/utils/toast_service.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController();

  Future<void> _launchCampaign() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final targetText = _targetController.text.trim();

    if (title.isEmpty || description.isEmpty || targetText.isEmpty) {
      ToastService.showError(context, 'Please fill in all fields');
      return;
    }

    final targetAmount = double.tryParse(targetText);
    if (targetAmount == null || targetAmount <= 0) {
      ToastService.showError(context, 'Please enter a valid target amount');
      return;
    }

    final success = await context.read<ProjectProvider>().addProject({
      'title': title,
      'description': description,
      'target_amount': targetAmount,
    });

    if (success && mounted) {
      ToastService.showSuccess(context, 'Campaign "$title" launched successfully!');
      Navigator.pop(context);
    } else if (mounted) {
      ToastService.showError(context, 'Failed to launch campaign');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProjectProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Launch Campaign',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF023E23)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(Icons.campaign_rounded, size: 100, color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Inspire the Community',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a new fundraising goal.',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Campaign Title',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _titleController,
              label: 'e.g., Mosque Renovation Fund',
              prefixIcon: Icons.title_rounded,
            ),
            const SizedBox(height: 24),
            Text(
              'Target Goal (₦)',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _targetController,
              label: 'e.g., 5000000',
              prefixIcon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Text(
              'Description',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _descController,
              label: 'Describe the purpose of this campaign...',
              prefixIcon: Icons.description_outlined,
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'L A U N C H  C A M P A I G N',
              isLoading: isLoading,
              onPressed: _launchCampaign,
            ),
          ],
        ),
      ),
    );
  }
}
