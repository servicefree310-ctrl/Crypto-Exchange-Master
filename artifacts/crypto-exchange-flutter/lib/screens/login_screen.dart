import 'package:flutter/material.dart';
import '../theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: const Icon(Icons.account_circle, color: AppColors.primary, size: 40),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Welcome to ZEBVIX',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.fg)),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text('Sign in to continue trading',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ),
              const SizedBox(height: 28),
              const TextField(
                style: TextStyle(color: AppColors.fg),
                decoration: InputDecoration(
                  labelText: 'Email or Phone',
                  labelStyle: TextStyle(color: AppColors.muted),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                obscureText: true,
                style: TextStyle(color: AppColors.fg),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: AppColors.muted),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: const Text("Don't have an account? Sign Up",
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
