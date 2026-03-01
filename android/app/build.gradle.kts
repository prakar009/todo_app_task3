plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services Plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.lmg.todo_app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        // FIXED: Java 8 features aur Desugaring enable ki gayi hai
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // FIXED: JVM target ko Java 8/1.8 par rakha hai compatibility ke liye
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.lmg.todo_app"
        // minSdk 21 ya usse upar hona chahiye notifications ke liye
        minSdk = 23 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // FIXED: Multidex enable kiya gaya hai
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // FIXED: Core Library Desugaring dependency add ki gayi hai
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase BoM aur Messaging
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("com.google.firebase:firebase-messaging")
}