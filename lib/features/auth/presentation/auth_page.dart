import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/erish_button.dart';
import '../services/auth_service.dart';

enum AuthTab { signIn, signUp }

/// ERISH Official Customer Authentication Page (`/login`, `/signup`, `/auth`)
/// Provides Sign In and New Customer Account Registration with form validation,
/// password visibility toggling, password reset flows, and luxury styling.
class AuthPage extends StatefulWidget {
  final AuthTab initialTab;

  const AuthPage({super.key, this.initialTab = AuthTab.signIn});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late AuthTab _activeTab;

  // Controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  // State
  bool _obscureSignInPassword = true;
  bool _obscureSignUpPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPhoneController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = AuthService();
    final result = await authService.signIn(
      email: _signInEmailController.text.trim(),
      password: _signInPasswordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome back, ${authService.displayName} ✦',
            style: AppTypography.button(color: AppColors.warmIvory),
          ),
          backgroundColor: AppColors.espresso,
          duration: const Duration(seconds: 2),
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = AuthService();
    final result = await authService.signUp(
      name: _signUpNameController.text.trim(),
      email: _signUpEmailController.text.trim(),
      password: _signUpPasswordController.text,
      phone: _signUpPhoneController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome to ERISH, ${_signUpNameController.text.trim()} ✦',
            style: AppTypography.button(color: AppColors.warmIvory),
          ),
          backgroundColor: AppColors.espresso,
          duration: const Duration(seconds: 3),
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _signInEmailController.text);
    bool sending = false;
    String? dialogStatus;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.warmIvory,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reset Password',
                        style: AppTypography.sectionTitle(color: AppColors.espresso),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enter your account email to receive a password recovery link.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body(color: AppColors.muted),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Account Email',
                          border: OutlineInputBorder(),
                        ),
                        style: AppTypography.body(color: AppColors.espresso),
                      ),
                      if (dialogStatus != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          dialogStatus!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: dialogStatus!.contains('sent')
                                ? AppColors.pink
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ErishButton(
                          text: sending ? 'Sending Link...' : 'Send Recovery Link',
                          onPressed: sending
                              ? null
                              : () async {
                                  final email = emailCtrl.text.trim();
                                  if (email.isEmpty || !email.contains('@')) {
                                    setDialogState(() {
                                      dialogStatus = 'Please enter a valid email address.';
                                    });
                                    return;
                                  }

                                  setDialogState(() {
                                    sending = true;
                                    dialogStatus = null;
                                  });

                                  final res = await AuthService().sendPasswordReset(email);

                                  setDialogState(() {
                                    sending = false;
                                    if (res.isSuccess) {
                                      dialogStatus =
                                          'Recovery email sent. Please check your inbox.';
                                    } else {
                                      dialogStatus = res.errorMessage;
                                    }
                                  });
                                },
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: Text(
                          'CANCEL',
                          style: AppTypography.button(color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.espresso),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: GestureDetector(
          onTap: () => context.go('/'),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Image.asset(
              'assets/images/erish-logo.png',
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                'ERISH',
                style: AppTypography.cardTitle(color: AppColors.espresso),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20.0 : 32.0,
            vertical: 24.0,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 24.0 : 36.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.sandBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand Header
                  Text(
                    'AUTHENTICATION',
                    style: AppTypography.eyebrow(color: AppColors.pink),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _activeTab == AuthTab.signIn
                        ? 'Sign In to ERISH'
                        : 'Create an Account',
                    style: AppTypography.sectionTitle(
                      color: AppColors.espresso,
                      isMobile: isMobile,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _activeTab == AuthTab.signIn
                        ? 'Access your orders, saved addresses, and wanderlust edits.'
                        : 'Join the world of ERISH for bespoke curation and seamless orders.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(color: AppColors.muted),
                  ),
                  const SizedBox(height: 28),

                  // Segmented Tabs: SIGN IN vs CREATE ACCOUNT
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.warmIvory,
                      border: Border.all(color: AppColors.sandBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _activeTab = AuthTab.signIn;
                                _errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              color: _activeTab == AuthTab.signIn
                                  ? AppColors.espresso
                                  : Colors.transparent,
                              alignment: Alignment.center,
                              child: Text(
                                'SIGN IN',
                                style: AppTypography.button(
                                  color: _activeTab == AuthTab.signIn
                                      ? AppColors.warmIvory
                                      : AppColors.espresso,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _activeTab = AuthTab.signUp;
                                _errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              color: _activeTab == AuthTab.signUp
                                  ? AppColors.espresso
                                  : Colors.transparent,
                              alignment: Alignment.center,
                              child: Text(
                                'REGISTER',
                                style: AppTypography.button(
                                  color: _activeTab == AuthTab.signUp
                                      ? AppColors.warmIvory
                                      : AppColors.espresso,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      color: Colors.red.shade50,
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 18,
                            color: Colors.red.shade800,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Form Fields
                  if (_activeTab == AuthTab.signIn)
                    _buildSignInForm()
                  else
                    _buildSignUpForm(),

                  const SizedBox(height: 24),

                  // Return link
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: Text(
                      '← Continue as Guest to Storefront',
                      style: AppTypography.button(color: AppColors.espresso),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _signInEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
            style: AppTypography.body(color: AppColors.espresso),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your email.';
              }
              if (!val.contains('@') || !val.contains('.')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signInPasswordController,
            obscureText: _obscureSignInPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignInPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _obscureSignInPassword = !_obscureSignInPassword;
                  });
                },
              ),
            ),
            style: AppTypography.body(color: AppColors.espresso),
            onFieldSubmitted: (_) => _handleSignIn(),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please enter your password.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot password?',
                style: AppTypography.caption(
                  color: AppColors.pink,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ErishButton(
            text: _isLoading ? 'Signing In...' : 'Sign In',
            onPressed: _isLoading ? null : _handleSignIn,
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _signUpNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Meera Patel',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline, size: 18),
            ),
            style: AppTypography.body(color: AppColors.espresso),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your full name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signUpEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
            style: AppTypography.body(color: AppColors.espresso),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter an email.';
              }
              if (!val.contains('@') || !val.contains('.')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signUpPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number (Optional)',
              hintText: '+91 98765 43210',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_outlined, size: 18),
            ),
            style: AppTypography.body(color: AppColors.espresso),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signUpPasswordController,
            obscureText: _obscureSignUpPassword,
            decoration: InputDecoration(
              labelText: 'Password (min. 6 characters)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignUpPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _obscureSignUpPassword = !_obscureSignUpPassword;
                  });
                },
              ),
            ),
            style: AppTypography.body(color: AppColors.espresso),
            onFieldSubmitted: (_) => _handleSignUp(),
            validator: (val) {
              if (val == null || val.length < 6) {
                return 'Password must be at least 6 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'By creating an account, you agree to receive order notifications and bespoke collection updates from ERISH.',
            style: AppTypography.caption(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          ErishButton(
            text: _isLoading ? 'Creating Account...' : 'Create Account',
            onPressed: _isLoading ? null : _handleSignUp,
          ),
        ],
      ),
    );
  }
}
