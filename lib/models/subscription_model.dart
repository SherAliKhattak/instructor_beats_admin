enum SubscriptionStatus { active, canceled, pastDue }

class SubscriptionModel {
  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.userLabel,
    required this.plan,
    required this.status,
    required this.currentPeriodEnd,
    required this.stripeSubscriptionId,
  });

  final String id;
  final String userId;
  final String userLabel;
  final String plan;
  final SubscriptionStatus status;
  final DateTime currentPeriodEnd;
  final String stripeSubscriptionId;

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? userLabel,
    String? plan,
    SubscriptionStatus? status,
    DateTime? currentPeriodEnd,
    String? stripeSubscriptionId,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userLabel: userLabel ?? this.userLabel,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      stripeSubscriptionId:
          stripeSubscriptionId ?? this.stripeSubscriptionId,
    );
  }
}
