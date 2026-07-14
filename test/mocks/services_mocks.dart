import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_service.dart';
import 'package:vitta/app/core/services/logging/log_destination.dart';
import 'package:vitta/app/core/services/logging/logging_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class MockImagePickerService extends Mock implements ImagePickerService {}


class MockLoggingService extends Mock implements LoggingService {}

class MockLogDestination extends Mock implements LogDestination {}
