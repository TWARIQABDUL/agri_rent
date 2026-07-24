import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const Color _green = Color(0xFF2E7D32);
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _tint = Color(0xFFE8F1E5);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Full name is required';
    if (t.length < 2) return 'Name is too short';
    return null;
  }

  String? _validateEmail(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!re.hasMatch(t)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    final t = v ?? '';
    if (t.isEmpty) return 'Password is required';
    if (t.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please accept the Terms to continue')),
        );
      return;
    }
    context.read<AuthBloc>().add(
      SignUpWithEmailRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade600,
                ),
              );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 22, 28, 14),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome to AgriRent,',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: _green,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Hello there, let's create your account.",
                          style: TextStyle(fontSize: 14, color: _muted),
                        ),
                        const SizedBox(height: 16),
                        _illustration(),
                        const SizedBox(height: 8),
                        _nameField(),
                        const SizedBox(height: 13),
                        _emailField(),
                        const SizedBox(height: 13),
                        _passwordField(),
                        const SizedBox(height: 14),
                        _termsRow(),
                        const SizedBox(height: 20),
                        _createAccountButton(),
                        const SizedBox(height: 22),
                        _signInFooter(),
                      ],
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

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
      decoration: const BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          if (Navigator.canPop(context))
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(width: 14),
          const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _illustration() {
    return SizedBox(
      height: 160,
      child: Center(
        child: Container(
          width: 148,
          height: 148,
          decoration: const BoxDecoration(color: _tint, shape: BoxShape.circle),
          child: Container(
            width: 76,
            height: 114,
            margin: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_add_alt_1,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameField() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      validator: _validateName,
      decoration: _fieldDecoration(
        hint: 'Full name',
        icon: Icons.person_outline,
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: _validateEmail,
      decoration: _fieldDecoration(
        hint: 'Email address',
        icon: Icons.mail_outline,
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscure,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.newPassword],
      validator: _validatePassword,
      onFieldSubmitted: (_) => _submit(),
      decoration: _fieldDecoration(
        hint: 'Password',
        icon: Icons.lock_outline,
        suffix: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFF9CA3AF),
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: 1.5),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _muted, fontSize: 14),
      prefixIcon: Icon(icon, color: _green, size: 19),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: border(_border),
      focusedBorder: border(_green),
      errorBorder: border(Colors.red.shade400),
      focusedErrorBorder: border(Colors.red.shade600),
    );
  }

  Widget _termsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: _acceptedTerms ? _green : Colors.white,
              border: Border.all(
                color: _acceptedTerms ? _green : _border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: _acceptedTerms
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text.rich(
            TextSpan(
              text: 'By creating an account you agree to our ',
              style: TextStyle(fontSize: 12.5, color: _muted, height: 1.5),
              children: [
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(color: _dark, fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(color: _dark, fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _createAccountButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final loading = state is AuthLoading;
        return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _green.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 19),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _signInFooter() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: RichText(
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(fontSize: 13.5, color: _muted),
            children: [
              TextSpan(
                text: 'Sign In',
                style: TextStyle(color: _green, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
