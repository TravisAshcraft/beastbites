plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.beast_bites"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    // ➌ Enable Java 8+ compatibility and core-library desugaring:
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8

        // This flag is necessary so that libraries using Java 8+ APIs get “desugared” down
        // to code Android 5.0+ can run:
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.beast_bites"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // ➍ Add the desugaring dependency under dependencies { … }:
    dependencies {
        implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.0")
        implementation("androidx.core:core-ktx:1.9.0")
        implementation("androidx.appcompat:appcompat:1.6.1")
        implementation("com.google.android.material:material:1.8.0")
        implementation("androidx.constraintlayout:constraintlayout:2.1.4")

        // Flutter plugins (these will be generated in your pubspec → .gradle files, e.g. flutter_local_notifications, sqflite_android, etc.)
        // For example (you do not need to add these manually; they will get pulled in when you flutter pub get):
        //
        // implementation("com.github.dexterous:adapter:1.0.0")  // placeholder
        // implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0") // etc.

        // ➎ **Core-library desugaring** dependency (must match compileOptions above):
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    }
}

flutter {
    source = "../.."
}
