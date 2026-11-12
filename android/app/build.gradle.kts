plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kharchatrack"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.kharchatrack.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("KHARCHATRACK_KEYSTORE_PATH")
                ?: throw GradleException("Missing KHARCHATRACK_KEYSTORE_PATH")
            storeFile = file(keystorePath)
            storePassword = System.getenv("KHARCHATRACK_KEYSTORE_PASSWORD")
                ?: throw GradleException("Missing KHARCHATRACK_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KHARCHATRACK_KEY_ALIAS")
                ?: throw GradleException("Missing KHARCHATRACK_KEY_ALIAS")
            keyPassword = System.getenv("KHARCHATRACK_KEY_PASSWORD")
                ?: throw GradleException("Missing KHARCHATRACK_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
