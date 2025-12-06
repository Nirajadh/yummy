import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:yummy/core/widgets/auth_widgets.dart';
import 'package:yummy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yummy/features/restaurant/presentation/restaurant_details_screen.dart';

enum _OtpAction { none, verify, resend }

/// Arguments passed from the admin sign up step.
class AdminOtpScreenArgs {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final int? initialSecondsLeft;

  const AdminOtpScreenArgs({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.initialSecondsLeft,
  });
}

/// Final admin OTP verification screen based on Layout 1A.
class AdminOtpScreen extends StatefulWidget {
  const AdminOtpScreen({super.key, this.args});

  final AdminOtpScreenArgs? args;

  @override
  State<AdminOtpScreen> createState() => _AdminOtpScreenState();
}

class _AdminOtpScreenState extends State<AdminOtpScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _otpController;
  Timer? _timer;
  int _secondsLeft = 120;
  bool _verifying = false;
  String? _otpError;
  String? _resendMessage;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    );
    // If we know remaining seconds from backend (e.g. OTP already sent),
    // start from that value; otherwise use full 120s.
    final initial = widget.args?.initialSecondsLeft;
    _startTimer(startFrom: initial);
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startTimer({int? startFrom}) {
    _timer?.cancel();
    setState(() {
      _secondsLeft = startFrom != null && startFrom > 0 ? startFrom : 120;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _formattedTime {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _displayEmail {
    final email = widget.args?.email ?? 'admin***@example.com';
    final atIndex = email.indexOf('@');
    if (atIndex <= 1) return email;
    final first = email.substring(0, 1);
    final domain = email.substring(atIndex);
    return '$first***$domain';
  }

  /// Last action that triggered an auth request from this screen,
  /// used to distinguish between verify and resend failures.
  _OtpAction _lastAction = _OtpAction.none;

  Future<void> _onVerifyPressed() async {
    if (_otpController.text.trim().length != 6) {
      _showSnack('Please enter the 6-digit code');
      return;
    }
    if (_secondsLeft <= 0) {
      FocusScope.of(context).unfocus();
      setState(() {
        _otpError = 'Code expired. Please resend a new code.';
        _otpController.clear();
      });
      _shakeController.forward(from: 0);
      return;
    }
    final args = widget.args;
    if (args == null) {
      _showSnack('Something went wrong. Please go back and try again.');
      return;
    }

    _lastAction = _OtpAction.verify;
    context.read<AuthBloc>().add(
      AdminRegisterVerifyRequested(
        name: args.name,
        email: args.email,
        password: args.password,
        confirmPassword: args.confirmPassword,
        otp: _otpController.text.trim(),
      ),
    );
  }

  void _onResend() {
    final args = widget.args;
    if (args == null) {
      _showSnack('Something went wrong. Please go back and try again.');
      return;
    }

    _lastAction = _OtpAction.resend;
    context.read<AuthBloc>().add(
      AdminRegisterResendRequested(email: args.email),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/auth');
        return false;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              setState(() => _verifying = true);
            } else {
              if (_verifying) {
                setState(() => _verifying = false);
              }
            }

            if (state is AuthFailure) {
              _shakeController.forward(from: 0);
              if (_lastAction == _OtpAction.verify) {
                // Use local timer to decide expired vs invalid.
                final isExpired = _secondsLeft <= 0;
                final uiMessage = isExpired
                    ? 'Code expired. Please resend a new code.'
                    : 'Invalid OTP';

                setState(() {
                  _otpError = uiMessage;
                  if (isExpired) {
                    _otpController.clear();
                  }
                });

                if (isExpired) {
                  _shakeController.forward(from: 0);
                }
              } else {
                // Resend failed: show backend message, but do not mark OTP invalid.
              }
            }

            if (state is AuthAdminRegisterResendSuccess) {
              _showSnack(state.adminRegisterEntity.message);
              setState(() {
                _resendMessage = state.adminRegisterEntity.message;
                _otpError = null;
                _otpController.clear();
              });
              _startTimer();
            }

            if (state is AuthAdminRegisterVerifySuccess) {
              setState(() {
                _otpError = null;
                _resendMessage = null;
              });
            }

            if (state is AuthAdminRegisterVerifySuccess) {
              _showSnack(state.adminRegisterEntity.message);
              Navigator.pushReplacementNamed(
                context,
                '/restaurant-setup',
                arguments: const RestaurantDetailsArgs(
                  allowSkip: true,
                  redirectRoute: '/admin-dashboard',
                ),
              );
            }
          },
          child: Stack(
            children: [
              const AuthBackground(),
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/auth',
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Verify your email',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'We’ve sent a 6-digit code to',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            Text(
                              _displayEmail,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
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
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  20,
                                  18,
                                  5,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE5EDFF),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            'Step 2 of 3',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: const Color(
                                                    0xFF2F6BFF,
                                                  ),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Text(
                                            'Admin',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Enter verification code',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'For your security, this code will expire in 2 minutes.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    const SizedBox(height: 22),
                                    AnimatedBuilder(
                                      animation: _shakeAnimation,
                                      builder: (context, child) {
                                        final t = _shakeAnimation.value;
                                        final dx = t == 0
                                            ? 0.0
                                            : (8 *
                                                  (1 - t) *
                                                  math.sin(t * math.pi * 8));
                                        return Transform.translate(
                                          offset: Offset(dx, 0),
                                          child: child,
                                        );
                                      },
                                      child: _OtpPinput(
                                        controller: _otpController,
                                        hasError: _otpError != null,
                                        onChanged: (value) {
                                          if (_otpError != null ||
                                              _resendMessage != null) {
                                            setState(() {
                                              _otpError = null;
                                              _resendMessage = null;
                                            });
                                          }
                                        },
                                        onCompleted: () {
                                          _onVerifyPressed();
                                        },
                                      ),
                                    ),
                                    if (_otpError != null) ...[
                                      const SizedBox(height: 6),
                                      Center(
                                        child: Text(
                                          _otpError!,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: Colors.red.shade600,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 18),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.timer_outlined,
                                              size: 18,
                                              color: Color(0xFF2F6BFF),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Expires in $_formattedTime',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey.shade700,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: _secondsLeft == 0
                                              ? _onResend
                                              : null,
                                          child: Text(
                                            'Resend code',
                                            style: TextStyle(
                                              color: _secondsLeft == 0
                                                  ? const Color(0xFF2F6BFF)
                                                  : Colors.grey.shade400,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_resendMessage != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        _resendMessage!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.green.shade600,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Layout 1A Pinput styling extracted into a reusable widget.
class _OtpPinput extends StatelessWidget {
  const _OtpPinput({
    required this.controller,
    required this.hasError,
    required this.onChanged,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseDecoration = BoxDecoration(
      color: hasError ? Colors.red.shade50 : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: hasError ? Colors.red.shade400 : Colors.grey.shade300,
        width: 1.2,
      ),
    );

    final defaultTheme = PinTheme(
      width: 42,
      height: 52,
      textStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Colors.black,
      ),
      decoration: baseDecoration,
    );

    return Pinput(
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onClipboardFound: (value) => controller.setText(value),
      length: 6,
      controller: controller,
      autofocus: true,
      errorText: null,
      keyboardType: TextInputType.number,
      closeKeyboardWhenCompleted: false,
      pinputAutovalidateMode: PinputAutovalidateMode.disabled,
      defaultPinTheme: defaultTheme,
      focusedPinTheme: defaultTheme.copyWith(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasError ? Colors.red.shade500 : const Color(0xFF2F6BFF),
            width: 1.4,
          ),
        ),
      ),

      cursor: Container(width: 2, height: 24, color: theme.primaryColor),
      onChanged: onChanged,
      onCompleted: (_) => onCompleted(),

      useNativeKeyboard: true,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
    );
  }
}
