plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dafalabs.motto"
    // Pinned above the Flutter template's default: flutter_secure_storage
    // compiles against 37 and refuses anything older. Raising it here rather
    // than pinning an older storage release, because the Keychain is where the
    // device identity has to live.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dafalabs.motto"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Two flavors so both can sit on one phone and neither can be mistaken for
    // the other. The suffix is what keeps their application ids apart; the app
    // name is what keeps them apart on the home screen.
    //
    // A manifest placeholder rather than resValue: custom resource values are a
    // build feature that is off by default, and turning it on for one string is
    // more machinery than the string is worth.
    flavorDimensions += "environment"

    productFlavors {
        create("stage") {
            dimension = "environment"
            applicationIdSuffix = ".stage"
            manifestPlaceholders["appName"] = "Motto Stage"
        }
        create("prod") {
            dimension = "environment"
            manifestPlaceholders["appName"] = "Motto"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
