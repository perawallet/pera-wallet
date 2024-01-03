/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.customviews

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.graphics.PointF
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.view.View
import com.google.android.material.imageview.ShapeableImageView
import kotlin.math.abs
import kotlin.math.roundToInt

@Suppress("detekt.NestedBlockDepth")
class ZoomShapeableImageView(context: Context, attrs: AttributeSet) :
    ShapeableImageView(context, attrs),
    View.OnTouchListener {

    private val calculationMatrix: Matrix = Matrix()

    private enum class Mode {
        NONE, DRAG, ZOOM
    }

    private var mode = Mode.NONE

    private val last = PointF()
    private val start = PointF()

    private val matrixBounds = FloatArray(MATRIX_SIZE) { 0f }

    private var redundantXSpace = 0f
    private var redundantYSpace = 0f

    private var viewWidth = 0
    private var viewHeight = 0
    private var saveScale = 1f
    private var right = 0f
    private var bottom = 0f
    private var originalWidth = 0f
    private var originalHeight = 0f
    private var bitmapWidth = 0
    private var bitmapHeight = 0

    private val scaleDetector = ScaleGestureDetector(context, ScaleListener())

    init {
        calculationMatrix.setTranslate(1f, 1f)
        imageMatrix = calculationMatrix
        scaleType = ScaleType.MATRIX
    }

    override fun onTouch(v: View?, event: MotionEvent): Boolean {
        scaleDetector.onTouchEvent(event)
        calculationMatrix.getValues(matrixBounds)
        val x = matrixBounds[Matrix.MTRANS_X]
        val y = matrixBounds[Matrix.MTRANS_Y]
        val curr = PointF(event.x, event.y)

        onEventAction(event = event, curr = curr, y = y, x = x)
        imageMatrix = calculationMatrix
        invalidate()
        return true
    }

    private fun onEventAction(
        event: MotionEvent,
        curr: PointF,
        y: Float,
        x: Float
    ) {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                onEventActionDown(event)
            }
            MotionEvent.ACTION_MOVE -> {
                when (mode) {
                    Mode.DRAG -> onActionMoveDrag(curr, y, x)
                    else -> {}
                }
            }
            MotionEvent.ACTION_UP -> {
                onEventActionUp(curr)
            }
            MotionEvent.ACTION_POINTER_UP -> {
                mode = Mode.NONE
            }
        }
    }

    private fun onActionMoveDrag(curr: PointF, y: Float, x: Float) {
        var deltaX = curr.x - last.x
        var deltaY = curr.y - last.y
        val scaleWidth = (originalWidth * saveScale).roundToInt()
        val scaleHeight = (originalHeight * saveScale).roundToInt()

        when {
            scaleWidth < viewWidth -> {
                deltaX = 0f
                if (y + deltaY > 0)
                    deltaY = -y
                else if (y + deltaY < -bottom)
                    deltaY = -(y + bottom)
            }
            scaleHeight < viewHeight -> {
                deltaY = 0f
                if (x + deltaX > 0)
                    deltaX = -x
                else if (x + deltaX < -right)
                    deltaX = -(x + right)
            }
            else -> {
                if (x + deltaX > 0)
                    deltaX = -x
                else if (x + deltaX < -right)
                    deltaX = -(x + right)
                if (y + deltaY > 0)
                    deltaY = -y
                else if (y + deltaY < -bottom)
                    deltaY = -(y + bottom)
            }
        }
        calculationMatrix.postTranslate(deltaX, deltaY)
        last.set(curr.x, curr.y)
    }

    private fun onEventActionUp(curr: PointF) {
        mode = Mode.NONE
        val xDiff = abs(curr.x - start.x).toInt()
        val yDiff = abs(curr.y - start.y).toInt()
        if (xDiff < CLICK && yDiff < CLICK)
            performClick()
    }

    private fun onEventActionDown(event: MotionEvent) {
        last.set(event.x, event.y)
        start.set(last)
        mode = Mode.DRAG
    }

    override fun setImageBitmap(bitmap: Bitmap?) {
        super.setImageBitmap(bitmap)
        bitmap?.let {
            bitmapWidth = it.width
            bitmapHeight = it.height
            setOnTouchListener(this)
        }
    }

    override fun setImageDrawable(drawable: Drawable?) {
        super.setImageDrawable(drawable)
        drawable?.let {
            bitmapWidth = it.minimumWidth
            bitmapHeight = it.minimumHeight
            setOnTouchListener(this)
        }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        viewWidth = MeasureSpec.getSize(widthMeasureSpec)
        viewHeight = MeasureSpec.getSize(heightMeasureSpec)

        val scaleX = viewWidth.toFloat() / bitmapWidth.toFloat()
        val scaleY = viewHeight.toFloat() / bitmapHeight.toFloat()
        val scale = scaleX.coerceAtMost(scaleY)
        calculationMatrix.setScale(scale, scale)
        imageMatrix = calculationMatrix
        saveScale = 1f

        redundantXSpace = viewWidth.toFloat() - (scale * bitmapWidth.toFloat())
        redundantXSpace /= 2f
        redundantYSpace = viewHeight.toFloat() - (scale * bitmapHeight.toFloat())
        redundantYSpace /= 2f

        calculationMatrix.postTranslate(redundantXSpace, redundantYSpace)
        originalWidth = viewWidth - 2 * redundantXSpace
        originalHeight = viewHeight - 2 * redundantYSpace

        right = viewWidth * saveScale - viewWidth - (2 * redundantXSpace * saveScale)
        bottom = viewHeight * saveScale - viewHeight - (2 * redundantYSpace * saveScale)
        imageMatrix = calculationMatrix
    }

    private inner class ScaleListener : ScaleGestureDetector.SimpleOnScaleGestureListener() {
        override fun onScaleBegin(detector: ScaleGestureDetector): Boolean {
            mode = Mode.ZOOM
            return true
        }

        override fun onScale(detector: ScaleGestureDetector): Boolean {
            var scaleFactor = MIN_SCALE_FACTOR.coerceAtLeast(detector.scaleFactor).coerceAtMost(MAX_SCALE_FACTOR)
            val originalScale = saveScale
            saveScale *= scaleFactor
            if (saveScale > MAX_SCALE) {
                saveScale = MAX_SCALE
                scaleFactor = MAX_SCALE / originalScale
            } else if (saveScale < MIN_SCALE) {
                saveScale = MIN_SCALE
                scaleFactor = MIN_SCALE / originalScale
            }
            right = viewWidth * saveScale - viewWidth - (2 * redundantXSpace * saveScale)
            bottom = viewHeight * saveScale - viewHeight - (2 * redundantYSpace * saveScale)

            if (originalWidth * saveScale <= viewWidth || originalHeight * saveScale <= viewHeight) {
                calculationMatrix.postScale(
                    scaleFactor,
                    scaleFactor,
                    (viewWidth / 2).toFloat(),
                    (viewHeight / 2).toFloat()
                )
                if (scaleFactor < 1) {
                    calculationMatrix.getValues(matrixBounds)
                    val x = matrixBounds[Matrix.MTRANS_X]
                    val y = matrixBounds[Matrix.MTRANS_Y]
                    if ((originalWidth * saveScale).roundToInt() < viewWidth) {
                        if (y < -bottom)
                            calculationMatrix.postTranslate(0f, -(y + bottom))
                        else if (y > 0)
                            calculationMatrix.postTranslate(0f, -y)
                    } else {
                        if (x < -right)
                            calculationMatrix.postTranslate(-(x + right), 0f)
                        else if (x > 0)
                            calculationMatrix.postTranslate(-x, 0f)
                    }
                }
            } else {
                calculationMatrix.postScale(scaleFactor, scaleFactor, detector.focusX, detector.focusY)
                calculationMatrix.getValues(matrixBounds)
                val x = matrixBounds[Matrix.MTRANS_X]
                val y = matrixBounds[Matrix.MTRANS_Y]

                if (scaleFactor < 1) {
                    if (x < -right)
                        calculationMatrix.postTranslate(-(x + right), 0f)
                    else if (x > 0)
                        calculationMatrix.postTranslate(-x, 0f)
                    if (y < -bottom)
                        calculationMatrix.postTranslate(0f, -(y + bottom))
                    else if (y > 0)
                        calculationMatrix.postTranslate(0f, -y)
                }
            }
            return true
        }
    }

    companion object {
        private const val MIN_SCALE = 1f
        private const val MAX_SCALE = 3f
        private const val MATRIX_SIZE = 9
        private const val CLICK = 3
        private const val MAX_SCALE_FACTOR = 1.05f
        private const val MIN_SCALE_FACTOR = .95f
    }
}
