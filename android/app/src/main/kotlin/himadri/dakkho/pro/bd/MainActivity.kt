package himadri.dakkho.pro.bd

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * DAKKHO Academy — Main Activity
 *
 * Key responsibilities:
 *   1. FLAG_SECURE — blocks screenshots (Power+VolDown), adb screencap, screen recording apps.
 *      Critical for video content protection. Set on onCreate + onWindowFocusChanged
 *      because some OEMs (Xiaomi, Oppo) strip FLAG_SECURE on focus changes.
 *
 *   2. Method channel "dakkho/native" — exposes native Android capabilities to Flutter:
 *      - getFlagSecure(): returns current state
 *      - setFlagSecure(enabled): toggle at runtime (e.g. disabled on Settings page if user wants)
 *      - getKeystoreAlias(alias): generates/retrieves app-generated device UUID from Keystore
 *      - secureWipe(path): secure delete (overwrite + delete) for downloaded videos
 *
 *   3. Single-task launch mode (in manifest) — ensures deep links reopen existing instance
 *      rather than spawning a new one.
 */
class MainActivity : FlutterActivity() {

    private val CHANNEL = "dakkho/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getFlagSecure" -> {
                    val flags = window.attributes.flags
                    val isSecure = (flags and WindowManager.LayoutParams.FLAG_SECURE) != 0
                    result.success(isSecure)
                }
                "setFlagSecure" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    if (enabled) {
                        window.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE
                        )
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(true)
                }
                "getDeviceUuid" -> {
                    val uuid = DeviceUuidHelper.get(this)
                    result.success(uuid)
                }
                "getDeviceInfo" -> {
                    val info = DeviceInfoHelper.get(this)
                    result.success(info)
                }
                "secureWipe" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        val success = SecureWipeHelper.wipe(path)
                        result.success(success)
                    } else {
                        result.error("INVALID_PATH", "path is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ─── FLAG_SECURE — block screenshots + screen recording ───
        // Critical for video content protection.
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)

        // Re-apply FLAG_SECURE on focus change — some OEMs (Xiaomi, Oppo) strip it
        // when the app goes into PiP mode or split-screen.
        if (hasFocus) {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
        }
    }
}
