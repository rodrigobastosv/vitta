import 'package:package_info_plus/package_info_plus.dart';

/// Thin adapter over `package_info_plus` so nothing above `core/services/`
/// imports the SDK — the `NotificationService`/`PurchaseService` boundary.
///
/// The figures it reports are the ones the release pipeline wrote into the
/// binary: the version name comes from the `vX.Y.Z` tag via `--build-name`, and
/// the build number from TestFlight's next build number (iOS) or the CI run
/// number (Android). That is the whole reason to show them — a tester reporting
/// a bug can say which build they are on, and the two pipelines number builds
/// differently, so the name alone does not identify one.
///
/// [init] is called once from `bootstrap`, like every other service's, so
/// [version] can be a plain synchronous getter: a version is a fact about the
/// running binary, not something a screen should await.
class AppInfoService {
  PackageInfo? _packageInfo;

  String get version => _packageInfo?.version ?? '';

  String get buildNumber => _packageInfo?.buildNumber ?? '';

  /// Empty until [init] has run, and on a platform that cannot answer — the
  /// caller renders nothing rather than a half-stated version.
  bool get isAvailable => version.isNotEmpty;

  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }
}
