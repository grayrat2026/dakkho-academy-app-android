import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

/// ExamSchedulePage — exam timetable with semester filter + list/calendar views.
/// Backend: TODO — /api/exam-schedule doesn't exist yet. In-memory sample data.
class ExamSchedulePage extends StatefulWidget {
  const ExamSchedulePage({super.key});
  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  int _selectedSemester = 5;
  bool _calendarView = false;

  // Sample exam schedule (TODO: replace with /api/exam-schedule)
  final Map<int, List<Map<String, dynamic>>> _exams = {
    5: [
      {'subject': 'Microprocessor & Interfacing', 'code': '61051', 'date': DateTime.now().add(const Duration(days: 30)), 'time': '10:00 AM', 'duration': '3 hours', 'room': 'Hall A-201', 'status': 'upcoming'},
      {'subject': 'Database Management', 'code': '61053', 'date': DateTime.now().add(const Duration(days: 33)), 'time': '10:00 AM', 'duration': '3 hours', 'room': 'Hall A-202', 'status': 'upcoming'},
      {'subject': 'Object Oriented Programming', 'code': '61054', 'date': DateTime.now().add(const Duration(days: 36)), 'time': '10:00 AM', 'duration': '3 hours', 'room': 'Hall A-203', 'status': 'upcoming'},
      {'subject': 'Operating System', 'code': '61055', 'date': DateTime.now().add(const Duration(days: 39)), 'time': '10:00 AM', 'duration': '3 hours', 'room': 'Hall A-201', 'status': 'upcoming'},
      {'subject': 'Data Communication', 'code': '61052', 'date': DateTime.now().add(const Duration(days: 42)), 'time': '10:00 AM', 'duration': '3 hours', 'room': 'Hall A-204', 'status': 'upcoming'},
    ],
    4: [
      {'subject': 'Mathematics-IV', 'code': '61041', 'date': DateTime.now().subtract(const Duration(days: 60)), 'time': '10:00 AM', 'duration': '3 hours', 'room': 'Hall B-101', 'status': 'completed'},
      {'subject': 'Digital Electronics', 'code': '61044', 'date': DateTime.now().subtract(const Duration(days: 63)), 'time': '10:00 AM', 'duration': '3 hours', 'room': 'Hall B-102', 'status': 'completed'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final exams = _exams[_selectedSemester] ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Exam Schedule'),
        actions: [
          IconButton(
            icon: Icon(_calendarView ? LucideIcons.list : LucideIcons.calendar),
            onPressed: () => setState(() => _calendarView = !_calendarView),
            tooltip: _calendarView ? 'List view' : 'Calendar view',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var s = 1; s <= 8; s++) ...[
                    FilterChip(
                      label: Text('Sem $s'),
                      selected: _selectedSemester == s,
                      onSelected: (_) => setState(() => _selectedSemester = s),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      body: exams.isEmpty
          ? const EmptyState(icon: LucideIcons.calendar, title: 'No exams scheduled', subtitle: 'Exam dates for this semester will appear here.')
          : _calendarView
              ? _buildCalendarView(exams)
              : _buildListView(exams),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> exams) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (_, i) {
        final exam = exams[i];
        final date = exam['date'] as DateTime;
        final isCompleted = exam['status'] == 'completed';
        final daysLeft = date.difference(DateTime.now()).inDays;

        return GlassCard(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          gradient: isCompleted ? LinearGradient(colors: [DakkhoColors.surfaceLight, DakkhoColors.surface]) : null,
          child: Row(
            children: [
              // Date block
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: isCompleted ? null : DakkhoColors.primaryGradient,
                  color: isCompleted ? DakkhoColors.surfaceLighter : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${date.day}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isCompleted ? DakkhoColors.textMuted : Colors.white)),
                    Text(_monthShort(date.month), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isCompleted ? DakkhoColors.textMuted : Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Subject info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: DakkhoColors.purple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(exam['code'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: DakkhoColors.purple, fontFamily: 'monospace')),
                        ),
                        const SizedBox(width: 8),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: DakkhoColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('COMPLETED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: DakkhoColors.success)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(exam['subject'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.clock, size: 11, color: DakkhoColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${exam['time']} · ${exam['duration']}', style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin, size: 11, color: DakkhoColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(exam['room'], style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              // Days left
              if (!isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: daysLeft < 7 ? DakkhoColors.danger.withValues(alpha: 0.15) : DakkhoColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('$daysLeft', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: daysLeft < 7 ? DakkhoColors.danger : DakkhoColors.warning)),
                      Text('days', style: TextStyle(fontSize: 9, color: daysLeft < 7 ? DakkhoColors.danger : DakkhoColors.warning)),
                    ],
                  ),
                ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildCalendarView(List<Map<String, dynamic>> exams) {
    // Simple calendar grid showing the current month with exam markers
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;  // Mon=0
    final daysInMonth = lastDay.day;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_monthFull(now.month)} ${now.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
              const SizedBox(height: 16),
              // Weekday headers
              Row(
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) =>
                  Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.textSecondary))))).toList(),
              ),
              const SizedBox(height: 8),
              // Calendar grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
                itemCount: startWeekday + daysInMonth,
                itemBuilder: (_, i) {
                  if (i < startWeekday) return const SizedBox();
                  final day = i - startWeekday + 1;
                  final date = DateTime(now.year, now.month, day);
                  final hasExam = exams.any((e) {
                    final ed = e['date'] as DateTime;
                    return ed.year == date.year && ed.month == date.month && ed.day == date.day;
                  });
                  final isToday = date.day == now.day && date.month == now.month;

                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: hasExam ? DakkhoColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: isToday ? Border.all(color: DakkhoColors.primary, width: 2) : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
                              color: isToday ? DakkhoColors.primary : DakkhoColors.textPrimary,
                            ),
                          ),
                        ),
                        if (hasExam)
                          Positioned(
                            top: 4, right: 4,
                            child: Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(color: DakkhoColors.danger, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Legend
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: DakkhoColors.danger, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Exam scheduled', style: TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                  const SizedBox(width: 16),
                  Container(width: 12, height: 12, decoration: BoxDecoration(border: Border.all(color: DakkhoColors.primary, width: 2), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  const Text('Today', style: TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                ],
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
      ],
    );
  }

  String _monthShort(int m) => ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][m - 1];
  String _monthFull(int m) => ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m - 1];
}
