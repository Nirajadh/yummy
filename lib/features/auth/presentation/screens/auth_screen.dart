import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/widgets/app_text_field.dart';
import 'package:yummy/core/widgets/auth_widgets.dart';
import 'package:yummy/features/auth/presentation/bloc/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _rememberMe = false;
  AuthTab _selectedTab = AuthTab.login;

  void _switchToLogin() {
    setState(() {
      _selectedTab = AuthTab.login;
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  void _switchToSignUp() {
    setState(() {
      _selectedTab = AuthTab.signUp;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedTab == AuthTab.login) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      _showSnack('Passwords do not match');
      return;
    }

    context.read<AuthBloc>().add(
          AdminRegisterRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _loading = true);
          } else {
            setState(() => _loading = false);
          }

          if (state is AuthFailure) {
            _showSnack(state.message);
          }

          if (state is AuthLoginSuccess) {
            switch (state.role.toLowerCase()) {
              case 'kitchen':
                Navigator.pushReplacementNamed(context, '/kitchen-dashboard');
                break;
              case 'staff':
                Navigator.pushReplacementNamed(context, '/staff-dashboard');
                break;
              default:
                Navigator.pushReplacementNamed(context, '/admin-dashboard');
            }
          }

          if (state is AuthRegisterSuccess) {
            _showSnack(state.registerEntity.message);
            setState(() {
              _selectedTab = AuthTab.login;
              _passwordController.clear();
              _confirmController.clear();
            });
          }

          if (state is AuthAdminRegisterSuccess) {
            _showSnack(state.adminRegisterEntity.message);
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          }
        },
        child: Stack(
          children: [
            const AuthBackground(),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const AppLogo(size: 48),
                              const SizedBox(width: 10),
                              Text(
                                'Yummy',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Get Started now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                            Text(
                              'Create an account or log in to explore about our app',
                              style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A0F172A),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AuthTabs(
                                selected: _selectedTab,
                                onLoginTap: _switchToLogin,
                                onSignUpTap: _switchToSignUp,
                              ),
                              const SizedBox(height: 18),
                              if (_selectedTab == AuthTab.signUp) ...[
                                AppTextField(
                                  controller: _nameController,
                                  label: 'Full name',
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 14),
                              ],
                              AppTextField(
                                controller: _emailController,
                                label: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              AppPasswordField(
                                controller: _passwordController,
                                label: 'Password',
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                              if (_selectedTab == AuthTab.signUp) ...[
                                const SizedBox(height: 14),
                                AppPasswordField(
                                  controller: _confirmController,
                                  label: 'Confirm Password',
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ],
                              if (_selectedTab == AuthTab.login) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          onChanged: (value) => setState(
                                            () => _rememberMe = value ?? false,
                                          ),
                                        ),
                                        Text(
                                          'Remember me',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'Forgot Password ?',
                                        style: TextStyle(
                                          color: Color(0xFF2F6BFF),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 30),
                              GradientPrimaryButton(
                                label: _selectedTab == AuthTab.login
                                    ? 'Log In'
                                    : 'Sign Up',
                                loading: _loading,
                                onTap: _submit,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'Or',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              GoogleButton(onTap: () {}),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
