import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/network/dio_client.dart';
import '../../../users/data/repositories/user_repository_impl.dart';
import '../../../users/domain/entities/user.dart';
import '../providers/user_session_notifier.dart';

/// Simple provider for user list
final _usersProvider = FutureProvider<List<AppUser>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final repo = UserRepositoryImpl(db);
  return (await repo.getUsers()).getOrElse((_) => []);
});

/// Owner-only screen for user management.
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  bool _isSyncing = false;

  Future<void> _syncUsers() async {
    setState(() => _isSyncing = true);
    try {
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      final token = await storage.read(key: 'license_token');

      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aplikasi belum diaktivasi lisensinya'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final db = ref.read(appDatabaseProvider);
      final repo = UserRepositoryImpl(db);
      final dio = ref.read(dioProvider);

      final result = await repo.syncUsersFromServer(token, dio);
      if (mounted) {
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          ),
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Sinkronisasi pengguna berhasil!'),
                backgroundColor: Colors.green,
              ),
            );
            ref.invalidate(_usersProvider);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan sinkronisasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _showUserDialog({AppUser? user}) async {
    final nameCtrl = TextEditingController(text: user?.displayName ?? '');
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    UserRole role = user?.role ?? UserRole.cashier;
    final formKey = GlobalKey<FormState>();
    bool isActive = user?.isActive ?? true;
    bool obscurePass = true;
    bool obscureConfirm = true;
    bool changePassword = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  user == null ? Icons.person_add_rounded : Icons.edit_rounded,
                  color: Theme.of(ctx).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(user == null ? 'Tambah Pengguna' : 'Edit Pengguna'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Lengkap
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Nama diperlukan' : null,
                  ),
                  const SizedBox(height: 12),

                  // Username (hanya saat tambah)
                  if (user == null)
                    TextFormField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Username diperlukan' : null,
                    ),
                  if (user == null) const SizedBox(height: 12),

                  // Password (tambah baru: wajib; edit: opsional)
                  if (user != null) ...[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ganti Password'),
                      subtitle: const Text('Aktifkan untuk mengubah password'),
                      value: changePassword,
                      onChanged: (v) => setStateLocal(() => changePassword = v),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (user == null || changePassword) ...[
                    TextFormField(
                      controller: passCtrl,
                      obscureText: obscurePass,
                      decoration: InputDecoration(
                        labelText: user == null ? 'Password' : 'Password Baru',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setStateLocal(() => obscurePass = !obscurePass),
                        ),
                      ),
                      validator: (v) => (user == null || changePassword) &&
                              (v == null || v.length < 4)
                          ? 'Min 4 karakter'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPassCtrl,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () => setStateLocal(
                              () => obscureConfirm = !obscureConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (user == null || changePassword) {
                          if (v == null || v.isEmpty) return 'Diperlukan';
                          if (v != passCtrl.text) return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Peran
                  DropdownButtonFormField<UserRole>(
                    initialValue: role,
                    decoration: const InputDecoration(
                      labelText: 'Peran',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: UserRole.values
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.label),
                            ))
                        .toList(),
                    onChanged: (r) =>
                        setStateLocal(() => role = r ?? UserRole.cashier),
                  ),

                  // Status aktif (hanya saat edit)
                  if (user != null) ...[
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Status Aktif'),
                      subtitle: Text(
                        isActive ? 'Pengguna dapat login' : 'Pengguna diblokir',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      value: isActive,
                      onChanged: (v) => setStateLocal(() => isActive = v),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Simpan'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final db = ref.read(appDatabaseProvider);
                final repo = UserRepositoryImpl(db);

                if (user == null) {
                  // Buat user baru
                  final result = await repo.createUser(
                    AppUser(
                      id: 0,
                      username: usernameCtrl.text.trim(),
                      displayName: nameCtrl.text.trim(),
                      role: role,
                      isActive: true,
                    ),
                    passCtrl.text,
                  );
                  if (ctx.mounted) {
                    result.fold(
                      (failure) => ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(failure.message),
                          backgroundColor: Colors.red,
                        ),
                      ),
                      (_) => Navigator.pop(ctx),
                    );
                  }
                } else {
                  // Update user
                  await repo.updateUser(
                    AppUser(
                      id: user.id,
                      username: user.username,
                      displayName: nameCtrl.text.trim(),
                      role: role,
                      isActive: isActive,
                    ),
                  );

                  // Ganti password jika diaktifkan
                  if (changePassword && passCtrl.text.isNotEmpty) {
                    await repo.changePassword(user.id, passCtrl.text);
                  }

                  if (ctx.mounted) Navigator.pop(ctx);
                }

                ref.invalidate(_usersProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteUser(AppUser user, AppUser? currentUser) async {
    // Proteksi: tidak bisa hapus akun sendiri
    if (currentUser != null && user.id == currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat menghapus akun yang sedang digunakan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Hapus Pengguna'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: Theme.of(ctx).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Anda yakin ingin menghapus '),
              TextSpan(
                text: user.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: '?\n\nTindakan ini tidak dapat dibatalkan.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: const Text('Hapus'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final db = ref.read(appDatabaseProvider);
      final repo = UserRepositoryImpl(db);
      final result = await repo.deleteUser(user.id);
      if (mounted) {
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          ),
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${user.displayName} berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
            ref.invalidate(_usersProvider);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(_usersProvider);
    final currentUser = ref.watch(userSessionProvider).user;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  )
                : const Icon(Icons.sync_rounded),
            tooltip: 'Sinkronisasi dari Server',
            onPressed: _isSyncing ? null : _syncUsers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Pengguna'),
      ),
      body: usersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (users) {
          if (users.isEmpty) {
            return const EmptyStateWidget(
              title: 'Belum ada pengguna',
              subtitle: 'Tambahkan pengguna untuk mengakses sistem',
              icon: Icons.people_outline_rounded,
            );
          }

          // Info card jumlah user per toko
          final activeCount = users.where((u) => u.isActive).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // Info summary card
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withValues(alpha: 0.1),
                      cs.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.store_rounded, color: cs.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengguna Toko Ini',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '$activeCount aktif · ${users.length - activeCount} nonaktif · Total ${users.length}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),

              // User list
              ...users.asMap().entries.map((entry) {
                final i = entry.key;
                final user = entry.value;
                final isSelf = currentUser?.id == user.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: isSelf
                        ? BorderSide(
                            color: cs.primary.withValues(alpha: 0.4),
                            width: 1.5,
                          )
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 4),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                cs.primary.withValues(alpha: isSelf ? 0.2 : 0.1),
                            child: Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!user.isActive)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          if (user.isActive)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isSelf) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Anda',
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '${user.username} · ${user.role.label}${!user.isActive ? ' · Nonaktif' : ''}',
                        style: TextStyle(
                          color: !user.isActive
                              ? Colors.red.shade400
                              : cs.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tombol Edit
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: cs.primary,
                            ),
                            tooltip: 'Edit Pengguna',
                            onPressed: () => _showUserDialog(user: user),
                          ),
                          // Tombol Hapus (tidak bisa hapus diri sendiri)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: isSelf
                                  ? cs.onSurface.withValues(alpha: 0.25)
                                  : Colors.red.shade400,
                            ),
                            tooltip: isSelf
                                ? 'Tidak dapat menghapus akun sendiri'
                                : 'Hapus Pengguna',
                            onPressed: isSelf
                                ? null
                                : () => _confirmDeleteUser(user, currentUser),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.05);
              }),
            ],
          );
        },
      ),
    );
  }
}
