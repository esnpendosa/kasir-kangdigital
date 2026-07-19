import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

const _kLastUserId = 'last_logged_user_id';
const _kLastUsername = 'last_logged_username';

/// State: currently logged-in user, or null if not logged in.
class UserSessionState {
  const UserSessionState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final AppUser? user;
  final bool isLoading;
  final String? error;

  bool get isLoggedIn => user != null;

  UserSessionState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      UserSessionState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class UserSessionNotifier extends Notifier<UserSessionState> {
  late UserRepository _repo;

  @override
  UserSessionState build() {
    final db = ref.read(appDatabaseProvider);
    _repo = UserRepositoryImpl(db);
    // Auto-restore session on startup
    _restoreSession();
    return const UserSessionState(isLoading: true);
  }

  /// Restore last session from persistent storage.
  /// If a user was logged in before, auto-login them without needing a password.
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_kLastUserId);
      final username = prefs.getString(_kLastUsername);
      final displayName = prefs.getString('last_logged_display_name');
      final roleStr = prefs.getString('last_logged_role');
      final isActive = prefs.getBool('last_logged_is_active') ?? true;

      if (userId != null && username != null && roleStr != null) {
        // Restore session immediately from SharedPreferences cache to avoid blocking
        final user = AppUser(
          id: userId,
          username: username,
          displayName: displayName ?? username,
          role: AppUser.roleFromString(roleStr),
          isActive: isActive,
        );
        state = UserSessionState(user: user);

        // Verification query in background
        _verifySessionInBackground(userId);
      } else {
        // No stored session — check if this is first run, auto-login as admin if only one user exists
        final usersResult = await _repo.getUsers();
        usersResult.fold(
          (_) => state = const UserSessionState(),
          (users) {
            if (users.length == 1 && users.first.isActive) {
              // Single user → auto-login
              state = UserSessionState(user: users.first);
              _storeSession(users.first);
            } else {
              state = const UserSessionState();
            }
          },
        );
      }
    } catch (_) {
      state = const UserSessionState();
    }
  }

  Future<void> _verifySessionInBackground(int userId) async {
    try {
      final result = await _repo.getUserById(userId);
      result.fold(
        (_) {}, // fail silently, keep cached session
        (user) {
          if (!user.isActive) {
            // User deactivated, force logout
            logout();
          } else {
            // Update cached session
            _storeSession(user);
          }
        },
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> _storeSession(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastUserId, user.id);
    await prefs.setString(_kLastUsername, user.username);
    await prefs.setString('last_logged_display_name', user.displayName);
    await prefs.setString('last_logged_role', user.role.name);
    await prefs.setBool('last_logged_is_active', user.isActive);
  }

  Future<void> _clearStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastUserId);
    await prefs.remove(_kLastUsername);
    await prefs.remove('last_logged_display_name');
    await prefs.remove('last_logged_role');
    await prefs.remove('last_logged_is_active');
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repo.login(username, password);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = UserSessionState(user: user);
        _storeSession(user); // persist for next launch
        return true;
      },
    );
  }

  Future<void> logout() async {
    await _clearStoredSession();
    state = const UserSessionState();
  }

  /// Switch user without full logout (for multi-cashier scenario)
  Future<bool> switchUser(String username, String password) async {
    return login(username, password);
  }

  bool get hasOwnerRole => state.user?.role == UserRole.owner;
  bool get hasManagerRole =>
      state.user?.role == UserRole.owner ||
      state.user?.role == UserRole.manager;
}

final userSessionProvider =
    NotifierProvider<UserSessionNotifier, UserSessionState>(
  UserSessionNotifier.new,
);
