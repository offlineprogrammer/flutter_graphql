import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/ModelProvider.dart';

class ToDoItemPage extends StatefulWidget {
  const ToDoItemPage({
    required this.todoItem,
    super.key,
  });

  final Todo? todoItem;

  @override
  State<ToDoItemPage> createState() => _ToDoItemPageState();
}

class _ToDoItemPageState extends State<ToDoItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late final String _nameText;
  late bool _isDone;

  bool get _isCreate => _todoItem == null;
  Todo? get _todoItem => widget.todoItem;

  @override
  void initState() {
    super.initState();

    final todoItem = _todoItem;
    if (todoItem != null) {
      _nameController.text = todoItem.name;
      _descriptionController.text = todoItem.description ?? '';

      _nameText = 'Update todo Item';
      _isDone = todoItem.complete ?? false;
    } else {
      _nameText = 'Create todo Item';
      _isDone = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // If the form is valid, submit the data
    final name = _nameController.text;
    final description = _descriptionController.text;
    final complete = _isDone;

    if (_isCreate) {
      // Create a new todo item
      final newEntry = Todo(
        name: name,
        description: description.isNotEmpty ? description : null,
        complete: complete,
      );
      final request = ModelMutations.create(newEntry);
      final response = await Amplify.API.mutate(request: request).response;
      safePrint('Create result: $response');
    } else {
      // Update todoItem instead
      final updateToDoItem = _todoItem!.copyWith(
        name: name,
        description: description.isNotEmpty ? description : null,
        complete: complete,
      );
      final request = ModelMutations.update(updateToDoItem);
      final response = await Amplify.API.mutate(request: request).response;
      safePrint('Update result: $response');
    }

    // Navigate back to homepage after create/update executes
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_nameText),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name (required)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Done'),
                      value: _isDone,
                      onChanged: (bool value) {
                        setState(() {
                          _isDone = value;
                        });
                      },
                      secondary: const Icon(Icons.done_all_outlined),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: submitForm,
                      child: Text(_nameText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
