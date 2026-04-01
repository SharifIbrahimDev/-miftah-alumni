import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'member_dashboard.dart';
import 'cashier_dashboard.dart';
import 'registrar_dashboard.dart';
import 'president_dashboard.dart';

class DashboardSelector extends StatelessWidget {
  const DashboardSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user.isPresident) return const PresidentDashboard();
    if (user.isCashier) return const CashierDashboard();
    if (user.isRegistrar) return const RegistrarDashboard();
    return const MemberDashboard();
  }
}
