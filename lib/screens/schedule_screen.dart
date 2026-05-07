import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/schedule_provider.dart';
import '../providers/subject_provider.dart';
import '../shared/widgets/bottom_nav.dart';
import 'dashboard_screen.dart';
import 'search_screen.dart';
import 'subject_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        elevation: 0,
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          final sessions = provider.sessions;

          if (sessions.isEmpty) {
            return const _EmptyScheduleState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            physics: const BouncingScrollPhysics(),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _ScheduleCard(
                subjectName: session.subjectName,
                topicName: session.topicName,
                date: session.date,
                time: session.time,
                durationMinutes: session.durationMinutes,
                isCompleted: session.isCompleted,
                onToggle: () => provider.toggleComplete(session.id),
                onDelete: () => provider.removeSession(session.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddScheduleSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
            return;
          }

          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SubjectScreen()),
            );
            return;
          }

          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
            return;
          }
        },
      ),
    );
  }

  void _openAddScheduleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddScheduleSheet(),
    );
  }
}

class _AddScheduleSheet extends StatefulWidget {
  const _AddScheduleSheet();

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();

  String? _selectedSubjectId;
  String? _selectedTopicId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectProvider = context.watch<SubjectProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();

    final subjects = subjectProvider.subjects;
    final selectedSubject =
        subjects.where((s) => s.id == _selectedSubjectId).toList();
    final topics = selectedSubject.isEmpty ? [] : selectedSubject.first.topics;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add Study Session',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _DropdownField(
                  label: 'Subject',
                  value: _selectedSubjectId,
                  items: subjects
                      .map<DropdownMenuItem<String>>((s) => DropdownMenuItem<String>(
                            value: s.id,
                            child: Text(s.subjectName),
                          ))
                      .toList(growable: false),
                  validator: (v) => v == null ? 'Please select a subject' : null,
                  onChanged: (value) {
                    setState(() {
                      _selectedSubjectId = value;
                      _selectedTopicId = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Topic',
                  value: _selectedTopicId,
                  items: topics
                      .map<DropdownMenuItem<String>>((t) => DropdownMenuItem<String>(
                            value: t.id,
                            child: Text(t.topicName),
                          ))
                      .toList(growable: false),
                  validator: (v) => v == null ? 'Please select a topic' : null,
                  onChanged: (value) => setState(() => _selectedTopicId = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        label: 'Date',
                        valueText: _selectedDate == null
                            ? 'Select'
                            : _formatDate(_selectedDate!),
                        icon: Icons.calendar_today_rounded,
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 2),
                            initialDate: _selectedDate ?? now,
                          );
                          if (picked == null) return;
                          setState(() => _selectedDate = picked);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerField(
                        label: 'Time',
                        valueText: _selectedTime == null
                            ? 'Select'
                            : _selectedTime!.format(context),
                        icon: Icons.schedule_rounded,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                          );
                          if (picked == null) return;
                          setState(() => _selectedTime = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duration (minutes)',
                    prefixIcon: const Icon(Icons.timelapse_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter duration';
                    }
                    final minutes = int.tryParse(value.trim());
                    if (minutes == null || minutes <= 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = _formKey.currentState?.validate() ?? false;
                      if (!ok) return;
                      if (_selectedDate == null) {
                        _showSnack(context, 'Please select a date');
                        return;
                      }
                      if (_selectedTime == null) {
                        _showSnack(context, 'Please select a time');
                        return;
                      }

                      final subject = subjects.firstWhere((s) => s.id == _selectedSubjectId);
                      final topic = subject.topics.firstWhere((t) => t.id == _selectedTopicId);
                      final durationMinutes = int.parse(_durationController.text.trim());

                      await scheduleProvider.addSession(
                        subjectId: subject.id,
                        subjectName: subject.subjectName,
                        topicId: topic.id,
                        topicName: topic.topicName,
                        date: _selectedDate!,
                        time: _selectedTime!.format(context),
                        durationMinutes: durationMinutes,
                      );

                      // Clear form (beginner-friendly)
                      _durationController.clear();
                      setState(() {
                        _selectedSubjectId = null;
                        _selectedTopicId = null;
                        _selectedDate = null;
                        _selectedTime = null;
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        _showSnack(context, 'Schedule added successfully');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Add Session'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final String? Function(String?) validator;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String valueText;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.valueText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          prefixIcon: Icon(icon),
        ),
        child: Text(valueText),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String subjectName;
  final String topicName;
  final DateTime date;
  final String time;
  final int durationMinutes;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.subjectName,
    required this.topicName,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.isCompleted,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleColor = Colors.grey.shade700;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$subjectName • $topicName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  text: _formatDate(date),
                ),
                _InfoChip(
                  icon: Icons.schedule_rounded,
                  text: time,
                ),
                _InfoChip(
                  icon: Icons.timelapse_rounded,
                  text: '${durationMinutes}m',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade200),
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : subtitleColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCompleted ? 'Completed' : 'Mark as completed',
                    style: TextStyle(color: subtitleColor),
                  ),
                ),
                Switch(
                  value: isCompleted,
                  onChanged: (_) => onToggle(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyScheduleState extends StatelessWidget {
  const _EmptyScheduleState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 56, color: Colors.grey.shade500),
            const SizedBox(height: 10),
            const Text(
              'No sessions scheduled',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap the Add button to plan today’s study.',
              style: TextStyle(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
