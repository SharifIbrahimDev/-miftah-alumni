import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contribution_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../profile/profile_screen.dart';
import '../users/user_list_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../projects/project_list_screen.dart';
import '../../widgets/app_drawer.dart';
import 'package:miftah_mobile/core/services/report_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/utils/toast_service.dart';

class PresidentDashboard extends StatefulWidget {
  const PresidentDashboard({super.key});

  @override
  State<PresidentDashboard> createState() => _PresidentDashboardState();
}

class _PresidentDashboardState extends State<PresidentDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ContributionProvider>().fetchAllContributions();
      context.read<ContributionProvider>().fetchExpenses();
      context.read<UserProvider>().fetchUsers();
      context.read<DashboardProvider>().fetchDashboardData();
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
          _buildSliverAppBar(context, user?.name ?? 'President'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainBalanceCard(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('FINANCIAL INSIGHTS'),
                  const SizedBox(height: 16),
                  _buildFinancialInsights(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('QUICK ACTIONS'),
                  const SizedBox(height: 16),
                  _buildActionsGrid(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader('RECENT ACTIVITY'),
                  const SizedBox(height: 16),
                  _buildRecentActivityList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'EXECUTIVE COMMAND',
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
          color: Colors.white.withOpacity(0.9),
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
                    AppColors.primary.withOpacity(0.3),
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
                    'Assalamu Alaikum,',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 32,
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
          onPressed: () {
            final provider = context.read<ContributionProvider>();
            final totalIncome = provider.allContributions.where((c) => c.status == 'paid').fold(0.0, (sum, c) => sum + c.amount);
            final totalExpense = provider.expenses.fold(0.0, (sum, e) => sum + e.amount);
            ReportService.generateFinancialReport(
              organizationName: 'Miftah Alumni Hub',
              contributions: provider.allContributions,
              totalIncome: totalIncome,
              totalExpense: totalExpense,
            );
          },
          icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          icon: const Icon(Icons.shield_outlined, color: Colors.white),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.primary.withOpacity(0.6),
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildMainBalanceCard() {
    return GlassCard(
      baseColor: AppColors.primary,
      opacity: 0.9,
      padding: const EdgeInsets.all(28),
      border: Border.all(color: Colors.white.withOpacity(0.15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TREASURY',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Icon(Icons.account_balance_rounded, color: AppColors.accent.withOpacity(0.5), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<DashboardProvider>(
            builder: (context, dashboard, _) {
              if (dashboard.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white));
              final balance = ((dashboard.stats?['total_collected_monthly'] ?? 0) - (dashboard.stats?['total_expenses'] ?? 0));
              
              return Text(
                '₦${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Total Unified Liquidity',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 32),
          Consumer<DashboardProvider>(
            builder: (context, dashboard, _) {
              final totalIncome = (dashboard.stats?['total_collected_monthly'] ?? 0).toDouble();
              final totalExpense = (dashboard.stats?['total_expenses'] ?? 0).toDouble();
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBalanceDetail('Inflow', '₦${(totalIncome/1000000).toStringAsFixed(1)}M', Icons.expand_less_rounded, Colors.greenAccent),
                  _buildBalanceDetail('Outflow', '₦${(totalExpense/1000000).toStringAsFixed(1)}M', Icons.expand_more_rounded, Colors.redAccent),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(String label, String value, IconData icon, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(), 
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)
              ),
              Text(
                value, 
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildActionItem(
          context,
          'Members',
          Icons.people_rounded,
          const Color(0xFF1976D2),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen())),
        ),
        _buildActionItem(
          context,
          'Finance',
          Icons.account_balance_wallet_rounded,
          const Color(0xFF2E7D32),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionListScreen())),
        ),
        _buildActionItem(
          context,
          'Projects',
          Icons.rocket_launch_rounded,
          const Color(0xFFF57C00),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectListScreen())),
        ),
        _buildActionItem(
          context,
          'Due Setup',
          Icons.settings_suggest_rounded,
          const Color(0xFF00796B),
          () => _showUpdateDueDialog(context),
        ),
      ],
    );
  }

  void _showUpdateDueDialog(BuildContext context) {
    final provider = context.read<ContributionProvider>();
    final amountController = TextEditingController(text: provider.standardMonthlyDue.toStringAsFixed(0));
    String selectedMonth = provider.effectiveMonth;
    int selectedYear = provider.effectiveYear;

    final List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    CustomDialogBox.show(
      context: context,
      title: 'Update Standard Due',
      content: StatefulBuilder(
        builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Specify the new monthly contribution rate and the effective start date.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  label: 'New Amount (₦)',
                  prefixIcon: Icons.payments_outlined,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Effective Month',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: selectedMonth,
                  items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (val) => setDialogState(() => selectedMonth = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Effective Year',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: selectedYear,
                  items: [2026, 2027, 2028].map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                  onChanged: (val) => setDialogState(() => selectedYear = val!),
                ),
              ],
            ),
          ),
      ),
      actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            SizedBox(
              width: 140,
              child: CustomButton(
                text: 'Save',
                onPressed: () {
                  if (amountController.text.isEmpty) return;
                  provider.updateStandardDue(double.parse(amountController.text), selectedMonth, selectedYear);
                  Navigator.pop(context);
                  ToastService.showSuccess(context, 'Financial Standard updated for $selectedMonth $selectedYear onwards.');
                },
              ),
            ),
          ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      opacity: 0.05,
      border: Border.all(color: Colors.black.withOpacity(0.04)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialInsights() {
    return GlassCard(
      height: 240,
      opacity: 0.05,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Trend',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
              const Icon(Icons.show_chart_rounded, size: 18, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) => FlLine(color: AppColors.textSecondary.withOpacity(0.1), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Text(months[value.toInt()], style: const TextStyle(color: Colors.white54, fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 5000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1000),
                      FlSpot(1, 1500),
                      FlSpot(2, 1200),
                      FlSpot(3, 3000),
                      FlSpot(4, 2800),
                      FlSpot(5, 4500),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboard, _) {
        if (dashboard.isLoading) return const Center(child: CircularProgressIndicator());
        final recentList = dashboard.stats?['recent_monthly'] as List? ?? [];
        if (recentList.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.history_rounded,
            title: 'No Recent Activity',
            subtitle: 'There is no recent activity to display right now.',
          );
        }
        
        return Column(
          children: recentList.map((activity) {
            final name = activity['user']?['name'] ?? 'Unknown User';
            final amount = '₦${activity['amount'] ?? 0}';
            final type = 'MONTHLY DUES';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                opacity: 0.05,
                border: Border.all(color: Colors.black.withOpacity(0.04)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        name.isNotEmpty ? name[0] : '?', 
                        style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name, 
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)
                          ),
                          const SizedBox(height: 2),
                          Text(
                            type, 
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary, 
                              fontSize: 11, 
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            )
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amount,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                        ),
                        Text(
                          'CREDIT',
                          style: GoogleFonts.inter(fontSize: 9, color: AppColors.success, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
