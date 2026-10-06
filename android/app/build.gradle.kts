import java.text.SimpleDateFormat
import java.util.Date
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.polymap.android"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.polymap.android"
        minSdk = 26
        targetSdk = 35
        versionCode = 6
        versionName = "1.1.1"
        buildConfigField("String", "BUILD_TIME", "\"" + SimpleDateFormat("yyyy-MM-dd HH:mm").format(Date()) + "\"")
        vectorDrawables.useSupportLibrary = true
    }

    buildTypes {
        debug { buildConfigField("boolean", "CRASH_SCREEN", "true") }
        release {
            buildConfigField("boolean", "CRASH_SCREEN", "false")
            isMinifyEnabled = false
        }
    }
    flavorDimensions += "renderer"
    productFlavors {
        create("gl") { dimension = "renderer" }
        create("vulkan") { dimension = "renderer"; versionNameSuffix = "-vulkan" }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
    buildFeatures {
        compose = true
        buildConfig = true
    }
    testOptions {
        unitTests.isReturnDefaultValues = true
    }
    packaging {
        resources.excludes += setOf("META-INF/AL2.0", "META-INF/LGPL2.1")
    }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2025.09.00")
    implementation(composeBom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.activity:activity-compose:1.11.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.9.4")

    implementation("androidx.core:core-ktx:1.17.0")
    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.recyclerview:recyclerview:1.4.0")
    implementation("androidx.dynamicanimation:dynamicanimation:1.1.0")
    implementation("androidx.fragment:fragment-ktx:1.8.9")
    implementation("com.google.android.material:material:1.14.0")
    implementation("androidx.constraintlayout:constraintlayout:2.2.1")

    "glImplementation"("org.maplibre.gl:android-sdk-opengl:13.6.1")
    "vulkanImplementation"("org.maplibre.gl:android-sdk-vulkan:13.6.1")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.google.code.gson:gson:2.13.2")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")

    testImplementation("junit:junit:4.13.2")
}
