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

package com.algorand.android.customviews.collectibleimageview

import android.content.Context
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import androidx.core.content.res.use
import androidx.core.view.updatePadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomCollectibleImageBinding
import com.algorand.android.utils.exceptions.ViewNullPointerException
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.recordException
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.imageview.ShapeableImageView

abstract class BaseCollectibleImageView(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs) {

    protected val binding = viewBinding(CustomCollectibleImageBinding::inflate)

    abstract val shapeableImageView: ShapeableImageView?

    init {
        initAttributes(attrs)
    }

    fun showText(text: String) {
        shapeableImageView?.apply {
            setImageDrawable(ColorDrawable(ContextCompat.getColor(context, R.color.layer_gray_lighter)))
            show()
        }
        binding.collectibleNameTextView.apply {
            this.text = text
            show()
        }
    }

    fun showImage(drawable: Drawable, decreaseOpacity: Boolean = false) {
        background = null
        binding.collectibleNameTextView.hide()
        shapeableImageView?.apply {
            alpha = if (decreaseOpacity) DECREASED_OPACITY else 1f
            setImageDrawable(drawable)
            show()
        }
    }

    fun getImageView(): ShapeableImageView? = shapeableImageView

    fun showVideoPlayButton() {
        binding.videoPlayButton.show()
    }

    protected fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.BaseCollectibleImageView).use {
            it.getDimension(R.styleable.BaseCollectibleImageView_textHorizontalMargin, -1f).let { margin ->
                if (margin != -1f) setTextMargin(margin.toInt())
            }
        }
    }

    private fun setTextMargin(marginIntSize: Int) {
        binding.collectibleNameTextView.updatePadding(
            left = marginIntSize,
            right = marginIntSize
        )
    }

    protected fun recordViewNullException(logTag: String) {
        recordException(ViewNullPointerException(logTag))
    }

    companion object {
        private const val DECREASED_OPACITY = 0.4f
    }
}
