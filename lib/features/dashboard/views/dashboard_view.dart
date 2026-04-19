import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/formatters.dart';
import 'package:instructor_beats_admin/core/widgets/empty_state_message.dart';
import 'package:instructor_beats_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:instructor_beats_admin/models/subscription_model.dart';
import 'package:instructor_beats_admin/theme/app_colors.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = controller.data;

    return Obx(() {
      controller.activitySearchQuery.value;
      data.activity.length;
      final songCount = data.songs.length;
      final categoryCount = data.categories.length;
      final userCount = data.users.length;
      final activeSubs = data.subscriptions
          .where((s) => s.status == SubscriptionStatus.active)
          .length;
      final totalSubs = data.subscriptions.length;
      final activeRate = totalSubs == 0
          ? 0.0
          : activeSubs / totalSubs;

      return LayoutBuilder(
        builder: (context, c) {
          final pad = c.maxWidth >= 900 ? 28.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: DashColors.textMuted.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, bc) {
                    final w = bc.maxWidth;
                    int cross = 1;
                    if (w >= 1200) cross = 5;
                    if (w >= 900 && w < 1200) cross = 3;
                    if (w >= 600 && w < 900) cross = 2;
                    return GridView.count(
                      crossAxisCount: cross,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: cross >= 5
                          ? 1.15
                          : cross >= 3
                              ? 1.2
                              : 1.35,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _HrMetricCard(
                          title: 'Songs',
                          value: '$songCount',
                          accent: DashColors.blue,
                          icon: Icons.library_music_rounded,
                          progress: (songCount / 50).clamp(0.0, 1.0),
                          deltaLabel: '+${songCount > 2 ? 8 : 3}%',
                          deltaPositive: true,
                        ),
                        _HrMetricCard(
                          title: 'Categories',
                          value: '$categoryCount',
                          accent: DashColors.violet,
                          icon: Icons.category_rounded,
                          progress: (categoryCount / 12).clamp(0.0, 1.0),
                          deltaLabel: '+2%',
                          deltaPositive: true,
                        ),
                        _HrMetricCard(
                          title: 'Users',
                          value: '$userCount',
                          accent: DashColors.cyan,
                          icon: Icons.people_alt_rounded,
                          progress: (userCount / 100).clamp(0.0, 1.0),
                          deltaLabel: '+5%',
                          deltaPositive: true,
                        ),
                        _HrMetricCard(
                          title: 'Active subs',
                          value: '$activeSubs',
                          accent: DashColors.orange,
                          icon: Icons.subscriptions_rounded,
                          progress: activeRate,
                          deltaLabel: totalSubs == 0 ? '—' : '${(activeRate * 100).round()}%',
                          deltaPositive: activeRate >= 0.5,
                    ),
                    _HrMetricCard(
                      title: 'Efficiency',
                      value: '${(activeRate * 100).round()}%',
                      accent: DashColors.blue,
                      icon: Icons.bolt_rounded,
                      progress: activeRate,
                      deltaLabel: '+4%',
                      deltaPositive: true,
                    ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'Recent activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: DashColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  style: const TextStyle(
                    color: DashColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search recent activity…',
                    hintStyle: TextStyle(
                      color: DashColors.textMuted.withValues(alpha: 0.75),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: DashColors.textMuted,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: DashColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: DashColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: DashColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.2,
                      ),
                    ),
                  ),
                  onChanged: controller.setActivitySearch,
                ),
                const SizedBox(height: 12),
                Card(
                  child: controller.filteredActivity.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 16,
                          ),
                          child: EmptyStateMessage(
                            icon: Icons.history_rounded,
                            title: data.activity.isEmpty
                                ? 'No recent activity yet'
                                : 'No activity matches your search',
                            message: data.activity.isEmpty
                                ? 'When you add or change songs, song or video categories, members, playlists, videos, or subscriptions, a short summary will show up here.'
                                : 'Try different words or clear the search to see all recent items.',
                            titleColor: DashColors.textPrimary,
                            messageColor: DashColors.textMuted,
                            iconColor:
                                DashColors.textMuted.withValues(alpha: 0.45),
                          ),
                        )
                      : Column(
                          children: [
                            for (var i = 0;
                                i < controller.filteredActivity.length;
                                i++) ...[
                              if (i > 0)
                                const Divider(
                                  height: 1,
                                  color: DashColors.border,
                                ),
                              ListTile(
                                title: Text(
                                  controller.filteredActivity[i].title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: DashColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  controller.filteredActivity[i].subtitle,
                                  style: const TextStyle(
                                    color: DashColors.textMuted,
                                  ),
                                ),
                                trailing: Text(
                                  adminDateFormat.format(
                                    controller.filteredActivity[i].at,
                                  ),
                                  style: const TextStyle(
                                    color: DashColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _HrMetricCard extends StatelessWidget {
  const _HrMetricCard({
    required this.title,
    required this.value,
    required this.accent,
    required this.icon,
    required this.progress,
    required this.deltaLabel,
    required this.deltaPositive,
  });

  final String title;
  final String value;
  final Color accent;
  final IconData icon;
  final double progress;
  final String deltaLabel;
  final bool deltaPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const Spacer(),
              Text(
                'Daily',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: DashColors.textMuted.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.more_horiz_rounded,
                size: 18,
                color: DashColors.textMuted.withValues(alpha: 0.7),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DashColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 32,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(color: accent),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: DashColors.border,
              color: accent,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: DashColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (deltaLabel != '—')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (deltaPositive ? DashColors.green : DashColors.red)
                        .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    deltaLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: deltaPositive ? DashColors.green : DashColors.red,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final w = size.width;
    final h = size.height;
    final pts = <Offset>[
      Offset(0, h * 0.72),
      Offset(w * 0.2, h * 0.55),
      Offset(w * 0.38, h * 0.62),
      Offset(w * 0.55, h * 0.35),
      Offset(w * 0.72, h * 0.45),
      Offset(w * 0.88, h * 0.28),
      Offset(w, h * 0.38),
    ];

    path.moveTo(pts.first.dx, pts.first.dy);
    fillPath.moveTo(pts.first.dx, h);
    fillPath.lineTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(w, h);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
