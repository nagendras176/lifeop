import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../domain/entities/task.dart';

class TaskDefinitionScreen extends StatefulWidget {
  final Task? taskToEdit;
  final Function(Task) onTaskSaved;

  const TaskDefinitionScreen({
    super.key,
    this.taskToEdit,
    required this.onTaskSaved,
  });

  @override
  State<TaskDefinitionScreen> createState() => _TaskDefinitionScreenState();
}

class _TaskDefinitionScreenState extends State<TaskDefinitionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  
  Priority _selectedPriority = Priority.medium;
  TaskType _selectedTaskType = TaskType.simple;
  DateTime? _selectedDeadline;
  TimeOfDay? _selectedTime;
  Color _selectedColor = Colors.blue;
  bool _hasReminder = false;
  DateTime? _reminderTime;
  
  // Objectives management
  final List<Objective> _objectives = [];
  
  // Subtasks management
  final List<Task> _subtasks = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _loadTaskData();
    }
  }

  void _loadTaskData() {
    final task = widget.taskToEdit!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _notesController.text = task.notes ?? '';
    _selectedPriority = task.priority;
    _selectedTaskType = task.taskType;
    _selectedDeadline = task.deadline;
    _selectedTime = task.deadline != null 
        ? TimeOfDay.fromDateTime(task.deadline!)
        : null;
    _selectedColor = task.color;
    _hasReminder = task.reminderTime != null;
    _reminderTime = task.reminderTime;
    
    // Load objectives and subtasks
    _objectives.clear();
    _objectives.addAll(task.objectives);
    // Note: Subtasks would be loaded from a separate call in a real app
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Objective management methods
  void _addObjective() {
    setState(() {
      _objectives.add(Objective(
        id: _generateId(),
        name: '',
        weight: 0,
      ));
    });
  }

  void _removeObjective(int index) {
    setState(() {
      _objectives.removeAt(index);
    });
  }

  void _updateObjective(int index, Objective objective) {
    setState(() {
      _objectives[index] = objective;
    });
  }

  void _autoBalanceWeights() {
    if (_objectives.isEmpty) return;
    
    final weightPerObjective = 100 ~/ _objectives.length;
    final remainder = 100 % _objectives.length;
    
    setState(() {
      for (int i = 0; i < _objectives.length; i++) {
        final weight = weightPerObjective + (i < remainder ? 1 : 0);
        _objectives[i] = _objectives[i].copyWith(weight: weight);
      }
    });
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskToEdit != null ? 'Edit Task' : 'Create Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Describe what needs to be done...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                hintText: 'Additional notes or context...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            // Task Properties
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Priority>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: Priority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (Priority? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPriority = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<TaskType>(
                    value: _selectedTaskType,
                    decoration: const InputDecoration(
                      labelText: 'Task Type',
                      border: OutlineInputBorder(),
                    ),
                    items: TaskType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (TaskType? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTaskType = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Color Picker
            ListTile(
              title: const Text('Task Color'),
              subtitle: Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Pick a color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: _selectedColor,
                          onColorChanged: (color) {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Deadline
            ListTile(
              title: const Text('Deadline'),
              subtitle: Text(_selectedDeadline != null 
                  ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                  : 'No deadline set'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedDeadline != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _selectedDeadline = null;
                          _selectedTime = null;
                        });
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDeadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDeadline = date;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Time (if deadline is set)
            if (_selectedDeadline != null) ...[
              ListTile(
                title: const Text('Time'),
                subtitle: Text(_selectedTime != null 
                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'No time set'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedTime != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedTime = null;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedTime = time;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Objectives Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Objectives',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _autoBalanceWeights,
                      child: const Text('Auto-balance'),
                    ),
                    ElevatedButton(
                      onPressed: _addObjective,
                      child: const Text('Add Objective'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (_objectives.isEmpty)
              const Text(
                'No objectives defined. Add objectives to break down this task into smaller, measurable steps.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...(_objectives.asMap().entries.map((entry) {
                final index = entry.key;
                final objective = entry.value;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: objective.name,
                                decoration: const InputDecoration(
                                  labelText: 'Objective Name',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  _updateObjective(index, objective.copyWith(name: value));
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue: objective.weight.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Weight %',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final weight = int.tryParse(value) ?? 0;
                                  _updateObjective(index, objective.copyWith(weight: weight));
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Checkbox(
                              value: objective.isCompleted,
                              onChanged: (value) {
                                _updateObjective(index, objective.copyWith(isCompleted: value ?? false));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeObjective(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTask,
                child: Text(
                  widget.taskToEdit != null ? 'Update Task' : 'Create Task',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;
    
    // Combine deadline and time
    DateTime? finalDeadline;
    if (_selectedDeadline != null && _selectedTime != null) {
      finalDeadline = DateTime(
        _selectedDeadline!.year,
        _selectedDeadline!.month,
        _selectedDeadline!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    } else if (_selectedDeadline != null) {
      finalDeadline = _selectedDeadline;
    }
    
    final task = Task(
      id: widget.taskToEdit?.id ?? _generateId(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      priority: _selectedPriority,
      taskType: _selectedTaskType,
      deadline: finalDeadline,
      color: _selectedColor,
      reminderTime: _hasReminder ? _reminderTime : null,
      createdAt: widget.taskToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      objectives: _objectives.where((obj) => obj.name.isNotEmpty).toList(),
    );
    
    widget.onTaskSaved(task);
    Navigator.of(context).pop();
  }
}
