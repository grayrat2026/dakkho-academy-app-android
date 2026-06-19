package himadri.dakkho.pro.bd

import android.os.Build
import android.content.Context

/**
 * DeviceInfoHelper — returns structured device info for /api/device/bind payload.
 *
 * Sent to server on every login so the Settings → Active Devices page can show
 * "Samsung Galaxy A54, Android 14, App v1.0.0".
 */
object DeviceInfoHelper {

    fun get(context: Context): Map<String, String> {
        return mapOf(
            "deviceName" to "${Build.MANUFACTURER} ${Build.MODEL}",
            "deviceModel" to Build.MODEL,
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT.toString(),
            "manufacturer" to Build.MANUFACTURER,
            "brand" to Build.BRAND,
            "appFlavor" to getAppFlavor(context),
            "osLanguage" to java.util.Locale.getDefault().toLanguageTag()
        )
    }

    /**
     * Get the build flavor (dev/staging/prod) from BuildConfig.
     * Required because product flavors change the applicationId, but we want
     * to send the flavor name to the server for analytics.
     */
    private fun getAppFlavor(context: Context): String {
        return try {
            // Read from the applicationId suffix
            val appId = context.packageName
            when {
                appId.endsWith(".dev") -> "dev"
                appId.endsWith(".staging") -> "staging"
                appId.endsWith(".debug") -> "debug"
                appId.endsWith(".profile") -> "profile"
                else -> "prod"
            }
        } catch (e: Exception) {
            "unknown"
        }
    }
}
