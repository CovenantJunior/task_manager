import 'package:flutter/material.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
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
      // final response = await callOpenAI(prompt);
      setState(() {
        // tasks = parseTasks(response);
      });
    } catch (e) {
      setState(() => error = 'Failed to fetch tasks.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<String> parseTasks(String rawResponse) {
    // Dummy parser; replace with actual OpenAI output parser
    return rawResponse
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Task Assistant',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'e.g. Plan my week with 3 work tasks and 2 wellness tasks',
                hintStyle: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: isLoading ? null : _generateTasks,
              child: Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
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
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(tasks[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          // Add to your local project/task list
                        },
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
