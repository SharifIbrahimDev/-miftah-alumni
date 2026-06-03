import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/shared_prefs_manager.dart';
import 'data/datasources/remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/contribution_repository_impl.dart';
import 'data/repositories/project_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/contribution_provider.dart';
import 'presentation/providers/project_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/screens/main_layout.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'core/services/notification_service.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsManager.init();
  await NotificationService.initialize();

  final remoteDataSource = RemoteDataSource();
  final authRepository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
  final contributionRepository = ContributionRepository(remoteDataSource: remoteDataSource);
  final projectRepository = ProjectRepository(remoteDataSource: remoteDataSource);
  final userRepository = UserRepositoryImpl(remoteDataSource: remoteDataSource);
  final dashboardRepository = DashboardRepository(remoteDataSource: remoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ContributionProvider(repo: contributionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(repo: projectRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(repo: userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(repo: dashboardRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: const MiftahAlumniApp(),
    ),
  );
}

class MiftahAlumniApp extends StatelessWidget {
  const MiftahAlumniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    
    return MaterialApp(
      title: 'Miftah Alumni Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: auth.isAuthenticated ? const MainLayout() : const LoginScreen(),
    );
  }
}
