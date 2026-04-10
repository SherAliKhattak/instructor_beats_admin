import 'package:intl/intl.dart';
import 'package:instructor_beats_admin/models/subscription_model.dart';

String formatDurationMmSs(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

final DateFormat adminDateFormat = DateFormat.yMMMd();

String subscriptionStatusLabel(SubscriptionStatus s) => switch (s) {
      SubscriptionStatus.active => 'Active',
      SubscriptionStatus.canceled => 'Canceled',
      SubscriptionStatus.pastDue => 'Past due',
    };
