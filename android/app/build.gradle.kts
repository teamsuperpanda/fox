plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
import java.util.Properties
import java.io.FileInputStream

// Load keystore properties from a gitignored properties file (key.properties,
// keystore.properties or local.properties) or from environment variables.
// Signing values are never committed.
val possibleProps = listOf("key.properties", "keystore.properties", "local.properties")
val keystoreProperties = Properties()
val keystorePropertiesFile = possibleProps.map { rootProject.file(it) }.firstOrNull { it.exists() }
if (keystorePropertiesFile != null) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun prop(key: String): String? {
    val fromFile = if (keystoreProperties.isEmpty) null else keystoreProperties.getProperty(key)
    if (!fromFile.isNullOrBlank()) return fromFile
    val envKey = System.getenv(key.uppercase())
    if (!envKey.isNullOrBlank()) return envKey
    return null
}

val releaseStoreFile = prop("storeFile") ?: prop("KEYSTORE_PATH")
val releaseStorePassword = prop("storePassword") ?: prop("KEYSTORE_PASSWORD")
val releaseKeyAlias = prop("keyAlias") ?: prop("KEY_ALIAS")
val releaseKeyPassword = prop("keyPassword") ?: prop("KEY_PASSWORD")
val hasReleaseSigning = releaseStoreFile != null &&
    releaseStorePassword != null &&
    releaseKeyAlias != null &&
    releaseKeyPassword != null

android {
    namespace = "com.teamsuperpanda.fox"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID for publishing
        applicationId = "com.teamsuperpanda.fox"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Only used when every value is present. No repo keystore is picked
            // up implicitly and the debug key is never used for a release.
            if (hasReleaseSigning) {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        // Single release block. There used to be two; the first silently signed
        // release builds with the debug key.
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

// Fail a release build without a keystore instead of producing an AAB that
// Play rejects, and do it only when a release task actually runs so debug
// builds still work without signing secrets.
tasks.matching {
    it.name == "bundleRelease" || it.name == "assembleRelease"
}.configureEach {
    doFirst {
        if (!hasReleaseSigning) {
            throw GradleException(
                "Release signing is not configured. Add storeFile, storePassword, " +
                    "keyAlias and keyPassword to android/key.properties (gitignored), " +
                    "or set KEYSTORE_PATH, KEYSTORE_PASSWORD, KEY_ALIAS and KEY_PASSWORD. " +
                    "See docs/ANDROID_SIGNING.md."
            )
        }
    }
}
