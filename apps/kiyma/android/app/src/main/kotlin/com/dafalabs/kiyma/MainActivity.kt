package com.dafalabs.kiyma

import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity

/**
 * The counter is drawn edge to edge, so the system bars are hidden here
 * rather than from Dart.
 *
 * `SystemChrome.setEnabledSystemUIMode(immersiveSticky)` stopped hiding
 * anything once the app targeted SDK 36: the platform removed that opt-out,
 * not the underlying controller. Without this the status clock and the
 * gesture handle sit on top of the kitchen.
 */
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        goImmersive()
    }

    /** Re-applied on focus, so a transient swipe does not leave them up. */
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) goImmersive()
    }

    private fun goImmersive() {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        WindowInsetsControllerCompat(window, window.decorView).apply {
            hide(WindowInsetsCompat.Type.systemBars())
            systemBarsBehavior =
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
    }
}
