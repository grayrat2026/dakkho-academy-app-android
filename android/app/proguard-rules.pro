# DAKKHO Academy — ProGuard / R8 Rules

# ─── Flutter / Dart ───
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# ─── media_kit / ExoPlayer / LibMPV ───
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }
-keep class org.libmpv.** { *; }
-dontwarn org.libmpv.**

# ─── Firebase / FCM ───
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**

# ─── Hive (Local DB) ───
-keep class org.apache.commons.codec.** { *; }
-keep class com.github.davidmotson.** { *; }
-dontwarn org.apache.commons.**

# ─── Riverpod / Freezed / JSON Serialization (reflection-free, but generated classes need keeping) ───
-keep class com.dakkho.** { *; }
-keep class himadri.dakkho.pro.bd.** { *; }

# ─── Dio HTTP client ───
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# ─── FlutterSecureStorage (uses Android Keystore) ───
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ─── Lottie animations ───
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**

# ─── Sentry (error tracking) ───
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# ─── Native libraries (.so files) ───
-keepclasseswithmembernames class * {
    native <methods>;
}
