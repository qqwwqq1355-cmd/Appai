import 'package:flutter/material.dart';
import 'package:shoplensx/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _showEmailPasswordFields = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ShopLensX',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.facebook),
              label: const Text('Sign in with Facebook'),
            ),
            const SizedBox(height: 16),
            if (!_showEmailPasswordFields)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showEmailPasswordFields = true;
                  });
                },
                icon: const Icon(Icons.email),
                label: const Text('Sign in with Email'),
              ),
            if (_showEmailPasswordFields) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await _apiService.login(
                      _emailController.text,
                      _passwordController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login successful: ${result['token']}'),
                      ),
                    );
                    Navigator.pushReplacementNamed(context, '/home');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
