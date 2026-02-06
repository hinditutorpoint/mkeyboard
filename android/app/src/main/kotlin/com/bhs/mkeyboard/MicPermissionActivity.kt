package com.bhs.mkeyboard

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat

/**
 * Transparent activity that requests microphone permission.
 * IME services cannot request permissions directly — they need an Activity.
 * This activity is transparent, requests the permission, and finishes immediately.
 */
class MicPermissionActivity : ComponentActivity() {

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            Toast.makeText(this, "Microphone enabled! Tap 🎤 again.", Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(this, "Microphone permission denied", Toast.LENGTH_SHORT).show()
        }
        finish()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (ContextCompat.checkSelfPermission(
                this, Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            // Already granted
            Toast.makeText(this, "Microphone already enabled!", Toast.LENGTH_SHORT).show()
            finish()
            return
        }

        // Request permission
        requestPermissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
    }
}