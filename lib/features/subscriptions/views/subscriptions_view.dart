import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/formatters.dart';
import 'package:instructor_beats_admin/core/widgets/empty_state_message.dart';
import 'package:instructor_beats_admin/core/widgets/pagination_controls.dart';
import 'package:instructor_beats_admin/core/widgets/section_header.dart';
import 'package:instructor_beats_admin/features/subscriptions/controllers/subscriptions_controller.dart';
import 'package:instructor_beats_admin/models/subscription_model.dart';

class SubscriptionsView extends GetView<SubscriptionsController> {
  const SubscriptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Subscriptions'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: wide ? 360 : double.infinity,
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search user or plan',
                  ),
                  onChanged: controller.setSearch,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(
              () {
                controller.searchQuery.value;
                controller.currentPage.value;
                final items = controller.pageItems;
                final listEmpty = controller.filtered.isEmpty;
                if (listEmpty) {
                  final noSubs = controller.data.subscriptions.isEmpty;
                  return Column(
                    children: [
                      Expanded(
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: EmptyStateMessage(
                            icon: Icons.subscriptions_outlined,
                            title: noSubs
                                ? 'No subscriptions yet'
                                : 'No matching subscriptions',
                            message: noSubs
                                ? 'When customers subscribe through your app or billing, their plans will show up here for you to manage.'
                                : 'Try a different search or clear the box to see all subscriptions.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PaginationControls(
                        currentPage: controller.currentPage.value,
                        totalItems: controller.filtered.length,
                        itemsPerPage: controller.itemsPerPage,
                        onPageChanged: controller.setPage,
                      ),
                    ],
                  );
                }
                if (!wide) {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (context, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final s = items[i];
                            return _SubCard(
                              sub: s,
                              onCancel: () => controller.cancelAtPeriodEnd(s),
                              onResume: () => controller.resume(s),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      PaginationControls(
                        currentPage: controller.currentPage.value,
                        totalItems: controller.filtered.length,
                        itemsPerPage: controller.itemsPerPage,
                        onPageChanged: controller.setPage,
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: LayoutBuilder(
                          builder: (context, constraints) => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            headingTextStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.2,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            dataTextStyle: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            columnSpacing: 24,
                            horizontalMargin: 18,
                            headingRowHeight: 52,
                            dataRowMinHeight: 56,
                            dataRowMaxHeight: 62,
                            dividerThickness: 0.5,
                            columns: const [
                              DataColumn(label: Text('User')),
                              DataColumn(label: Text('Plan')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Period end')),
                              DataColumn(label: Text('Stripe sub')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: List.generate(items.length, (i) {
                              final s = items[i];
                              return DataRow.byIndex(
                                index: i,
                                color: WidgetStateProperty.resolveWith(
                                  (_) => i.isEven
                                      ? Colors.transparent
                                      : Theme.of(
                                          context,
                                        ).colorScheme.surface.withValues(alpha: 0.2),
                                ),
                                  cells: [
                                    DataCell(Text(s.userLabel)),
                                    DataCell(Text(s.plan)),
                                    DataCell(_SubscriptionStatusBadge(status: s.status)),
                                    DataCell(Text(adminDateFormat.format(s.currentPeriodEnd))),
                                    DataCell(
                                      Tooltip(
                                        message: s.stripeSubscriptionId,
                                        child: Text(
                                          s.stripeSubscriptionId,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          if (s.status == SubscriptionStatus.active)
                                            FilledButton.tonal(
                                              onPressed: () => controller.cancelAtPeriodEnd(s),
                                              child: const Text('Cancel'),
                                            ),
                                          if (s.status != SubscriptionStatus.active)
                                            FilledButton(
                                              onPressed: () => controller.resume(s),
                                              child: const Text('Resume'),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                            }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PaginationControls(
                      currentPage: controller.currentPage.value,
                      totalItems: controller.filtered.length,
                      itemsPerPage: controller.itemsPerPage,
                      onPageChanged: controller.setPage,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubCard extends StatelessWidget {
  const _SubCard({
    required this.sub,
    required this.onCancel,
    required this.onResume,
  });

  final SubscriptionModel sub;
  final VoidCallback onCancel;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sub.userLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text('${sub.plan} • ${subscriptionStatusLabel(sub.status)}'),
            Text(
              'Renews ${adminDateFormat.format(sub.currentPeriodEnd)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (sub.status == SubscriptionStatus.active)
                  FilledButton.tonal(onPressed: onCancel, child: const Text('Cancel')),
                if (sub.status != SubscriptionStatus.active)
                  FilledButton(onPressed: onResume, child: const Text('Resume')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionStatusBadge extends StatelessWidget {
  const _SubscriptionStatusBadge({required this.status});

  final SubscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      SubscriptionStatus.active => ('Active', Colors.greenAccent, Icons.check_circle_outline),
      SubscriptionStatus.canceled => ('Canceled', Colors.redAccent, Icons.cancel_outlined),
      SubscriptionStatus.pastDue => ('Past due', Colors.orangeAccent, Icons.warning_amber_outlined),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
