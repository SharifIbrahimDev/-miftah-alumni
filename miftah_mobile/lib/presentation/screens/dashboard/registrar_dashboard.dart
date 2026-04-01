import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../profile/profile_screen.dart';
import '../users/user_list_screen.dart';
import '../../widgets/app_drawer.dart';

class RegistrarDashboard extends StatefulWidget {
  const RegistrarDashboard({super.key});

  @override
  State<RegistrarDashboard> createState() => _RegistrarDashboardState();
}

class _RegistrarDashboardState extends State<RegistrarDashboard> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user?.name ?? 'Registrar'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatBanner(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('REGISTRATION COMMAND'),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    context,
                    'Manage Alumni List',
                    'Database of all chapter members',
                    Icons.groups_rounded,
                    AppColors.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserListScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    context,
                    'New Registration',
                    'Direct entry for new chapter members',
                    Icons.person_add_alt_1_rounded,
                    AppColors.accent,
                    () => _showNewRegistrationDialog(context),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('LATEST ENROLLMENTS'),
                  const SizedBox(height: 16),
                  _buildRecentMembers(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewRegistrationDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('New Member Enrollment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(nameController, 'Full Name', Icons.person_outline),
              _buildDialogField(emailController, 'Email Address', Icons.email_outlined),
              _buildDialogField(phoneController, 'Phone Number', Icons.phone_android_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
            onPressed: () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty) return;
              final success = await context.read<UserProvider>().addUser({
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'role': 'member',
              });
              if (success) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Member registered successfully!'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Register Member'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'REGISTRAR CONSOLE',
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.5,
          color: Colors.white,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/miftah_bg.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.4),
                    AppColors.primary.withOpacity(0.95),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salaam, $name',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          icon: const Icon(Icons.badge_outlined, color: Colors.white),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.primary.withOpacity(0.5),
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildStatBanner() {
    return GlassCard(
      baseColor: AppColors.primary,
      opacity: 0.9,
      padding: const EdgeInsets.all(32),
      border: Border.all(color: Colors.white.withOpacity(0.15)),
      child: Column(
        children: [
          Text(
            'CHAPTER POPULATION',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '1,240',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verified Active Members',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      baseColor: color,
      opacity: 0.05,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub, 
                      style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMembers() {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        final recentUsers = provider.users.take(5).toList();
        
        if (recentUsers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No recent enrollments found.',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentUsers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = recentUsers[index];
            return GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              opacity: 0.03,
              border: Border.all(color: Colors.black.withOpacity(0.03)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    user.name[0].toUpperCase(), 
                    style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold)
                  ),
                ),
                title: Text(
                  user.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(
                  'ENROLLED: ${user.phone}',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
              ),
            );
          },
        );
      }
    );
  }
}
