plugins {
    id("com.android.application")
    id("kotlin-android")
    id("org.jetbrains.kotlin.plugin.compose")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bhs.mkeyboard"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.bhs.mkeyboard"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    buildFeatures {
        compose = true
    }

    dependencies {
        implementation("androidx.multidex:multidex:2.0.1")
        implementation("androidx.work:work-runtime-ktx:2.9.0")
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
        
        // Jetpack Compose
        implementation(platform("androidx.compose:compose-bom:2024.02.00"))
        implementation("androidx.compose.ui:ui")
        implementation("androidx.compose.ui:ui-graphics")
        implementation("androidx.compose.ui:ui-tooling-preview")
        implementation("androidx.compose.material3:material3")
        implementation("androidx.activity:activity-compose:1.8.2")
        implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
        implementation("androidx.lifecycle:lifecycle-service:2.7.0")
        implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
        debugImplementation("androidx.compose.ui:ui-tooling")
        
        // Emoji Picker
        implementation("androidx.emoji2:emoji2-emojipicker:1.0.0-alpha03")
    }
}

flutter {
    source = "../.."
}
