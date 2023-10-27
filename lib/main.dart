import 'package:flutter/material.dart';
import 'package:todolist/todo.dart';

import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo-List App',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: TodoApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoApp extends StatefulWidget {
  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final dbHelper = DatabaseHelper();
  List<Todo> _todos = [];
  int _count = 0;

  void refreshItemList() async {
    final todos = await dbHelper.getAllTodos();
    setState(() {
      _todos = todos;
    });
  }

  void searchItems() async {
    final keyword = _searchController.text.trim();
    print(keyword);
    if (keyword.isNotEmpty) {
      final todos = await dbHelper.getTodoByTitle(keyword);
      setState(() {
        _todos = todos;
      });
    } else {
      refreshItemList();
    }
  }

  void addItem(String title, String desc) async {
    final todo =
        Todo(id: _count, title: title, description: desc, completed: false);
    await dbHelper.insertTodo(todo);
    refreshItemList();
  }

  void updateItem(Todo todo, bool completed) async {
    final item = Todo(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      completed: completed,
    );
    await dbHelper.updateTodo(item);
    refreshItemList();
  }

  void deleteItem(int id) async {
    await dbHelper.deleteTodo(id);
    refreshItemList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshItemList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Todo List App'),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              ),
              onChanged: (_) {
                searchItems();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                var todo = _todos[index];
                return ListTile(
                  leading: todo.completed
                      ? IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            updateItem(todo, !todo.completed);
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.radio_button_unchecked),
                          onPressed: () {
                            updateItem(todo, !todo.completed);
                          },
                        ),
                  title: Text(
                    todo.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(todo.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.amber.shade400,
                    onPressed: () {
                      deleteItem(todo.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Tambah Todo'),
              content: SizedBox(
                width: 200,
                height: 200,
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: 'Judul todo'),
                    ),
                    TextField(
                      controller: _descController,
                      decoration:
                          const InputDecoration(hintText: 'Deskripsi todo'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Batalkan'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Tambah'),
                  onPressed: () {
                    addItem(_titleController.text, _descController.text);

                    Navigator.pop(context);
                    setState(() {
                      _count = _count + 1;
                    });
                  },
                ),
              ],
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
