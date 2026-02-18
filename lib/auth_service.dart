import 'dart:async';

enum LoginErrorType { emailNotRegistered, wrongPassword, inactiveAccount }

class LoginResult {
  final AppUser? user;
  final LoginErrorType? error;

  const LoginResult.success(this.user) : error = null;

  const LoginResult.failure(this.error) : user = null;
}

enum PasswordChangeErrorType { wrongCurrentPassword, weakPassword, mismatch }

class PasswordChangeResult {
  final bool isSuccess;
  final PasswordChangeErrorType? error;

  const PasswordChangeResult.success() : isSuccess = true, error = null;

  const PasswordChangeResult.failure(this.error) : isSuccess = false;
}

class AppUser {
  final String id;
  final String fullName;
  final String nik;
  final String placeOfBirth;
  final DateTime birthDate;
  final String gender;
  final String address;
  final String phoneNumber;
  final String email;
  final String username;
  final String jobTitle;
  final String role;
  final String department;
  final String employeeStatus;
  final DateTime joinDate;
  final String bankAccountNumber;
  final String? profilePhotoPath;
  final bool isActive;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.nik,
    required this.placeOfBirth,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.username,
    required this.jobTitle,
    required this.role,
    required this.department,
    required this.employeeStatus,
    required this.joinDate,
    required this.bankAccountNumber,
    this.profilePhotoPath,
    required this.isActive,
  });
}

class _AuthCredential {
  final AppUser user;
  String password;

  _AuthCredential({required this.user, required this.password});
}

class AuthService {
  final List<_AuthCredential> _credentials = <_AuthCredential>[
    _AuthCredential(
      user: AppUser(
        id: 'USR-001',
        fullName: 'Dinda Maharani',
        nik: '327600000002',
        placeOfBirth: 'Bandung',
        birthDate: DateTime(1994, 6, 12),
        gender: 'Perempuan',
        address: 'Jl. Setiabudi No. 18, Bandung',
        phoneNumber: '0812-3456-7890',
        email: 'dinda@kingroyal.com',
        username: 'dinda',
        jobTitle: 'Supervisor HR',
        role: 'Admin',
        department: 'Human Capital',
        employeeStatus: 'Tetap',
        joinDate: DateTime(2024, 1, 12),
        bankAccountNumber: '1234567890',
        isActive: true,
      ),
      password: 'Password@123',
    ),
    _AuthCredential(
      user: AppUser(
        id: 'USR-002',
        fullName: 'Reno Pratama',
        nik: '327600000003',
        placeOfBirth: 'Jakarta',
        birthDate: DateTime(1998, 9, 3),
        gender: 'Laki-laki',
        address: 'Jl. Cempaka Putih No. 22, Jakarta',
        phoneNumber: '0812-0000-1111',
        email: 'reno@kingroyal.com',
        username: 'reno',
        jobTitle: 'Staff Operasional',
        role: 'Staff',
        department: 'Front Office',
        employeeStatus: 'Kontrak',
        joinDate: DateTime(2025, 3, 1),
        bankAccountNumber: '0987654321',
        isActive: false,
      ),
      password: 'Password@123',
    ),
  ];

  Future<LoginResult> login({
    required String identity,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final normalized = identity.trim().toLowerCase();
    _AuthCredential? credential;
    for (final cred in _credentials) {
      if (cred.user.email.toLowerCase() == normalized ||
          cred.user.username.toLowerCase() == normalized) {
        credential = cred;
        break;
      }
    }

    if (credential == null) {
      return const LoginResult.failure(LoginErrorType.emailNotRegistered);
    }
    if (!credential.user.isActive) {
      return const LoginResult.failure(LoginErrorType.inactiveAccount);
    }
    if (credential.password != password) {
      return const LoginResult.failure(LoginErrorType.wrongPassword);
    }
    return LoginResult.success(credential.user);
  }

  Future<bool> requestPasswordReset(String identity) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final normalized = identity.trim().toLowerCase();
    return _credentials.any(
      (cred) =>
          cred.user.email.toLowerCase() == normalized ||
          cred.user.username.toLowerCase() == normalized,
    );
  }

  Future<PasswordChangeResult> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _AuthCredential? credential;
    for (final cred in _credentials) {
      if (cred.user.id == userId) {
        credential = cred;
        break;
      }
    }

    if (credential == null) {
      return const PasswordChangeResult.failure(
        PasswordChangeErrorType.wrongCurrentPassword,
      );
    }
    if (credential.password != currentPassword) {
      return const PasswordChangeResult.failure(
        PasswordChangeErrorType.wrongCurrentPassword,
      );
    }
    if (newPassword.length < 8) {
      return const PasswordChangeResult.failure(
        PasswordChangeErrorType.weakPassword,
      );
    }
    if (newPassword != confirmNewPassword) {
      return const PasswordChangeResult.failure(
        PasswordChangeErrorType.mismatch,
      );
    }

    credential.password = newPassword;
    return const PasswordChangeResult.success();
  }
}
