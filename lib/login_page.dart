import 'package:absensi_king_royal/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;
  final void Function(AppUser user, bool rememberMe) onLoginSuccess;

  const LoginPage({
    super.key,
    required this.authService,
    required this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _hidePassword = true;
  bool _isLoading = false;
  String? _serverError;

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mapLoginError(LoginErrorType error) {
    switch (error) {
      case LoginErrorType.emailNotRegistered:
        return 'Email/username tidak terdaftar.';
      case LoginErrorType.wrongPassword:
        return 'Password salah.';
      case LoginErrorType.inactiveAccount:
        return 'Akun nonaktif. Silakan hubungi admin.';
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _serverError = null;
    });

    final result = await widget.authService.login(
      identity: _identityController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.user != null) {
      widget.onLoginSuccess(result.user!, _rememberMe);
      return;
    }

    setState(() => _serverError = _mapLoginError(result.error!));
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _identityController.text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lupa Password'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Email/Username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty || !mounted) return;
    final exists = await widget.authService.requestPasswordReset(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exists
              ? 'Permintaan reset password terkirim (mock).'
              : 'Akun tidak ditemukan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icons/app_icon.jpg',
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Login Absensi King Royal',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _identityController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email / Username',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email/username wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => _hidePassword = !_hidePassword);
                            },
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password wajib diisi.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (_serverError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _serverError!,
                          style: const TextStyle(
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                          ),
                          const Text('Remember me'),
                          const Spacer(),
                          TextButton(
                            onPressed: _forgotPassword,
                            child: const Text(
                              'Lupa password?',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          child: Text(_isLoading ? 'Memproses...' : 'Login'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Siap dihubungkan ke database: ganti implementasi AuthService.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
