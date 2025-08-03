import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/components/todo_list_drawer_tile.dart';
import 'package:task_manager/controllers/todo_list_controller.dart';
import 'package:task_manager/layouts/ai_assistant.dart';
import 'package:task_manager/layouts/todo_list_preferences.dart';
import 'package:task_manager/layouts/todo_list_starred.dart';
import 'package:task_manager/layouts/todo_trash_page.dart';

class TodoListDrawer extends StatefulWidget {
  const TodoListDrawer({super.key});

  @override
  State<TodoListDrawer> createState() => _TodoListDrawerState();
}

class _TodoListDrawerState extends State<TodoListDrawer> {
  @override
  Widget build(BuildContext context) {
    
    context.read<TodoListDatabase>().fetchUser();
    List user = context.read<TodoListDatabase>().user;
    
    return Drawer(
      semanticLabel: "TodoList Drawer Menu",
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              child: Image.asset(
                'assets/images/note.png',
                width: 70,
                height: 70,
              )
            ),

            TodoListDrawerTile(
              title: "Home",
              leading: const Icon(Icons.home_outlined),
              onTap: () {
                Navigator.pop(context);
              }
            ),

            TodoListDrawerTile(
              title: "AI Assitant",
              leading: const Icon(Icons.assistant_outlined),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AIAssistantPage()));
              }
            ),

            TodoListDrawerTile(
              title: "Starred",
              leading: const Icon(Icons.star_border_rounded),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TodoStarred()));
              }
            ),
        
            TodoListDrawerTile(
              title: "Preferences",
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TodoListPreferences()));
              }
            ),
        

            TodoListDrawerTile(
              title: "Trash",
              leading: const Icon(Icons.delete_outline_rounded),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TodoTrash()));
              }
            ),
            const Divider(),
            
            (user.first.expires!.isAfter(DateTime.now())) ?
            TodoListDrawerTile(
              title: "Sign Out",
              leading: const Icon(Icons.logout_rounded),
              onTap: () async {
                context.read<TodoListDatabase>().clearUser();
              }
            ) : const SizedBox()
          ],
        ),
      ),
    );
  }
}