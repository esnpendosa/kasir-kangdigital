import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Abstract user repository interface.
abstract class UserRepository {
  Future<Either<Failure, AppUser>> login(String username, String password);
  Future<Either<Failure, List<AppUser>>> getUsers();
  Future<Either<Failure, AppUser>> getUserById(int id);
  Future<Either<Failure, int>> createUser(AppUser user, String plainPassword);
  Future<Either<Failure, void>> updateUser(AppUser user);
  Future<Either<Failure, void>> changePassword(int userId, String newPassword);
  Future<Either<Failure, void>> deactivateUser(int userId);
  Future<Either<Failure, void>> deleteUser(int userId);
  Future<bool> hasUsers();
  Future<Either<Failure, void>> syncUsersFromServer(String jwtToken, Dio dio);
}
