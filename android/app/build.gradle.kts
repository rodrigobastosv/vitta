import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// key.properties (gitignored) points at the Play upload keystore + its passwords.
// Present only where a Play-billable build is produced (locally, or written from
// secrets in the Play CI lane) - absent for local `flutter run` and the Firebase
// lane, which fall back to debug signing below. See docs/play-store-setup.md.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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
        // up. Not a Play Store upload key - that is the `upload` config below.
        getByName("debug") {
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
        // The real Play upload key, kept out of the repo entirely (secrets/local file
        // via key.properties). Only wired up when that file exists; otherwise Gradle
        // never reads it and the release build falls back to debug signing below.
        create("upload") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // With an upload key present (Play lane) sign with it - the only signature
            // Play Billing serves products to. Without it (local `flutter run`, the
            // Firebase lane) fall back to the committed debug keystore's stable
            // signature, which is what Firebase in-place updates depend on.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("upload")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
