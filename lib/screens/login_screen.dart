import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // (1) Key untuk Form dan controller untuk setiap field.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // (2) Buang controller saat layar ditutup.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // (3) Dijalankan saat tombol Masuk ditekan.
  // [TAMBAHAN] Memproses login dan berpindah ke Home.
void _submit() {
  final isValid = _formKey.currentState?.validate() ?? false;

  if (!isValid) return;

  // [TAMBAHAN] Navigasi menggunakan named route.
  Navigator.pushReplacementNamed(
    context,
    AppRoutes.home,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            // (4) Bungkus field dengan Form.
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Masuk',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),

                  // (5) TextFormField + controller + validator.
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 24),

                  // (6) Tombol memanggil _submit.
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}