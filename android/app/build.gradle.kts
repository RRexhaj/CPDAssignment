buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("com.google.gms:google-services:4.3.15") // Add this line
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Apply Firebase plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cpdassignmentrei"
    compileSdk = flutter.compileSdkVersion

    // Set the required NDK version explicitly
    ndkVersion = "29.0.13113456"

    compileOptions {
        // Enable Java 8 features
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true // Enable desugaring
    }

    kotlinOptions {
        // Set JVM target to 1.8 for Kotlin
        jvmTarget = "1.8"
    }

    defaultConfig {
        // Specify your unique Application ID
        applicationId = "com.example.cpdassignmentrei"
        // Update these values to match your application needs
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // Enable multidex if your app exceeds the 64K method limit
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5") // Updated version
}
