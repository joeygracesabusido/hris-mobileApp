import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/auth_provider.dart';
import '../../auth/role_guard.dart';
import '../../data/models/time_log.dart';
import '../../data/providers/time_log_list_provider.dart';
import '../widgets/app_theme.dart';

class TimeLogScreen extends ConsumerStatefulWidget {
  const TimeLogScreen({super.key});

  @override
  ConsumerState<TimeLogScreen> createState() => _TimeLogScreenState();
}

class _TimeLogScreenState extends ConsumerState<TimeLogScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TimeLog> _filterLogs(List<TimeLog> logs) {
    if (_searchQuery.isEmpty) return logs;
    final query = _searchQuery.toLowerCase();
    return logs.where((log) {
      final name = log.employee?.fullName.toLowerCase() ?? '';
      final id = log.employee?.employeeId.toLowerCase() ?? '';
      return name.contains(query) || id.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final guard = RoleGuard(authState);
    final employeeId = guard.isAdmin ? null : guard.currentEmployeeId;
    final timeLogAsync = ref.watch(timeLogListProvider(employeeId));

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Time Logs'),
          backgroundColor: AppTheme.primary,
        ),
        backgroundColor: AppTheme.background,
        body: const Center(
          child: Text(
            'Please log in to view time logs',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Logs'),
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      backgroundColor: AppTheme.background,
      body: timeLogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('$err',
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(timeLogListProvider(employeeId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (logs) {
          final filtered = _filterLogs(logs);
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(timeLogListProvider(employeeId));
              await ref.read(timeLogListProvider(employeeId).future);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search by name or ID...',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                        filled: true,
                        fillColor: AppTheme.cardBackground,
                        prefixIcon: Icon(Icons.search, color: Colors.white.withAlpha(150), size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.white.withAlpha(150), size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No time logs found',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _TimeLogCard(filtered[index]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TimeLogCard extends StatelessWidget {
  final TimeLog log;
  const _TimeLogCard(this.log);

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return DateFormat('hh:mm a').format(dt);
  }

  String _formatDate(DateTime dt) {
    return DateFormat('MMM dd, yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final empName = log.employee?.fullName ?? 'Unknown';
    final empId = log.employee?.employeeId ?? 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  empName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _StatusBadge(log),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ID: $empId',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(label: 'Date', value: _formatDate(log.date)),
              const SizedBox(width: 12),
              _InfoChip(label: 'In', value: _formatTime(log.clockIn)),
              const SizedBox(width: 12),
              _InfoChip(label: 'Out', value: _formatTime(log.clockOut)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MiniStat(label: 'Hours', value: '${log.workHours.toStringAsFixed(1)}h'),
              if (log.lateMinutes > 0) ...[
                const SizedBox(width: 12),
                _MiniStat(
                  label: 'Late',
                  value: '${log.lateMinutes}m',
                  color: const Color(0xFFFF6B6B),
                ),
              ],
              if (log.undertimeMinutes > 0) ...[
                const SizedBox(width: 12),
                _MiniStat(
                  label: 'Undertime',
                  value: '${log.undertimeMinutes}m',
                  color: const Color(0xFFFFD93D),
                ),
              ],
            ],
          ),
          if (log.shift != null) ...[
            const SizedBox(height: 8),
            Text(
              'Shift: ${log.shift!.name} (${log.shift!.startTime} - ${log.shift!.endTime})',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TimeLog log;
  const _StatusBadge(this.log);

  @override
  Widget build(BuildContext context) {
    final isPresent = log.clockIn != null;
    final hasClockedOut = log.clockOut != null;

    Color color;
    String label;

    if (!isPresent) {
      color = const Color(0xFFFF6B6B);
      label = 'Absent';
    } else if (!hasClockedOut) {
      color = const Color(0xFFFFD93D);
      label = 'Clocked In';
    } else {
      color = const Color(0xFF00D1B2);
      label = 'Complete';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MiniStat({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: c,
          ),
        ),
      ],
    );
  }
}
