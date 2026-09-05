import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Task Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/detail': (context) => const TaskDetailScreen(),
        '/mark-status': (context) => const MarkStatusScreen(),
      },
    );
  }
}

class Task {
  final String name;
  final String status;

  const Task({
    required this.name,
    this.status = 'Pending',
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [
    const Task(name: 'Buy groceries'),
    const Task(name: 'Submit report'),
    const Task(name: 'Call client', status: 'Complete'),
  ];

  // Go to Add Task screen using an unnamed route
  Future<void> _goToAddTask() async {
    final selectedTaskName = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(
          presetTasks: [
            'Buy groceries',
            'Submit report',
            'Call client',
            'Review PR',
          ],
        ),
      ),
    );

    if (selectedTaskName != null) {
      setState(() {
        _tasks.add(Task(name: selectedTaskName));
      });
    }
  }

  // Go to Task Detail screen using a named route
  Future<void> _openTaskDetail(int index) async {
    final updatedTask = await Navigator.pushNamed(
      context,
      '/detail',
      arguments: _tasks[index],
    ) as Task?;

    if (updatedTask != null) {
      setState(() {
        _tasks[index] = updatedTask;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Task Tracker'),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final isComplete = task.status == 'Complete';

          return ListTile(
            title: Text(task.name),
            subtitle: Text(task.status),
            trailing: isComplete
                ? const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                : const Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.grey,
                  ),
            onTap: () => _openTaskDetail(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ADD TASK SCREEN
// Uses an unnamed route

class AddTaskScreen extends StatelessWidget {
  final List<String> presetTasks;

  const AddTaskScreen({
    super.key,
    required this.presetTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: presetTasks.length,
        itemBuilder: (context, index) {
          final taskName = presetTasks[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.deepPurple.shade50,
                foregroundColor: Colors.deepPurple,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context, taskName);
              },
              child: Text(taskName),
            ),
          );
        },
      ),
    );
  }
}

// TASK DETAIL SCREEN
// Uses a named route

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _task = ModalRoute.of(context)!.settings.arguments as Task;
      _initialized = true;
    }
  }

  // Go to Mark Status screen
  Future<void> _goToMarkStatus() async {
    final newStatus = await Navigator.pushNamed(
      context,
      '/mark-status',
      arguments: _task,
    ) as String?;

    if (newStatus != null && newStatus != _task.status) {
      final updatedTask = Task(
        name: _task.name,
        status: newStatus,
      );

      // Return the updated task to Home
      if (mounted) {
        Navigator.pop(context, updatedTask);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _task.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${_task.status}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade50,
                foregroundColor: Colors.deepPurple,
                elevation: 0,
              ),
              onPressed: _goToMarkStatus,
              child: const Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK STATUS SCREEN
// Uses a named route

class MarkStatusScreen extends StatelessWidget {
  const MarkStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)!.settings.arguments as Task;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 44),
                backgroundColor: Colors.deepPurple.shade50,
                foregroundColor: Colors.deepPurple,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context, 'Complete');
              },
              child: const Text('Mark Complete'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 44),
                backgroundColor: Colors.deepPurple.shade50,
                foregroundColor: Colors.deepPurple,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context, 'Pending');
              },
              child: const Text('Mark Pending'),
            ),
          ],
        ),
      ),
    );
  }
}
