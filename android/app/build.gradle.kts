plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rodrigobastosv.vitta"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications' zonedSchedule needs java.time backported on older APIs.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.rodrigobastosv.vitta"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Health Connect requires API 26+; take the higher of Flutter's default and 26.
        minSdk = maxOf(flutter.minSdkVersion, 26)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Point the debug config at a keystore committed to the repo (debug.keystore,
        // with the well-known public `android` password - nothing secret). Distributing
        // via Firebase App Distribution needs the signature to be stable across builds,
        // and CI runners otherwise auto-generate a fresh debug keystore per run, whose
        // changing signature makes Android reject in-place updates. A committed keystore
        // gives every build - local and CI - the same signature, with no secrets to wire
        // up. Not a Play Store upload key: set one up if a Play pipeline is ever added.
        getByName("debug") {
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            // Signed with the committed debug keystore (see signingConfigs above) so
            // `flutter run --release` and the Firebase build share one stable signature.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
