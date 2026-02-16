import 'package:flutter/material.dart';

import 'database/database_helper.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BlocksScreen(),
    );
  }
}

class BlocksScreen extends StatefulWidget {
  const BlocksScreen({super.key});

  @override
  State<BlocksScreen> createState() => _BlocksScreenState();
}

class _BlocksScreenState extends State<BlocksScreen> {
  final db = DatabaseHelper.instance;

  Future<void> _showBlockDialog({Map<String, dynamic>? block}) async {
    final controller = TextEditingController(text: block?['name'] ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(block == null ? 'Add Block' : 'Edit Block'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Block name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              if (block == null) {
                await db.insertBlock(name);
              } else {
                await db.updateBlock(block['id'] as int, name);
              }

              if (context.mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBlock(int id) async {
    await db.deleteBlock(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocks')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.getBlocks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final blocks = snapshot.data ?? [];
          if (blocks.isEmpty) {
            return const Center(child: Text('No blocks yet. Tap + to add one.'));
          }

          return ListView.separated(
            itemCount: blocks.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final block = blocks[index];
              return ListTile(
                title: Text(block['name'] as String),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TasksScreen(
                      blockId: block['id'] as int,
                      blockName: block['name'] as String,
                    ),
                  ),
                ).then((_) => setState(() {})),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showBlockDialog(block: block),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteBlock(block['id'] as int),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBlockDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TasksScreen extends StatefulWidget {
  final int blockId;
  final String blockName;

  const TasksScreen({super.key, required this.blockId, required this.blockName});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final db = DatabaseHelper.instance;

  Future<void> _showTaskDialog({Map<String, dynamic>? task}) async {
    final controller = TextEditingController(text: task?['title'] ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task == null ? 'Add Task' : 'Edit Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Task title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isEmpty) return;

              if (task == null) {
                await db.insertTask(widget.blockId, title);
              } else {
                await db.updateTask(task['id'] as int, title);
              }

              if (context.mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(int id) async {
    await db.deleteTask(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.blockName)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.getTasksByBlock(widget.blockId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks yet. Tap + to add one.'));
          }

          return ListView.separated(
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isCompleted = (task['is_completed'] as int) == 1;
              final title = task['title'] as String;

              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailsScreen(taskId: task['id'] as int, taskTitle: title),
                  ),
                ).then((_) => setState(() {})),
                leading: Checkbox(
                  value: isCompleted,
                  onChanged: (checked) async {
                    await db.toggleTaskCompleted(task['id'] as int, checked ?? false);
                    setState(() {});
                  },
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    color: isCompleted ? Colors.grey : null,
                  ),
                ),
                subtitle: const Text('Tap to open comments'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showTaskDialog(task: task),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteTask(task['id'] as int),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskDetailsScreen extends StatefulWidget {
  final int taskId;
  final String taskTitle;

  const TaskDetailsScreen({super.key, required this.taskId, required this.taskTitle});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final db = DatabaseHelper.instance;

  Future<void> _showCommentDialog({Map<String, dynamic>? comment}) async {
    final controller = TextEditingController(text: comment?['text'] ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(comment == null ? 'Add Comment' : 'Edit Comment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Comment'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              if (comment == null) {
                await db.insertComment(widget.taskId, text);
              } else {
                await db.updateComment(comment['id'] as int, text);
              }

              if (context.mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(int id) async {
    await db.deleteComment(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.taskTitle)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.getCommentsByTask(widget.taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final comments = snapshot.data ?? [];
          if (comments.isEmpty) {
            return const Center(child: Text('No comments yet. Tap + to add one.'));
          }

          return ListView.separated(
            itemCount: comments.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final comment = comments[index];
              return ListTile(
                title: Text(comment['text'] as String),
                subtitle: Text('Created: ${comment['created_at']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showCommentDialog(comment: comment),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteComment(comment['id'] as int),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCommentDialog(),
        child: const Icon(Icons.add_comment_outlined),
      ),
    );
  }
}
