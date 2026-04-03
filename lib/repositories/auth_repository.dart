abstract class AuthRepository {
  Future<bool> signIn({required String email, required String password});
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  });
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<bool> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return true;
  }

  @override
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return true;
  }
}
