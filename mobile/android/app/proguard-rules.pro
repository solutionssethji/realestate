# ProGuard / R8 rules for Elysium Real Estate
# ─────────────────────────────────────────────────────────────────────────────
# Flutter rules are handled by the Flutter Gradle plugin.
# These rules cover Firebase and other critical libraries.

# ── Firebase ─────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── Kotlin ───────────────────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**

# ── Razorpay / Payment SDK (add specific rules when integrating real SDK) ────
# -keep class com.razorpay.** { *; }

# ── Google Maps ──────────────────────────────────────────────────────────────
-keep class com.google.maps.** { *; }

# ── Suppress common harmless warnings ────────────────────────────────────────
-dontwarn javax.annotation.**
-dontwarn org.jetbrains.annotations.**
