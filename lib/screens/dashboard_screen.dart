import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';
import '../providers/subject_provider.dart';
import '../shared/widgets/bottom_nav.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/progress_chart.dart';
import 'search_screen.dart';
import 'schedule_screen.dart';
import 'subject_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjectProvider = context.watch<SubjectProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();

    final totalSubjects =
        dashboardProvider.calculateTotalSubjects(subjectProvider);
    final totalTopics = dashboardProvider.calculateTotalTopics(subjectProvider);
    final completedTopics =
        dashboardProvider.calculateCompletedTopics(subjectProvider);
    final pendingTopics =
        dashboardProvider.calculatePendingTopics(subjectProvider);
    final completionPercent =
        dashboardProvider.calculateCompletionPercentage(subjectProvider);
    final weakSubjects = dashboardProvider.getWeakSubjects(subjectProvider);
    final recommendation =
        dashboardProvider.getNextRecommendedTopic(subjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DashboardCard(
                  title: 'Total Subjects',
                  countText: '$totalSubjects',
                  icon: Icons.menu_book_rounded,
                  gradientColors: [Colors.blue.shade100, Colors.blue.shade50],
                ),
                DashboardCard(
                  title: 'Total Topics',
                  countText: '$totalTopics',
                  icon: Icons.topic_rounded,
                  gradientColors: [Colors.purple.shade100, Colors.purple.shade50],
                ),
                DashboardCard(
                  title: 'Completed Topics',
                  countText: '$completedTopics',
                  icon: Icons.check_circle_outline_rounded,
                  gradientColors: [Colors.green.shade100, Colors.green.shade50],
                ),
                DashboardCard(
                  title: 'Pending Topics',
                  countText: '$pendingTopics',
                  icon: Icons.pending_actions_rounded,
                  gradientColors: [Colors.orange.shade100, Colors.orange.shade50],
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ProgressChart(percentage: completionPercent),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'You are ${completionPercent.toStringAsFixed(0)}% ready for exams',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Subject Priority',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: weakSubjects.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Add subjects and topics to see weak areas.'),
                    )
                  : Column(
                      children: weakSubjects.map((item) {
                        final percentage = (item.progress * 100).toStringAsFixed(0);
                        return ListTile(
                          title: Text(item.subjectName),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: LinearProgressIndicator(
                              value: item.progress,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(12),
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                          trailing: Text('$percentage%'),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Today Study Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: dashboardProvider.todaySessions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No study sessions planned for today'),
                    )
                  : Column(
                      children: dashboardProvider.todaySessions.map((session) {
                        return ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text('${session.subjectName} • ${session.topicName}'),
                          subtitle: Text(session.time),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Smart Suggestion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.indigo.shade50,
                border: Border.all(color: Colors.indigo.shade100),
              ),
              child: recommendation == null
                  ? const Text(
                      'Next Recommended Topic\n\nNo pending topics right now. Great work!',
                    )
                  : Text(
                      'Next Recommended Topic\n\n'
                      'Subject: ${recommendation['subjectName']}\n'
                      'Topic: ${recommendation['topicName']}\n'
                      'Reason: ${recommendation['reason']}',
                      style: const TextStyle(height: 1.5),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            return;
          }

          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SubjectScreen()),
            );
            return;
          }

          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleScreen()),
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

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This section will be added soon.'),
            ),
          );
        },
      ),
    );
  }
}
