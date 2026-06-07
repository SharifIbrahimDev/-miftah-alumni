import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shimmer_list_widget.dart';
import 'add_member_screen.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/utils/toast_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().fetchUsers());
  }

  void _showEditRoleDialog(user) {
    String selectedRole = user.role;

    CustomDialogBox.show(
      context: context,
      title: 'Change Role for ${user.name}',
      content: StatefulBuilder(
        builder: (context, setDialogState) => DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: InputDecoration(
            labelText: 'Assign Role',
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (val) => setDialogState(() => selectedRole = val!),
          items: ['member', 'cashier', 'registrar']
              .map((role) => DropdownMenuItem(value: role, child: Text(role.toUpperCase())))
              .toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        SizedBox(
          width: 120,
          child: CustomButton(
            text: 'Save',
            onPressed: () async {
              final success = await context.read<UserProvider>().updateUserRole(user.id, selectedRole);
              if (success) {
                if (!mounted) return;
                Navigator.pop(context);
                ToastService.showSuccess(context, 'Role updated successfully');
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Member Directory',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMemberScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          final users = provider.users.where((u) {
            final query = _searchController.text.toLowerCase();
            return u.name.toLowerCase().contains(query) || u.email.toLowerCase().contains(query);
          }).toList();

          if (provider.isLoading) {
            return const ShimmerListWidget(itemCount: 8);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: CustomTextField(
                  controller: _searchController,
                  label: 'Search Members',
                  hint: 'Search by name or email...',
                  onChanged: (val) => setState(() {}),
                  prefixIcon: Icons.search_rounded,
                  suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.close), onPressed: () { _searchController.clear(); setState(() {}); })
                      : null,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<UserProvider>().fetchUsers(),
                  color: AppColors.accent,
                  backgroundColor: AppColors.primary,
                  child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final roleColor = _getRoleColor(user.role);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: ListTile(
                        onTap: () {
                          if (context.read<AuthProvider>().user?.isPresident == true) {
                            _showEditRoleDialog(user);
                          }
                        },
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(user.email, style: const TextStyle(fontSize: 13)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.role.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: roleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.1, curve: Curves.easeOutQuint);
                  },
                ),
               ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'president': return AppColors.accent;
      case 'registrar': return Colors.blue;
      case 'cashier': return Colors.orange;
      default: return AppColors.primary;
    }
  }
}

