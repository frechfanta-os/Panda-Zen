import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val releaseKeystoreFile = System.getenv("KEYSTORE_PATH")?.let { file(it) }
    ?: keystoreProperties.getProperty("storeFile")?.let { file(it) }

val releaseStorePassword = System.getenv("KEYSTORE_PASSWORD")
    ?: keystoreProperties.getProperty("storePassword")

val releaseKeyAlias = System.getenv("KEY_ALIAS")
    ?: keystoreProperties.getProperty("keyAlias")

val releaseKeyPassword = System.getenv("KEY_PASSWORD")
    ?: keystoreProperties.getProperty("keyPassword")

val isReleaseSigningConfigured = releaseKeystoreFile != null
    && releaseKeystoreFile.exists()
    && !releaseStorePassword.isNullOrBlank()
    && !releaseKeyAlias.isNullOrBlank()
    && !releaseKeyPassword.isNullOrBlank()

android {
    namespace = "com.ghdinteractivestudio.pandazen"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.ghdinteractivestudio.pandazen"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (isReleaseSigningConfigured) {
                storeFile = releaseKeystoreFile
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (isReleaseSigningConfigured) {
                println("[Panda Zen Gradle] Configured RELEASE SIGNING with production keystore: ${releaseKeystoreFile?.name}")
                signingConfig = signingConfigs.getByName("release")
            } else {
                println("[Panda Zen Gradle] Production signing not configured. Falling back to DEBUG SIGNING for development/CI preview.")
                signingConfig = signingConfigs.getByName("debug")
            }
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
