import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/controllers/todo_list_controller.dart';
import 'package:task_manager/layouts/log_in.dart';
import 'package:task_manager/layouts/todo_list_page.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {

    final db = context.read<TodoListDatabase>();
    db.fetchUser();
    late final AnimationController controller = AnimationController(
      vsync: this,
    );


    void launch() {
      Future.delayed(const Duration(milliseconds: 1200), () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                final user = db.user.isNotEmpty ? db.user.first : null;
                final isExpired = user == null ||
                    user.expires == null ||
                    user.expires!.isAfter(DateTime.now());
                return isExpired ? const Login() : const TodoListPage();
              },
            )
          );
        });
      }
      
    void load() {
      controller.forward().whenComplete(() {
        launch();
      });
    }
    
    return Scaffold(
      body: Stack(
        children: [
           const Center(
          ),
          Center(
            child: Lottie.asset(
              height: 125,
              width: 125,
              'assets/lotties/list.json',
              controller: controller,
              filterQuality: FilterQuality.high,
              onLoaded: (e) {
                controller.duration = e.duration;
                load();
              }
            ),
          ),
        ]
      ),
    );
  }
}