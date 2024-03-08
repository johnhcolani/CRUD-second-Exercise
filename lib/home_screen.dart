import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  final Future<Database> database;
  const HomeScreen({Key? key, required this.database}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  List<Map<String, dynamic>> _task = [];

  @override
  void initState() {
    super.initState();
    refreshTaskList();
  }

  Future<void> insertTask(String title, String desc) async {
    final Database db = await widget.database;
    await db.insert('tasks', {
      'title': title,
      'desc': desc,
    });
    refreshTaskList();
    _titleController.clear(); // Clear title text field
    _descController.clear(); // Clear description text field
  }

  Future<void> updateTask(int id, String title, String desc) async {
    final Database db = await widget.database;
    await db.update(
      'tasks',
      {
        'title': title,
        'desc': desc,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    refreshTaskList();
  }

  Future<void> deleteTask(int id) async {
    final Database db = await widget.database;
    await db.delete(
      'tasks',
      where: 'id=?',
      whereArgs: [id],
    );
    refreshTaskList();
  }

  Future<void> refreshTaskList() async {
    final Database db = await widget.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    setState(() {
      _task = maps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD App'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Product Title',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _descController,
              decoration: const InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await insertTask(_titleController.text, _descController.text);
            },
            child: const Text("Add Task"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _task.length,
              itemBuilder: (context, index) {
                final task = _task[index];
                TextEditingController _editTitleController =
                    TextEditingController(text: task['title']);
                TextEditingController _editDescController =
                    TextEditingController(text: task['desc']);
                return Card(
                  child: ListTile(
                    title: Text(task['title']),
                    subtitle: Text(task['desc']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Edit Task'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: _editTitleController,
                                      decoration: const InputDecoration(
                                        hintText: 'Task Title',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    TextField(
                                      controller: _editDescController,
                                      decoration: const InputDecoration(
                                        hintText: 'Task Description',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      await updateTask(
                                          task['id'],
                                          _editTitleController.text,
                                          _editDescController.text);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Update'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        TextButton(
                          onPressed: () async {
                            await deleteTask(task['id']);
                          },
                          child: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
