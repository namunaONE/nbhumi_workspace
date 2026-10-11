plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nbhumi.user_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nbhumi.user_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release signing config — enabled when releaseKeystore properties are set
    // (injected via GitHub Actions secrets in release workflow).
    // See .github/workflows/release-apk.yml.
    val releaseKeystoreFile = project.findProperty("releaseKeystoreFile") as String?
    val releaseKeystorePassword = project.findProperty("releaseKeystorePassword") as String?
    val releaseKeyAlias = project.findProperty("releaseKeyAlias") as String?
    val releaseKeyPassword = project.findProperty("releaseKeyPassword") as String?
    val hasReleaseKeystore = releaseKeystoreFile != null &&
        releaseKeystorePassword != null &&
        releaseKeyAlias != null &&
        releaseKeyPassword != null

    if (hasReleaseKeystore) {
        signingConfigs {
            create("release") {
                storeFile = file(releaseKeystoreFile)
                storePassword = releaseKeystorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Fallback to debug signing for local/dev builds without keystore
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }

    // HYA-239: one flavor per backend. The flavor selects the *native*
    // identity (applicationId, display name) so dev/staging/prod install
    // side-by-side; the Dart side selects its backend via
    // `--dart-define=ENVIRONMENT=<flavor>` (see Makefile app-dev/app-staging/
    // app-prod and EnvConfig). Keep the flavor name identical to the
    // ENVIRONMENT value or logging/config will disagree with the icon.
    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["appName"] = "nBhumi Dev"
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            manifestPlaceholders["appName"] = "nBhumi Staging"
        }
        create("prod") {
            dimension = "environment"
            manifestPlaceholders["appName"] = "nBhumi"
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
