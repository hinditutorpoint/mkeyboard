package com.bhs.mkeyboard.keyboard

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke

/**
 * Draws the glide trail path on top of the keyboard.
 */
@Composable
fun GlideTrailCanvas(
    trailPoints: List<GlideTypingDetector.GlidePoint>,
    trailColor: Color,
    modifier: Modifier = Modifier
) {
    if (trailPoints.size < 2) return

    Canvas(modifier = modifier.fillMaxSize()) {
        val path = Path()
        val firstPoint = trailPoints.first()
        path.moveTo(firstPoint.x, firstPoint.y)

        // Use quadratic bezier curves for smooth trail
        for (i in 1 until trailPoints.size) {
            val prev = trailPoints[i - 1]
            val curr = trailPoints[i]

            // Midpoint for smooth curve
            val midX = (prev.x + curr.x) / 2f
            val midY = (prev.y + curr.y) / 2f

            path.quadraticBezierTo(prev.x, prev.y, midX, midY)
        }

        // Draw to the last point
        val lastPoint = trailPoints.last()
        path.lineTo(lastPoint.x, lastPoint.y)

        drawPath(
            path = path,
            color = trailColor.copy(alpha = 0.6f),
            style = Stroke(
                width = 6f,
                cap = StrokeCap.Round,
                join = StrokeJoin.Round
            )
        )

        // Draw dot at current position
        drawCircle(
            color = trailColor,
            radius = 8f,
            center = Offset(lastPoint.x, lastPoint.y)
        )
    }
}