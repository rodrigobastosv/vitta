import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/services/health/health_service.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_service.dart';
import 'package:vitta/app/core/services/logging/log_destination.dart';
import 'package:vitta/app/core/services/logging/logging_service.dart';
import 'package:vitta/app/core/services/notifications/notification_service.dart';
import 'package:vitta/app/core/services/purchases/purchase_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockImagePickerService extends Mock implements ImagePickerService {}

class MockHealthService extends Mock implements HealthService {}

class MockLoggingService extends Mock implements LoggingService {}

class MockLogDestination extends Mock implements LogDestination {}

class MockPurchaseService extends Mock implements PurchaseService {}
