import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/user_provider.dart';
import '../profile/profile_screen.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_drawer.dart';

class CashierDashboard extends StatefulWidget {
  const CashierDashboard({super.key});

  @override
  State<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends State<CashierDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ContributionProvider>().fetchAllContributions();
      context.read<ContributionProvider>().fetchExpenses();
      context.read<UserProvider>().fetchUsers(); // For member selection in dialogs
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user?.name ?? 'Cashier'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTodaySummary(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('FINANCIAL OPERATIONS'),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('PENDING COLLECTIONS'),
                  const SizedBox(height: 16),
                  _buildPendingDues(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDueDialog() {
    final provider = context.read<ContributionProvider>();
    final amountController = TextEditingController(text: provider.standardMonthlyDue.toStringAsFixed(0));
    final monthController = TextEditingController(text: 'April 2026');
    int? selectedUserId;
    
    // Helper to update amount when month changes
    void updateDefaultAmount(String monthYear) {
      final parts = monthYear.split(' ');
      if (parts.length == 2) {
        try {
          final amount = provider.getAmountForMonth(parts[0], int.parse(parts[1]));
          amountController.text = amount.toStringAsFixed(0);
        } catch (_) {}
      }
    }

    monthController.addListener(() => updateDefaultAmount(monthController.text));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Record Monthly Due', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProv, _) {
                    final members = userProv.users;
                    return DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Member',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: selectedUserId,
                      items: members.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))).toList(),
                      onChanged: (val) => setDialogState(() => selectedUserId = val),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildDialogField(monthController, 'Contribution Month', Icons.calendar_month_outlined),
                _buildDialogField(amountController, 'Amount (₦)', Icons.payments_outlined, isNumber: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedUserId == null) return;
                final success = await context.read<ContributionProvider>().recordContribution(
                      selectedUserId!,
                      double.parse(amountController.text),
                      monthController.text,
                      'paid',
                    );
                if (success) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment recorded successfully!'), backgroundColor: AppColors.success),
                  );
                }
              },
              child: const Text('Confirm Payment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewExpenseDialog() {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'General';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Record New Expense', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(descController, 'Description', Icons.description_outlined),
                _buildDialogField(amountController, 'Amount (₦)', Icons.payments_outlined, isNumber: true),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: selectedCategory,
                  items: ['General', 'Maintenance', 'Event', 'Welfare'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => selectedCategory = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                if (amountController.text.isEmpty) return;
                final success = await context.read<ContributionProvider>().recordExpense(
                      descController.text,
                      double.parse(amountController.text),
                      selectedCategory,
                    );
                if (success) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense recorded successfully!'), backgroundColor: AppColors.error),
                  );
                }
              },
              child: const Text('Confirm Expense', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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

  Widget _buildSliverAppBar(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'FINANCIAL DESK',
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

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionTile(
          context,
          'Record Month Due',
          Icons.calendar_today_rounded,
          AppColors.primary,
          _showRecordDueDialog,
        ),
        const SizedBox(width: 16),
        _buildActionTile(
          context,
          'New Expense',
          Icons.payments_outlined,
          AppColors.error,
          _showNewExpenseDialog,
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GlassCard(
        padding: EdgeInsets.zero,
        baseColor: color,
        opacity: 0.08,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySummary() {
    return Consumer<ContributionProvider>(
      builder: (context, provider, _) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final todayContributions = provider.allContributions.where((c) => DateFormat('yyyy-MM-dd').format(c.createdAt) == today && c.status == 'paid').toList();
        final todayExpenses = provider.expenses.where((e) => DateFormat('yyyy-MM-dd').format(e.createdAt) == today).toList();
        
        final inflow = todayContributions.fold(0.0, (sum, c) => sum + c.amount);
        final count = todayContributions.length + todayExpenses.length;

        return GlassCard(
          baseColor: AppColors.primary,
          opacity: 0.95,
          padding: const EdgeInsets.all(28),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          child: Column(
            children: [
              Text(
                'TOTAL RECORDED TODAY',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('₦${inflow.toStringAsFixed(0)}', 'INFLOW', Icons.add_circle_outline_rounded),
                  Container(height: 40, width: 1, color: Colors.white12),
                  _buildSummaryItem('$count', 'RECEIPTS', Icons.receipt_long_rounded),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(height: 8),
        Text(
          value, 
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
        ),
        Text(
          label, 
          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)
        ),
      ],
    );
  }

  Widget _buildPendingDues() {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        final members = provider.users.take(5).toList();
        
        if (members.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text('No members found to collect from.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = members[index];
            final provider = context.read<ContributionProvider>();
            final currentMonth = DateFormat('MMMM').format(DateTime.now());
            final currentYear = DateTime.now().year;
            final amount = provider.getAmountForMonth(currentMonth, currentYear);
            
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
                  'DUES: ₦${amount.toStringAsFixed(0)} | DUE: $currentMonth $currentYear',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.bold),
                ),
                trailing: InkWell(
                  onTap: () async {
                    final success = await provider.recordContribution(
                          user.id,
                          amount,
                          '$currentMonth $currentYear',
                          'paid',
                        );
                    if (success) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Marketed ₦${amount.toStringAsFixed(0)} for ${user.name}'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'COLLECT', 
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.error)
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }
}
