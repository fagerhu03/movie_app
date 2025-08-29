import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onLogin,
    this.onGoogle,
    this.onForgot,
    this.onCreateAccount,
    this.onChangeLocale,
  });
  static const routeName ="LoginScreen";

  final VoidCallback? onLogin;
  final VoidCallback? onGoogle;
  final VoidCallback? onForgot;
  final VoidCallback? onCreateAccount;
  final void Function(Locale locale)? onChangeLocale;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white70,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: const Color(0xFF2B2B2B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2), // blue focus like screenshot
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo (replace with your asset)
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(42),
                    border: Border.all(color: yellow, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.play_circle_fill, color: yellow, size: 48),
                ),
                const SizedBox(height: 24),

                // Email
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  decoration: _fieldDecoration(
                    hint: 'Email',
                    icon: Icons.email_rounded,
                  ),
                ),
                const SizedBox(height: 12),

                // Password + Forgot
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: _fieldDecoration(
                          hint: 'Password',
                          icon: Icons.lock_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: widget.onForgot,
                      child: const Text(
                        'Forget Password ?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: widget.onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 12),

                // Create account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't Have Account ? ",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onCreateAccount,
                      child: const Text(
                        'Create One',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // OR divider
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 12),

                // Google button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: widget.onGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.black),
                    label: const Text(
                      'Login With Google',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Language chips (replace with your flag assets if you have them)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LangChip(
                      tooltip: 'English',
                      image: const AssetImage('assets/images/flag_us.png'),
                      onTap: () => widget.onChangeLocale?.call(const Locale('en')),
                    ),
                    const SizedBox(width: 16),
                    _LangChip(
                      tooltip: 'Arabic',
                      image: const AssetImage('assets/images/flag_eg.png'),
                      onTap: () => widget.onChangeLocale?.call(const Locale('ar')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.image, this.onTap, this.tooltip, Key? key}) : super(key: key);
  final ImageProvider image;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Tooltip(
        message: tooltip ?? '',
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white24,
          child: CircleAvatar(
            radius: 16,
            backgroundImage: image,
          ),
        ),
      ),
    );
  }
}
