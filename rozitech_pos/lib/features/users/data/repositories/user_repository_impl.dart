import 'package:bcrypt/bcrypt.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._db);
  final db.AppDatabase _db;

  @override
  Future<Either<Failure, AppUser>> login(
      String username, String password) async {
    try {
      final row = await (_db.select(_db.users)
            ..where((u) =>
                u.username.equals(username) & u.isActive.equals(true)))
          .getSingleOrNull();

      if (row == null) {
        return left(const ValidationFailure('Username atau password salah'));
      }

      final match = BCrypt.checkpw(password, row.passwordHash);
      if (!match) {
        return left(const ValidationFailure('Username atau password salah'));
      }

      return right(_toEntity(row));
    } catch (e) {
      return left(DatabaseFailure('Login gagal: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AppUser>>> getUsers() async {
    try {
      final rows = await _db.select(_db.users).get();
      return right(rows.map(_toEntity).toList());
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil daftar pengguna: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> getUserById(int id) async {
    try {
      final row = await (_db.select(_db.users)
            ..where((u) => u.id.equals(id)))
          .getSingleOrNull();
      if (row == null) {
        return left(const NotFoundFailure('Pengguna tidak ditemukan'));
      }
      return right(_toEntity(row));
    } catch (e) {
      return left(DatabaseFailure('Gagal mengambil pengguna: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createUser(
      AppUser user, String plainPassword) async {
    try {
      final hash = BCrypt.hashpw(
          plainPassword, BCrypt.gensalt(logRounds: AppConstants.bcryptCost));
      final id = await _db.into(_db.users).insert(
            db.UsersCompanion.insert(
              username: user.username,
              name: user.displayName,
              passwordHash: hash,
              role: Value(user.role.name),
            ),
          );
      return right(id);
    } catch (e) {
      return left(DatabaseFailure('Gagal membuat pengguna: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(AppUser user) async {
    try {
      await (_db.update(_db.users)
            ..where((u) => u.id.equals(user.id)))
          .write(db.UsersCompanion(
        name: Value(user.displayName),
        role: Value(user.role.name),
        isActive: Value(user.isActive),
      ));
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal memperbarui pengguna: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
      int userId, String newPassword) async {
    try {
      final hash = BCrypt.hashpw(
          newPassword, BCrypt.gensalt(logRounds: AppConstants.bcryptCost));
      await (_db.update(_db.users)..where((u) => u.id.equals(userId)))
          .write(db.UsersCompanion(passwordHash: Value(hash)));
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal mengganti password: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateUser(int userId) async {
    try {
      await (_db.update(_db.users)..where((u) => u.id.equals(userId)))
          .write(const db.UsersCompanion(isActive: Value(false)));
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal menonaktifkan pengguna: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int userId) async {
    try {
      await (_db.delete(_db.users)..where((u) => u.id.equals(userId))).go();
      return right(null);
    } catch (e) {
      return left(DatabaseFailure('Gagal menghapus pengguna: $e'));
    }
  }

  @override
  Future<bool> hasUsers() async {
    final rows = await _db.select(_db.users).get();
    return rows.isNotEmpty;
  }

  @override
  Future<Either<Failure, void>> syncUsersFromServer(
      String jwtToken, Dio dio) async {
    try {
      final response = await dio.get(
        'users',
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        return left(NetworkFailure(
            response.data['message'] ?? 'Gagal mengambil data dari server'));
      }

      final List<dynamic> remoteData = response.data['data'];
      final List<String> remoteUsernames = [];

      for (final item in remoteData) {
        final username = item['username'] as String;
        final displayName = item['display_name'] as String;
        final passwordHash = (item['password_hash'] as String?) ?? '';
        final roleStr = item['role'] as String;
        final isActive = item['is_active'] as bool? ?? true;

        remoteUsernames.add(username);

        final existing = await (_db.select(_db.users)
              ..where((u) => u.username.equals(username)))
            .getSingleOrNull();

        if (existing == null) {
          await _db.into(_db.users).insert(
                db.UsersCompanion.insert(
                  username: username,
                  name: displayName,
                  passwordHash: passwordHash,
                  role: Value(roleStr),
                  isActive: Value(isActive),
                ),
              );
        } else {
          await (_db.update(_db.users)..where((u) => u.id.equals(existing.id)))
              .write(
            db.UsersCompanion(
              name: Value(displayName),
              passwordHash: passwordHash.isNotEmpty
                  ? Value(passwordHash)
                  : const Value.absent(),
              role: Value(roleStr),
              isActive: Value(isActive),
            ),
          );
        }
      }

      // Deactivate local non-cashier users that are not on the server
      final allLocalUsers = await _db.select(_db.users).get();
      for (final local in allLocalUsers) {
        if (local.role != 'cashier' &&
            !remoteUsernames.contains(local.username) &&
            local.username != 'admin') {
          await (_db.update(_db.users)..where((u) => u.id.equals(local.id)))
              .write(const db.UsersCompanion(isActive: Value(false)));
        }
      }

      return right(null);
    } catch (e) {
      return left(NetworkFailure('Sinkronisasi gagal: $e'));
    }
  }

  AppUser _toEntity(db.User row) {
    return AppUser(
      id: row.id,
      username: row.username,
      displayName: row.name,
      role: AppUser.roleFromString(row.role),
      isActive: row.isActive,
      passwordHash: row.passwordHash,
      createdAt: row.createdAt,
    );
  }
}
