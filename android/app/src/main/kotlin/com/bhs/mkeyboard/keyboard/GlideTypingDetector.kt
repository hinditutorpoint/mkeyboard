package com.bhs.mkeyboard.keyboard

import android.util.Log
import androidx.compose.ui.geometry.Offset
import kotlin.math.abs
import kotlin.math.sqrt

class GlideTypingDetector {

    companion object {
        private const val TAG = "GlideTyping"
        private const val MIN_GLIDE_DISTANCE = 20f // Minimum pixels to count as movement
        private const val SAMPLE_INTERVAL_MS = 16L // ~60fps sampling
    }

    data class KeyPosition(
        val key: String,
        val centerX: Float,
        val centerY: Float,
        val width: Float,
        val height: Float
    )

    data class GlidePoint(
        val x: Float,
        val y: Float,
        val timestamp: Long
    )

    private val tracePath = mutableListOf<GlidePoint>()
    private val visitedKeys = mutableListOf<String>()
    private var keyPositions = listOf<KeyPosition>()
    private var isGliding = false
    private var lastSampleTime = 0L

    fun setKeyPositions(positions: List<KeyPosition>) {
        keyPositions = positions
    }

    fun onGlideStart(x: Float, y: Float) {
        tracePath.clear()
        visitedKeys.clear()
        isGliding = true
        lastSampleTime = System.currentTimeMillis()

        val point = GlidePoint(x, y, lastSampleTime)
        tracePath.add(point)

        // Find starting key
        findKeyAt(x, y)?.let { key ->
            visitedKeys.add(key)
        }

        Log.d(TAG, "Glide started at ($x, $y)")
    }

    fun onGlideMove(x: Float, y: Float) {
        if (!isGliding) return

        val now = System.currentTimeMillis()
        if (now - lastSampleTime < SAMPLE_INTERVAL_MS) return
        lastSampleTime = now

        val lastPoint = tracePath.lastOrNull() ?: return
        val dist = distance(lastPoint.x, lastPoint.y, x, y)

        if (dist > MIN_GLIDE_DISTANCE) {
            tracePath.add(GlidePoint(x, y, now))

            // Check if we entered a new key
            findKeyAt(x, y)?.let { key ->
                if (visitedKeys.isEmpty() || visitedKeys.last() != key) {
                    visitedKeys.add(key)
                }
            }
        }
    }

    fun onGlideEnd(): String {
        isGliding = false

        if (visitedKeys.size <= 1) {
            // Not a glide — just a tap
            Log.d(TAG, "Not a glide (only ${visitedKeys.size} keys)")
            tracePath.clear()
            visitedKeys.clear()
            return ""
        }

        val keySequence = visitedKeys.joinToString("")
        Log.d(TAG, "Glide path: $keySequence (${visitedKeys.size} keys)")

        tracePath.clear()
        val result = keySequence
        visitedKeys.clear()
        return result
    }

    fun getTracePath(): List<GlidePoint> {
        return tracePath.toList()
    }

    fun isCurrentlyGliding(): Boolean = isGliding

    fun cancelGlide() {
        isGliding = false
        tracePath.clear()
        visitedKeys.clear()
    }

    private fun findKeyAt(x: Float, y: Float): String? {
        return keyPositions.find { pos ->
            val halfW = pos.width / 2f
            val halfH = pos.height / 2f
            x >= pos.centerX - halfW &&
            x <= pos.centerX + halfW &&
            y >= pos.centerY - halfH &&
            y <= pos.centerY + halfH
        }?.key
    }

    private fun distance(x1: Float, y1: Float, x2: Float, y2: Float): Float {
        val dx = x2 - x1
        val dy = y2 - y1
        return sqrt(dx * dx + dy * dy)
    }
}