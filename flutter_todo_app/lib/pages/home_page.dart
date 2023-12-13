import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/ModelProvider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _todoItems = <Todo>[];

  @override
  void initState() {
    super.initState();
    _refreshTodoItems();
  }

  Future<void> _refreshTodoItems() async {
    try {
      final request = ModelQueries.list(Todo.classType);
      final response = await Amplify.API.query(request: request).response;

      final todos = response.data?.items;
      if (response.hasErrors) {
        safePrint('errors: ${response.errors}');
        return;
      }
      setState(() {
        _todoItems = todos!.whereType<Todo>().toList();
      });
    } on ApiException catch (e) {
      safePrint('Query failed: $e');
    }
  }

  Future<void> _deleteToDoItem(Todo todoItem) async {
    final request = ModelMutations.delete<Todo>(todoItem);
    final response = await Amplify.API.mutate(request: request).response;
    safePrint('Delete response: $response');
    await _refreshTodoItems();
  }

  Future<void> _openToDoItem({Todo? todoItem}) async {
    await context.pushNamed('manage', extra: todoItem);
    // Refresh the entries when returning from the
    // todo item screen.
    await _refreshTodoItems();
  }

  Widget _buildRow({
    required String name,
    required String description,
    required bool isDone,
    TextStyle? style,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
        Expanded(
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
        Expanded(
          child: isDone ? const Icon(Icons.done) : const SizedBox(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // Navigate to the page to create new todo item
        onPressed: _openToDoItem,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('ToDo List'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: RefreshIndicator(
            onRefresh: _refreshTodoItems,
            child: Column(
              children: [
                if (_todoItems.isEmpty)
                  const Text('Use the \u002b sign to add new todo items')
                else
                  const SizedBox(height: 30),
                _buildRow(
                  name: 'Name',
                  description: 'Description',
                  isDone: false,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _todoItems.length,
                    itemBuilder: (context, index) {
                      final todoItem = _todoItems[index];
                      return Dismissible(
                        key: ValueKey(todoItem),
                        background: const ColoredBox(
                          color: Colors.red,
                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                        ),
                        onDismissed: (_) => _deleteToDoItem(todoItem),
                        child: ListTile(
                          onTap: () => _openToDoItem(
                            todoItem: todoItem,
                          ),
                          title: _buildRow(
                            name: todoItem.name,
                            description: todoItem.description ?? '',
                            isDone: todoItem.complete ?? false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
