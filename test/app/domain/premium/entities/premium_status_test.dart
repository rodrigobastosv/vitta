import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';
import 'package:vitta/app/domain/premium/entities/subscription_status.dart';

void main() {
  group('isActive', () {
    test('is false with no subscription at all', () {
      expect(const PremiumStatus.free().isActive, isFalse);
    });

    test('is true for an active subscription with no expiry recorded', () {
      expect(const PremiumStatus(status: .active).isActive, isTrue);
    });

    test('is true while in the grace period', () {
      expect(const PremiumStatus(status: .inGracePeriod).isActive, isTrue);
    });

    test('is true for a cancelled subscription that has not lapsed yet', () {
      final status = PremiumStatus(status: .cancelled, expiresAt: DateTime.now().add(const Duration(days: 5)));

      expect(status.isActive, isTrue);
    });

    test('is false once an expired status is recorded', () {
      expect(const PremiumStatus(status: .expired).isActive, isFalse);
    });

    // The row is only corrected when the store tells us, so an active status
    // with a past expiry is exactly the lag this guards against.
    test('is false when the expiry has passed even though the status still says active', () {
      final status = PremiumStatus(status: .active, expiresAt: DateTime.now().subtract(const Duration(hours: 1)));

      expect(status.isActive, isFalse);
    });
  });

  group('fromMap', () {
    test('reads the status, product and expiry off a subscriptions row', () {
      final status = PremiumStatus.fromMap(const {'status': 'active', 'product_id': 'vitta_premium_monthly', 'expires_at': '2099-01-15T00:00:00Z'});

      expect(status.status, SubscriptionStatus.active);
      expect(status.productId, 'vitta_premium_monthly');
      expect(status.expiresAt, isNotNull);
      expect(status.isActive, isTrue);
    });

    test('falls back to none for a status the app does not model', () {
      final status = PremiumStatus.fromMap(const {'status': 'something_new', 'product_id': 'x'});

      expect(status.status, SubscriptionStatus.none);
      expect(status.isActive, isFalse);
    });
  });
}
