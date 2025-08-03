import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/controllers/todo_list_controller.dart';
import 'package:task_manager/layouts/log_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  late final AnimationController controller;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool signingUp = false;
  bool success = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      _show('All fields are required', Colors.red);
      return;
    }

    if (password != confirm) {
      _show('Passwords do not match', Colors.deepOrange);
      return;
    }

    setState(() => signingUp = true);

    final db = context.read<TodoListDatabase>();
    final result = await db.signUpUser(
      username: username,
      email: email,
      password: password,
    );

    setState(() => signingUp = false);

    if (result == null) {
      _show('Registration successful', Colors.green);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => success = true);
      await controller.forward(from: 0);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    } else {
      _show(result, Colors.deepOrange);
    }
  }

  void _show(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bg,
        duration: const Duration(seconds: 3),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            heightFactor: 3.5,
            child: Lottie.asset(
              'assets/lotties/list.json',
              controller: controller,
              height: 125,
              width: 125,
              onLoaded: (composition) {
                controller.duration = composition.duration;
                controller.forward();
              },
            ),
          ),
          if (!success)
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Color(0xFF373435),
                            fontSize: 20,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 24),
            
                        // Username
                        _styledInput(
                          controller: _usernameController,
                          hintText: 'Username',
                        ),
                        const SizedBox(height: 13),
            
                        // Email
                        _styledInput(
                          controller: _emailController,
                          hintText: 'Email',
                        ),
                        const SizedBox(height: 13),
            
                        // Password
                        _styledInput(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: _obscurePassword,
                          onSuffixTap: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        const SizedBox(height: 13),
            
                        // Confirm Password
                        _styledInput(
                          controller: _confirmController,
                          hintText: 'Confirm Password',
                          obscureText: _obscureConfirm,
                          onSuffixTap: () {
                            setState(
                                () => _obscureConfirm = !_obscureConfirm);
                          },
                        ),
                        const SizedBox(height: 13),
            
                        // Sign Up button
                        GestureDetector(
                          onTap: !signingUp ? _handleSignUp : null,
                          child: Container(
                            width: double.infinity,
                            height: 45,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: signingUp
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF373435),
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Color(0xFF373435),
                                        fontSize: 16,
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
            
                        // Already have account
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const Login()),
                          ),
                          child: const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(
                                    color: Color(0xFF707A8A),
                                    fontSize: 12,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text: 'SIGN IN',
                                  style: TextStyle(
                                    color: Color(0xFF373435),
                                    fontSize: 12,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _styledInput({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 2),
      decoration: ShapeDecoration(
        color: const Color(0xFFF9F9F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Color(0xFF373435),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF707A8A),
            fontSize: 10,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w900,
          ),
          border: InputBorder.none,
          suffixIcon: onSuffixTap != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF707A8A),
                    size: 20,
                  ),
                  onPressed: onSuffixTap,
                )
              : null,
        ),
      ),
    );
  }
}
