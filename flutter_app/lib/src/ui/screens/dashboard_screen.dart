import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_provider.dart';
import '../../auth/role_guard.dart';
import '../widgets/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final guard = RoleGuard(authState);
    final user = authState.user;
    final name = user?['name'] as String? ?? user?['username'] as String? ?? 'User';
    final role = user?['role'] as String? ?? 'N/A';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _GradientSliverAppBar(
            name: name,
            role: role,
            onLogout: () => ref.read(authProvider.notifier).logout(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (guard.isAdmin) ...[
                  _QuickStatsRow(),
                  const SizedBox(height: 24),
                ],
                _SectionTitle(title: 'Quick Actions'),
                const SizedBox(height: 12),
                _QuickActionsGrid(guard: guard),
                const SizedBox(height: 24),
                if (guard.isAdmin) ...[
                  _SectionTitle(title: 'Recent Activity'),
                  const SizedBox(height: 12),
                  _ActivityTile(
                    icon: Icons.person_add,
                    title: 'New Employee Onboarded',
                    subtitle: 'Juan dela Cruz joined as Software Engineer',
                    time: '2 hours ago',
                  ),
                  _ActivityTile(
                    icon: Icons.description,
                    title: 'Leave Request Approved',
                    subtitle: 'Maria Santos — Annual Leave (3 days)',
                    time: '5 hours ago',
                  ),
                  _ActivityTile(
                    icon: Icons.attach_money,
                    title: 'Payroll Processed',
                    subtitle: 'May 2026 payroll has been finalized',
                    time: '1 day ago',
                  ),
                  const SizedBox(height: 32),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientSliverAppBar extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback? onLogout;

  const _GradientSliverAppBar({
    required this.name,
    required this.role,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log out',
            onPressed: onLogout,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00D1B2), Color(0xFF0098A6), Color(0xFF005F73)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.badge, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          role,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            label: 'Total Employees',
            value: '128',
            gradientColors: const [Color(0xFF00D1B2), Color(0xFF0098A6)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.beach_access,
            label: 'On Leave',
            value: '12',
            gradientColors: const [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.pending_actions,
            label: 'Pending',
            value: '8',
            gradientColors: const [Color(0xFFFFD93D), Color(0xFFFF9F1C)],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradientColors;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final RoleGuard guard;
  const _QuickActionsGrid({required this.guard});

  @override
  Widget build(BuildContext context) {
    final isEmployee = guard.isEmployee;
    final actions = [
      _ActionItem(icon: Icons.fingerprint, label: 'Attendance', color: const Color(0xFF00D1B2)),
      _ActionItem(icon: Icons.fingerprint, label: 'Face Registration', color: const Color(0xFF6C63FF)),
      if (!isEmployee) ...[
        _ActionItem(icon: Icons.person_add, label: 'Add Employee', color: const Color(0xFF00D1B2)),
        _ActionItem(icon: Icons.event, label: 'Manage Leaves', color: const Color(0xFF6C63FF)),
        _ActionItem(icon: Icons.attach_money, label: 'Payroll', color: const Color(0xFFFF6B6B)),
      ],
      _ActionItem(icon: Icons.schedule, label: 'Time Logs', color: const Color(0xFFFFD93D)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions.map((action) {
          return Padding(
            padding: EdgeInsets.only(
              left: action == actions.first ? 0 : 6,
              right: action == actions.last ? 0 : 6,
            ),
            child: SizedBox(
              width: 110,
              child: _ActionButton(item: action),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionItem({required this.icon, required this.label, required this.color});
}

class _ActionButton extends StatelessWidget {
  final _ActionItem item;

  const _ActionButton({required this.item});

  void _onTap(BuildContext context) {
    if (item.label == 'Attendance') {
      context.go('/attendance');
    } else if (item.label == 'Time Logs') {
      context.go('/time-logs');
    } else if (item.label == 'Face Registration') {
      context.go('/face-status');
    } else if (item.label == 'Payroll') {
      context.go('/payroll');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              item.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withAlpha(100),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
