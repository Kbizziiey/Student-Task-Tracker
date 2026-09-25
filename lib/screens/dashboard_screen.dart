import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/task_model.dart';
import '../widgets/task_tile.dart';
import 'add_edit_task_screen.dart';
import 'profile_screen.dart';

enum TaskFilter { all, pending, completed }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  TaskFilter _filter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _firestoreService.streamTasks(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allTasks = snapshot.data ?? [];
          final pendingCount = allTasks.where((t) => !t.completed).length;
          final completedCount = allTasks.where((t) => t.completed).length;

          final visibleTasks = switch (_filter) {
            TaskFilter.all => allTasks,
            TaskFilter.pending =>
              allTasks.where((t) => !t.completed).toList(),
            TaskFilter.completed =>
              allTasks.where((t) => t.completed).toList(),
          };

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _SummaryCard(
                      label: 'Pending',
                      count: pendingCount,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _SummaryCard(
                      label: 'Completed',
                      count: completedCount,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<TaskFilter>(
                  segments: const [
                    ButtonSegment(value: TaskFilter.all, label: Text('All')),
                    ButtonSegment(
                        value: TaskFilter.pending, label: Text('Pending')),
                    ButtonSegment(
                        value: TaskFilter.completed,
                        label: Text('Completed')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (selection) {
                    setState(() => _filter = selection.first);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: visibleTasks.isEmpty
                    ? const Center(child: Text('No tasks here yet.'))
                    : ListView.builder(
                        itemCount: visibleTasks.length,
                        itemBuilder: (context, index) {
                          final task = visibleTasks[index];
                          return TaskTile(
                            task: task,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditTaskScreen(task: task),
                                ),
                              );
                            },
                            onToggleCompleted: (value) {
                              _firestoreService.setCompleted(
                                  task.id, value ?? false);
                            },
                            onDelete: () {
                              _firestoreService.deleteTask(task.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
