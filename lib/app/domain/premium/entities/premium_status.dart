import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/premium/entities/subscription_status.dart';

class PremiumStatus extends Equatable {
  const PremiumStatus({required this.status, this.productId, this.expiresAt});

  const PremiumStatus.free() : status = .none, productId = null, expiresAt = null;

  factory PremiumStatus.fromMap(Map<String, dynamic> row) => PremiumStatus(
    status: SubscriptionStatus.fromWireValue(row['status'] as String?),
    productId: row['product_id'] as String?,
    expiresAt: row['expires_at'] == null ? null : DateTime.parse(row['expires_at'] as String).toLocal(),
  );

  final SubscriptionStatus status;
  final String? productId;
  final DateTime? expiresAt;

  // The date is checked alongside the status because the row is only corrected
  // when the store tells us: a subscription that lapsed an hour ago still reads
  // as active until the renewal notification arrives.
  bool get isActive => status.entitles && !_hasExpired;

  bool get _hasExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  @override
  List<Object?> get props => [status, productId, expiresAt];
}
