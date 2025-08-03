import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/controllers/todo_list_controller.dart';

class AIAssistant extends StatefulWidget {
  const AIAssistant({super.key});

  @override
  State<AIAssistant> createState() => _AIAssistantState();
}

class _AIAssistantState extends State<AIAssistant> {
  final TextEditingController _promptController = TextEditingController();
  bool isLoading = false;
  String? error;
  List<String> tasks = [];

  Future<void> _generateTasks() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
      error = null;
      tasks = [];
    });

    try {
      final response = await Gemini.instance.text('Generate a simple, numbered to-do task list based on this request: "$prompt"');

      final content = response?.output ?? '';
      final parsed = parseTasks(content);

      if (parsed.isEmpty) {
        error = 'No tasks found in the AI response.';
      } else {
        tasks = parsed;
      }
    } catch (e) {
      error = 'Failed to generate tasks.';
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<String> parseTasks(String raw) {
    return raw
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
        .toList();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Task Assistant',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'e.g. Plan 3 work tasks and 2 wellness tasks',
                hintStyle: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: isLoading ? null : _generateTasks,
              child: Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 1),
                        )
                      : const Text(
                          'Generate Tasks',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (tasks.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      title: Text(tasks[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          context.read<TodoListDatabase>().addTodoList(
                            tasks[index], 'AI', DateTime.now().add(const Duration(days: 1)).toString(), null,
                          );
                        }
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
