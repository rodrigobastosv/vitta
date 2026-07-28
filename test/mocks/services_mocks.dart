import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/services/analytics/analytics_service.dart';
import 'package:vitta/app/core/services/app_info/app_info_service.dart';
import 'package:vitta/app/core/services/cache/wire_cache_service.dart';
import 'package:vitta/app/core/services/health/health_service.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_service.dart';
import 'package:vitta/app/core/services/logging/log_destination.dart';
import 'package:vitta/app/core/services/logging/logging_service.dart';
import 'package:vitta/app/core/services/notifications/notification_service.dart';
import 'package:vitta/app/core/services/purchases/purchase_service.dart';
import 'package:vitta/app/core/services/supabase/realtime_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class MockRealtimeService extends Mock implements RealtimeService {}

class MockWireCacheService extends Mock implements WireCacheService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockAppInfoService extends Mock implements AppInfoService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockImagePickerService extends Mock implements ImagePickerService {}

class MockHealthService extends Mock implements HealthService {}

class MockLoggingService extends Mock implements LoggingService {}

class MockLogDestination extends Mock implements LogDestination {}

class MockPurchaseService extends Mock implements PurchaseService {}
