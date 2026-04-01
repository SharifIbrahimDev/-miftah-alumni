import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/shared_prefs_manager.dart';
import 'data/datasources/remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/contribution_repository_impl.dart';
import 'data/repositories/project_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/contribution_provider.dart';
import 'presentation/providers/project_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsManager.init();

  final remoteDataSource = RemoteDataSource();
  final authRepository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
  final contributionRepository = ContributionRepository(remoteDataSource: remoteDataSource);
  final projectRepository = ProjectRepository(remoteDataSource: remoteDataSource);
  final userRepository = UserRepositoryImpl(remoteDataSource: remoteDataSource);

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
      ],
      child: const MiftahAlumniApp(),
    ),
  );
}

class MiftahAlumniApp extends StatelessWidget {
  const MiftahAlumniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miftah Alumni Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
