import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';

import '../../../core/constants/app_color.dart';
import '../../../data/datasources/remote/firebase_service/firebase_auth_service.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widget/common/custom_button.dart';
import '../../widget/common/custom_text_field.dart';
import '../../widget/common/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        ResetPasswordEvent(email: _emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        authService: FirebaseAuthService(),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is PasswordResetSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password reset link sent to ${state.email}'),
                  backgroundColor: AppColors.income,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.expense,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state is AuthLoading,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Icon
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_reset,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Forgot Password?',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your email address and we\'ll send you a link to reset your password.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Email field
                        CustomTextField(
                          label: 'Email',
                          hint: 'Enter your email',
                          controller: _emailController,
                          validator: Validators.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 32),

                        // Reset button
                        CustomButton(
                          text: 'Send Reset Link',
                          onPressed: _handleResetPassword,
                          isLoading: state is AuthLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}