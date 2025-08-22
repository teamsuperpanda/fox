plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
import java.util.Properties
import java.io.FileInputStream

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

    // Load keystore properties from a file (try 'key.properties' or 'keystore.properties')
    // or from environment variables. This mirrors common Flutter project conventions
    // (some projects use 'key.properties'). CI (Codemagic) should provide either
    // a properties file or environment variables.
    val possibleProps = listOf("key.properties", "keystore.properties")
    val keystoreProperties = Properties()
    val keystorePropertiesFile = possibleProps.map { rootProject.file(it) }.firstOrNull { it.exists() }
    if (keystorePropertiesFile != null) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    fun prop(key: String): String? {
        val fromFile = if (keystoreProperties.isEmpty) null else keystoreProperties.getProperty(key)
        if (!fromFile.isNullOrBlank()) return fromFile
        // Try environment variables with uppercase names
        val envKey = System.getenv(key.uppercase())
        if (!envKey.isNullOrBlank()) return envKey
        return null
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
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Create a release signing config which prefers a keystore file referenced in
    // keystore.properties or via environment variables. Example keys in
    // keystore.properties: storeFile=upload-keystore.jks
    // storePassword=...
    // keyAlias=...
    // keyPassword=...
    signingConfigs {
        create("release") {
            // Prefer explicit configuration via properties file or environment variables.
            // Do NOT implicitly pick up a repo-stored upload-keystore.jks unless it is
            // explicitly referenced via storeFile / KEYSTORE_PATH. This avoids signing
            // with the wrong key accidentally.
            val storeFilePath = prop("storeFile") ?: prop("KEYSTORE_PATH")

            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }

            val storePwd = prop("storePassword") ?: prop("KEYSTORE_PASSWORD")
            val alias = prop("keyAlias") ?: prop("KEY_ALIAS")
            val keyPwd = prop("keyPassword") ?: prop("KEY_PASSWORD")

            if (storePwd != null) storePassword = storePwd
            if (alias != null) keyAlias = alias
            if (keyPwd != null) keyPassword = keyPwd
        }
    }

    buildTypes {
        release {
            // Use the release signing config only when key properties or env vars are
            // provided; otherwise fall back to debug signing (local dev). This prevents
            // accidental use of an unchecked repo keystore.
            val envKeystore = System.getenv("KEYSTORE_PATH")
            val propsFileExists = possibleProps.map { rootProject.file(it) }.any { it.exists() }

            signingConfig = if (envKeystore != null || propsFileExists) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
