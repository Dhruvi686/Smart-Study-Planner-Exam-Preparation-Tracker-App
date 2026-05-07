import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/topic_model.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import 'dashboard_screen.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TopicProvider(),
      child: Builder(
        builder: (context) {
          final subjectProvider = context.watch<SubjectProvider>();
          context.watch<TopicProvider>();
          final topicsProvider = context.read<TopicProvider>();
          final subjects = subjectProvider.subjects;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  // If this screen was pushed normally, pop it.
                  // If it was opened using replacement, go back to Dashboard.
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  );
                },
              ),
              title: const Text('Subjects'),
            ),
            body: subjects.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No subjects added yet.\nTap + to add your first subject.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(subject.subjectName),
                          subtitle: Text('${subject.topics.length} topic(s)'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Delete Subject',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  subjectProvider.removeSubject(subject.id);
                                },
                              ),
                              const Icon(Icons.expand_more),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _showAddTopicDialog(context, subject.id),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Topic'),
                                ),
                              ),
                            ),
                            if (subject.topics.isEmpty)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('No topics added yet.'),
                                ),
                              )
                            else
                              ...subject.topics.map(
                                (topic) => Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 8),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(topic.topicName),
                                      subtitle: Text(
                                        'Estimated Time: ${topic.estimatedStudyTime}',
                                      ),
                                      trailing: Wrap(
                                        spacing: 8,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          DropdownButton<String>(
                                            value: topic.status,
                                            items: TopicModel.statusOptions
                                                .map(
                                                  (status) =>
                                                      DropdownMenuItem<String>(
                                                    value: status,
                                                    child: Text(status),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              if (value == null) {
                                                return;
                                              }
                                              topicsProvider.updateStatus(
                                                subject,
                                                topic.id,
                                                value,
                                                subjectProvider,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon:
                                                const Icon(Icons.delete_outline),
                                            onPressed: () {
                                              topicsProvider.removeTopic(
                                                subject,
                                                topic.id,
                                                subjectProvider,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddSubjectDialog(context),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: subjectController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Subject name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Subject name cannot be empty';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                context.read<SubjectProvider>().addSubject(
                      subjectController.text,
                    );
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTopicDialog(BuildContext context, String subjectId) {
    final topicNameController = TextEditingController();
    final estimatedTimeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Topic'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: topicNameController,
                  decoration: const InputDecoration(
                    labelText: 'Topic Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Topic name cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: estimatedTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Study Time',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Estimated study time is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final subjects = context.read<SubjectProvider>().subjects;
                final selectedSubject = subjects.firstWhere(
                  (subject) => subject.id == subjectId,
                );

                context.read<TopicProvider>().addTopic(
                      selectedSubject,
                      topicNameController.text,
                      estimatedTimeController.text,
                      context.read<SubjectProvider>(),
                    );

                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
