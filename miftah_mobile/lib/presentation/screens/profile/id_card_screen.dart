import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flip_card/flip_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../../core/widgets/custom_widgets.dart';

class IdCardScreen extends StatelessWidget {
  const IdCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Digital Alumni ID',
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // The Virtual ID Card
              FlipCard(
                direction: FlipDirection.HORIZONTAL,
                front: _buildCardFront(user, isDark),
                back: _buildCardBack(user, isDark),
              ),
              const SizedBox(height: 40),
              Text(
                'Scan this QR code at events for fast check-in and membership validation.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined),
                label: const Text('SHARE DIGITAL CARD'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildCardFront(user, bool isDark) {
    return Container(
      width: double.infinity,
      height: 480,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF042D1B), const Color(0xFF0A0E0A)]
            : [AppColors.primary, const Color(0xFF02361E)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: const Icon(Icons.shield_outlined, size: 400, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MIFTAH ALUMNI',
                          style: GoogleFonts.outfit(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2),
                        ),
                        Text(
                          'OFFICIAL MEMBER',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, letterSpacing: 1),
                        ),
                      ],
                    ),
                    const Icon(Icons.auto_awesome, color: AppColors.accent, size: 24),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: QrImageView(
                    data: 'MIFTAH-ID-${user?.id ?? '0000'}',
                    version: QrVersions.auto,
                    size: 160.0,
                  ),
                ),
                const Spacer(),
                Text(
                  user?.name.toUpperCase() ?? 'ALUMNI MEMBER',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                  ),
                  child: Text(
                    user?.role.toUpperCase() ?? 'MEMBER',
                    style: GoogleFonts.inter(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfo('MEMBER ID', '#${user?.id ?? '---'}'),
                    _buildInfo('VALID THRU', 'PERMANENT'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(user, bool isDark) {
    return Container(
      width: double.infinity,
      height: 480,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0E0A) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: AppColors.surfaceVariant, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 40),
            color: isDark ? Colors.black : Colors.black87,
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms & Conditions',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'This card is the property of Miftah Alumni Hub. If found, please return to the nearest command center. Use of this card is governed by the organization\'s terms and conditions.',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AUTHORIZED SIGNATURE', style: TextStyle(fontSize: 8, color: AppColors.textSecondary, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text('M. A. Hub', style: GoogleFonts.dancingScript(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        Container(width: 100, height: 1, color: AppColors.textSecondary.withOpacity(0.3)),
                      ],
                    ),
                    QrImageView(
                      data: 'VERIFY-${user?.id ?? '0000'}',
                      version: QrVersions.auto,
                      size: 80.0,
                      foregroundColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'MEMBERSHIP SINCE ${DateTime.now().year}',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
