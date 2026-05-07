import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/topic_model.dart';
import '../providers/search_provider.dart';
import '../providers/subject_provider.dart';
import '../shared/widgets/bottom_nav.dart';
import '../widgets/search_tile.dart';
import 'dashboard_screen.dart';
import 'schedule_screen.dart';
import 'subject_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final subjectProvider = context.watch<SubjectProvider>();

    final results = searchProvider.getFilteredResults(subjectProvider);
    final subjectNames = _getSubjectNames(subjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: _SearchBar(
              initialValue: searchProvider.query,
              onChanged: (value) => searchProvider.searchTopics(value),
              onClear: () => searchProvider.searchTopics(''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _FiltersSection(
              subjectNames: subjectNames,
              selectedSubject: searchProvider.selectedSubject,
              selectedStatus: searchProvider.selectedStatus,
              selectedProgress: searchProvider.progressFilter,
              onSubjectChanged: (value) => searchProvider.filterBySubject(value),
              onStatusChanged: (value) => searchProvider.filterByStatus(value),
              onProgressChanged: (value) =>
                  searchProvider.filterByProgress(value),
              onReset: () => searchProvider.resetFilters(),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return SearchTile(item: results[index]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;

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

          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleScreen()),
            );
            return;
          }
        },
      ),
    );
  }

  List<String> _getSubjectNames(SubjectProvider subjectProvider) {
    final names = subjectProvider.subjects.map((s) => s.subjectName).toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['All', ...names];
  }
}

class _SearchBar extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.initialValue,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search topics or subjects...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    onClear();
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

class _FiltersSection extends StatelessWidget {
  final List<String> subjectNames;
  final String selectedSubject;
  final String selectedStatus;
  final String selectedProgress;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onProgressChanged;
  final VoidCallback onReset;

  const _FiltersSection({
    required this.subjectNames,
    required this.selectedSubject,
    required this.selectedStatus,
    required this.selectedProgress,
    required this.onSubjectChanged,
    required this.onStatusChanged,
    required this.onProgressChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filters',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _DropdownField(
                    label: 'Subject',
                    value: selectedSubject,
                    items: subjectNames,
                    onChanged: onSubjectChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DropdownField(
                    label: 'Status',
                    value: selectedStatus,
                    items: const [
                      'All',
                      TopicModel.notStarted,
                      TopicModel.inProgress,
                      TopicModel.completed,
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ProgressChip(
                  label: 'All',
                  isSelected: selectedProgress == 'All',
                  onTap: () => onProgressChanged('All'),
                ),
                _ProgressChip(
                  label: 'Less than 50%',
                  isSelected: selectedProgress == '<50',
                  onTap: () => onProgressChanged('<50'),
                ),
                _ProgressChip(
                  label: 'More than 50%',
                  isSelected: selectedProgress == '>50',
                  onTap: () => onProgressChanged('>50'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue == null) return;
            onChanged(newValue);
          },
        ),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProgressChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isSelected ? Colors.indigo : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade500),
            const SizedBox(height: 10),
            const Text(
              'No matching topics found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Try changing filters',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
