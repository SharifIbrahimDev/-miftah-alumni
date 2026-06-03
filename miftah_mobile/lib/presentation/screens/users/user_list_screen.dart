import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_member_screen.dart';

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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Change Role for ${user.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: DropdownButtonFormField<String>(
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
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final success = await context.read<UserProvider>().updateUserRole(user.id, selectedRole);
                if (success) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Role updated successfully'), backgroundColor: AppColors.success),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Member Directory'),
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
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search members...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.close), onPressed: () { _searchController.clear(); setState(() {}); })
                        : null,
                  ),
                ),
              ),
              Expanded(
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
                            color: roleColor.withOpacity(0.1),
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
                                color: roleColor.withOpacity(0.1),
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

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'president': return AppColors.accent;
      case 'registrar': return Colors.blue;
      case 'cashier': return Colors.orange;
      default: return AppColors.primary;
    }
  }
}

