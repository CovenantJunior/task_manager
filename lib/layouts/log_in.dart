import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/controllers/todo_list_controller.dart';
import 'package:task_manager/layouts/sign_up.dart';
import 'package:task_manager/layouts/todo_list_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController controller;

  bool _obscurePassword = true;
  bool authorizing = false;
  bool success = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in both email and password.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => authorizing = true);

    final db = context.read<TodoListDatabase>();
    final result = await db.loginUser(email: email, password: password);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login successful!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );


      await Future.delayed(const Duration(seconds: 2));
      setState(() => success = true);
      controller.forward(from: 0).whenComplete(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TodoListPage(),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.deepOrange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    setState(() => authorizing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Lottie.asset(
                  'assets/lotties/list.json',
                  controller: controller,
                  height: 125,
                  width: 125,
                  filterQuality: FilterQuality.high,
                  onLoaded: (composition) {
                    controller.duration = composition.duration;
                    controller.forward();
                  },
                ),
              ),
            ),
            !success ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                    'Account Login',
                    style: TextStyle(
                      color: Color(0xFF373435),
                      fontSize: 20,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 19, vertical: 2),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF9F9F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(
                        color: Color(0xFF373435),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: Color(0xFF707A8A),
                          fontSize: 10,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w900,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 19, vertical: 2),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF9F9F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: TextField(
                      onSubmitted: (_) => _handleSignIn(),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        color: Color(0xFF373435),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                          color: Color(0xFF707A8A),
                          fontSize: 10,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w900,
                        ),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF707A8A),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  GestureDetector(
                    onTap: !authorizing ? _handleSignIn : null,
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: authorizing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF373435),
                                  strokeWidth: 1,
                                ),
                              )
                            : const Text(
                                'Sign In',
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
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    ),
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'New User? ',
                            style: TextStyle(
                              color: Color(0xFF707A8A),
                              fontSize: 12,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: 'CREATE ACCOUNT',
                            style: TextStyle(
                              color: Color(0xFF707A8A),
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
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
