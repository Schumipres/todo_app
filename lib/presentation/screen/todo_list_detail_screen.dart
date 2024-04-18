import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_list_bloc.dart';
import 'dart:async';

import 'package:todo_app/models/todo_list_model.dart';

class TodoListDetailScreen extends StatefulWidget {
  const TodoListDetailScreen({super.key});

  @override
  State<TodoListDetailScreen> createState() => _TodoListDetailScreenState();
}

class _TodoListDetailScreenState extends State<TodoListDetailScreen> {
  // Timer
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Reset timer function
  void resetTimer(String value, int index, String title,
      {bool noteIsClosed = false}) {
    // Cancel the previous timer, if any
    timer?.cancel();
    // Start a new timer

    //if value and index are not null, then start the timer
    if (noteIsClosed == true) {
      context.read<TodoListBloc>().add(
            UpdatedNote(
              title: title,
              index: index,
              description: value,
              noteIsClosed: noteIsClosed,
            ),
          );
    } else if (noteIsClosed == false) {
      timer = Timer(const Duration(seconds: 1), () {
        print('Auto-saving... $value, $index');
        // Auto-save after 2 seconds of inactivity
        context.read<TodoListBloc>().add(
              UpdatedNote(
                title: title,
                index: index,
                description: value,
              ),
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (context, state) {
        if (state is TodoListLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is NavigateToDetailedScreen) {
          return Scaffold(
            appBar: AppBar(
              title: GestureDetector(
                onTap: () {
                  // Handle the tap event to make the title editable
                  // You can use a dialog or navigate to a new screen for editing
                  // For simplicity, let's show a dialog
                  showDialog(
                    context: context,
                    builder: (context) {
                      String editedTitle = state.todo.title;
                      return AlertDialog(
                        title: Text(
                          'Edit Title',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ),
                        content: TextFormField(
                          initialValue: state.todo.title,
                          onChanged: (value) {
                            editedTitle = value;
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context.read<TodoListBloc>().add(
                                    UpdatedNote(
                                      index: state.todo.id!,
                                      title: editedTitle,
                                    ),
                                  );
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  state.todo.title,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
              ),
              //handle the back button
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  resetTimer(state.todo.description!, state.todo.id!,
                      state.todo.title, noteIsClosed: true);
                  Navigator.pop(context);
                },
              ),
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: TextEditingController(text: state.todo.description),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: null,
                style: const TextStyle(
                  fontSize: 19,
                  height: 1.5,
                ),
                onChanged: (value) {
                  // Reset the timer when the text changes
                  resetTimer(value, state.todo.id!, state.todo.title);
                },
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
