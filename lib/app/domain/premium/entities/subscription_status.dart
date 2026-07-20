enum SubscriptionStatus {
  none(null),
  active('active'),
  expired('expired'),
  cancelled('cancelled'),
  inGracePeriod('in_grace_period');

  const SubscriptionStatus(this.wireValue);

  final String? wireValue;

  static SubscriptionStatus fromWireValue(String? value) =>
      SubscriptionStatus.values.firstWhere((status) => status.wireValue == value, orElse: () => .none);

  // cancelled still entitles until it lapses: the user turned off auto-renew,
  // they did not ask for the rest of the period they paid for back.
  bool get entitles => switch (this) {
    .active || .inGracePeriod || .cancelled => true,
    .none || .expired => false,
  };
}
