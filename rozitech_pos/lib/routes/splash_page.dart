import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/license/license_manager.dart';
import '../core/providers/database_provider.dart';
import '../core/network/dio_client.dart';
import '../features/users/data/repositories/user_repository_impl.dart';
import 'app_router.dart';
import '../core/config/app_config.dart';

/// Animated splash screen that checks license and routes accordingly.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _hasNavigated = false;

  Future<void> _triggerBackgroundSync() async {
    try {
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      final token = await storage.read(key: 'license_token');
      if (token != null && token.isNotEmpty) {
        final db = ref.read(appDatabaseProvider);
        final repo = UserRepositoryImpl(db);
        final dio = ref.read(dioProvider);
        await repo.syncUsersFromServer(token, dio);
      }
    } catch (_) {
      // Fail silently in background
    }
  }

  void _navigateToNext(LicenseStatus status) {
    if (_hasNavigated) return;
    _hasNavigated = true;

    if (status == LicenseStatus.valid) {
      _triggerBackgroundSync();
    }

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (status == LicenseStatus.valid) {
        context.go(AppRoutes.dashboard);
      } else {
        context.go(AppRoutes.activation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final licenseAsync = ref.watch(licenseStatusProvider);

    // If it's already resolved, navigate
    if (licenseAsync.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNext(licenseAsync.value!);
      });
    }

    // Also listen to future changes
    ref.listen<AsyncValue<LicenseStatus>>(licenseStatusProvider, (_, next) {
      next.whenData((status) {
        _navigateToNext(status);
      });
    });

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.6, 0.6), duration: 600.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 32),

            // App name
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.3),

            const SizedBox(height: 8),

            Text(
              '${AppConfig.appName} System',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

            const SizedBox(height: 64),

            // Loading indicator
            licenseAsync.when(
              data: (_) => Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
                size: 28,
              ).animate().scale(curve: Curves.elasticOut, duration: 500.ms),
              loading: () => SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              ),
              error: (e, _) => Text(
                'Error: $e',
                style: const TextStyle(color: Colors.red),
              ),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 16),

            Text(
              'Memuat...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}
