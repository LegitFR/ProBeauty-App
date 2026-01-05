# -------------------------------------------------
# Stripe SDK – required to prevent R8 stripping
# -------------------------------------------------

-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Push Provisioning (not used but referenced)
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }

# Kotlin metadata (required for Stripe)
-keep class kotlin.Metadata { *; }

# Flutter Stripe specific
-keep class com.flutter.stripe.** { *; }
-dontwarn com.flutter.stripe.**
