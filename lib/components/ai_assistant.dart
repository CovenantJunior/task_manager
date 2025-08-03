import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:task_manager/controllers/todo_list_controller.dart';
import 'package:task_manager/services/audio_service.dart';
import 'package:task_manager/services/notification_service.dart';
import 'package:vibration/vibration.dart';

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

  TextEditingController textController = TextEditingController();
  String hint = 'Task description';
  TextEditingController dateController = TextEditingController();
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String selectedCategory = 'Personal';
  String interval = 'Every Minute';
  List searchResults = [];
  List nonTrashedTodolists = [];
  List nonTrashedTodolistsState = [];
  List preference = [];
  List cardToRemove = [];
  bool _isListening = false;
  bool backingUp = false;
  late SpeechToText _speech;

  int plansCount = 0;
  Future<bool?> hasVibrate = Vibration.hasVibrator();
  bool requestedClipboard = false;
  bool animate = false;

  Future<void> _generateTasks() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
      error = null;
      tasks = [];
    });

    try {
      final response = await Gemini.instance.text(
        'Generate a simple, numbered to-do task list based on this request: "$prompt"',
        modelName: 'models/gemini-1.5-flash',
      );

      final output = response?.output;
      if (output == null || output.trim().isEmpty) {
        error = 'No response received from Gemini.';
      } else {
        final parsed = parseTasks(output);
        if (parsed.isEmpty) {
          error = 'No tasks found in the AI response.';
        } else {
          tasks = parsed;
        }
      }
    } catch (e) {
      error = 'Failed to generate tasks: $e';
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

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          // print('Speech recognition status: $status');
          if (status == 'listening') {
            setState(() {
              _isListening = true;
              hint = 'Listening';
            });
          } else {
            setState(() {
              _isListening = false;
              hint = 'Task description';
            });
          }
        },
        onError: (errorNotification) {
          // print('Speech recognition error: $errorNotification');
          setState(() {
            _isListening = false;
            _speech.stop();
            hint = 'Task description';
          });
        },
      );
      if (available) {
        setState(() {
          _isListening = true;
          hint = 'Listening';
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              hint = 'Task description';
              textController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
        hint = 'Task description';
        textController.text = '';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: selectedDate,
      lastDate: DateTime(3000),
    );
    dateController.text = DateFormat('yyyy-MM-dd').format(picked!);
    if (mounted && picked != selectedDate) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void createTodoList(String data, BuildContext context) {
    if (data != '') {
      textController.text = data;
    }
    dateController.text == '' ? dateController.text = date : dateController.text= dateController.text;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Add a plan",
          style: TextStyle(
            fontFamily: "Quicksand",
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.list_rounded),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        autocorrect: true,
                        autofocus: true,
                        minLines: 1,
                        maxLines: 20,
                        controller: textController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: hint,
                          suffixIcon: context.watch<TodoListDatabase>().preferences.first.stt == true
                              ? (IconButton(
                                  onPressed: _listen,
                                  icon: Icon(_isListening == true
                                      ? Icons.mic_off
                                      : Icons.mic)))
                              : const SizedBox(),
                          hintStyle: const TextStyle(
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.bold),
                          labelStyle: const TextStyle(
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.category),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(
                                fontFamily: "Quicksand",
                                fontWeight: FontWeight.bold),
                            border: InputBorder.none),
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                          },
                          items: [
                            'Personal',
                            'Work',
                            'Study',
                            'Shopping',
                            'Sport',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    fontFamily: "Quicksand",
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                          isExpanded: true,
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _selectDate(context);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                              labelText: 'Tap here to choose due date',
                              labelStyle: TextStyle(
                                  fontFamily: "Quicksand",
                                  fontWeight: FontWeight.bold),
                              hintText: 'Select due date',
                              border: InputBorder.none),
                          child: TextFormField(
                            onTap: () {
                              _selectDate(context);
                            },
                            controller: dateController,
                            style: const TextStyle(
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.bold
                            ),
                            readOnly: true, // Make the TextFormField read-only
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Reminder Interval',
                            labelStyle: TextStyle(
                                fontFamily: "Quicksand",
                                fontWeight: FontWeight.bold),
                            border: InputBorder.none),
                        child: DropdownButtonFormField<String>(
                          value: interval,
                          onChanged: (value) {
                            interval = value!;
                          },
                          items: [
                            'Every Minute',
                            'Hourly',
                            'Daily',
                            'Weekly'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    fontFamily: "Quicksand",
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                          isExpanded: true,
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
              setState(() {
                selectedDate = DateTime.now().add(const Duration(days: 1));
                requestedClipboard = true;
              });
            },
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            onPressed: () async {
              setState(() {
                animate = true;
              });
              Future.delayed(const Duration(milliseconds: 300), () {
                setState(() {
                  animate = false;
                });
              });
              String text = textController.text.trim();
              String due = dateController.text;
              String category = selectedCategory;
              String intvl = interval;
              if (text.isNotEmpty) {
                AudioService().play('pings/start.mp3');
                context.read<TodoListDatabase>().addTodoList(text, category, due, intvl);
                setState(() {
                  selectedDate = DateTime.now().add(const Duration(days: 1));
                });
                Navigator.pop(context);
                textController.clear();
                if (context.read<TodoListDatabase>().preferences.first.notification == true) {
                  int notifID = context.read<TodoListDatabase>().todolists.isNotEmpty ? context.read<TodoListDatabase>().todolists.last.id + 1 : 1;
                  NotificationService().scheduleNotification(
                    id: notifID,
                    title: "Reminder",
                    body: "TODO: $text",
                    interval: intvl,
                    payload: jsonEncode({
                      'scheduledDate': DateTime.now().toIso8601String(),
                      'interval': intvl,
                    }),
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                    content: const Text(
                      'Plan saved',
                      style: TextStyle(
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else {
                if (context.read<TodoListDatabase>().preferences.first.vibration) Vibration.vibrate(duration: 50);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
                    duration: const Duration(seconds: 2),
                    content: const Text(
                      'Oops, blank shot!',
                      style: TextStyle(
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ));
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        icon: tasks[index].length < 100 ? const Icon(Icons.add) : const SizedBox(),
                        onPressed: () async {
                          // Navigator.pop(context);
                          createTodoList(tasks[index], context);
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
