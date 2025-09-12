# HealthBox ProGuard Rules

# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Flutter and Dart classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class androidx.lifecycle.** { *; }

# Keep Drift/SQLite classes
-keep class drift.** { *; }
-keep class moor.** { *; }
-keep class com.simolus.** { *; }
-keepclassmembers class * extends drift.GeneratedDatabase { *; }

# Keep SQLCipher classes for database encryption
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# Keep Google Drive API classes for sync functionality
-keep class com.google.api.** { *; }
-keep class com.google.auth.** { *; }
-keep class com.google.gson.** { *; }
-keep class com.google.api.client.** { *; }
-keep class com.google.api.services.** { *; }

# Keep Google Sign In classes
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }

# Keep ML Kit classes for OCR functionality
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }

# Keep notification classes
-keep class androidx.work.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# Keep file picker and image picker classes
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }

# Keep PDF generation classes
-keep class com.example.pdf.** { *; }
-keep class com.itextpdf.** { *; }

# Keep QR code generation classes
-keep class com.journeyapps.barcodescanner.** { *; }
-keep class com.google.zxing.** { *; }

# Keep chart library classes
-keep class com.github.mikephil.charting.** { *; }

# Keep shared preferences and secure storage
-keep class androidx.security.crypto.** { *; }
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep reflection-based serialization classes
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Remove debug logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Keep line numbers for debugging crashes
-keepattributes LineNumberTable,SourceFile
-renamesourcefileattribute SourceFile

# Optimization settings
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Medical data specific - keep model classes if using reflection
-keep class com.pranta.health_box.data.models.** { *; }
-keep class * extends drift.DataClass { *; }

# Keep custom exceptions
-keep public class * extends java.lang.Exception

# Keep Google Play Core classes (for app bundles)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep Google ML Kit Text Recognition classes
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# Keep Flutter deferred components classes
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }