import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun resolveGoogleMapsApiKey(): String {
    System.getenv("GOOGLE_MAPS_API_KEY")?.trim()?.takeIf { it.isNotEmpty() }?.let { return it }

    val secretsFile = rootProject.file("secrets.properties")
    if (!secretsFile.exists()) {
        error(
            """
            |
            |GOOGLE_MAPS_API_KEY is not configured.
            |
            |  1. cp android/secrets.properties.example android/secrets.properties
            |  2. Set GOOGLE_MAPS_API_KEY in android/secrets.properties
            |
            |Or export GOOGLE_MAPS_API_KEY (for CI).
            |
            """.trimMargin(),
        )
    }

    val secretsProperties = Properties()
    secretsFile.inputStream().use { secretsProperties.load(it) }
    val key = secretsProperties.getProperty("GOOGLE_MAPS_API_KEY")?.trim().orEmpty()
    if (key.isEmpty() || key == "YOUR_GOOGLE_MAPS_API_KEY_HERE") {
        error(
            """
            |
            |GOOGLE_MAPS_API_KEY is missing or still set to the placeholder.
            |Edit android/secrets.properties with your Maps SDK for Android key.
            |
            """.trimMargin(),
        )
    }
    return key
}

val googleMapsApiKey = resolveGoogleMapsApiKey()

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.ezzcode.nabdh_alyaman"
    compileSdk = 36
    ndkVersion = "29.0.13846066"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            if (!storeFilePath.isNullOrBlank()) {
                storeFile = file(storeFilePath)
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.ezzcode.nabdh_alyaman"
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = 35
        multiDexEnabled = true
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
    }

    buildTypes {
        getByName("release") {
            // استخدم توقيع release (وليس debug)
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.4"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("com.google.android.gms:play-services-base:18.2.0")
}
