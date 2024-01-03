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
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.widget.FrameLayout
import androidx.core.view.isVisible
import com.algorand.android.databinding.CustomCollectibleImageBinding
import com.algorand.android.utils.exceptions.ViewNullPointerException
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.recordException
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.imageview.ShapeableImageView

abstract class BaseCollectibleImageView(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs) {

    protected val binding = viewBinding(CustomCollectibleImageBinding::inflate)

    abstract val shapeableImageView: ShapeableImageView?

    fun showImage(drawable: Drawable) {
        background = null
        shapeableImageView?.apply {
            setImageDrawable(drawable)
            show()
        }
    }

    fun setOpacity(decreaseOpacity: Boolean = false) {
        shapeableImageView?.alpha = if (decreaseOpacity) DECREASED_OPACITY else 1f
    }

    fun getImageView(): ShapeableImageView? = shapeableImageView

    fun setPlayButtonVisibility(isVisible: Boolean) {
        binding.videoPlayButton.isVisible = isVisible
    }

    protected fun recordViewNullException(logTag: String) {
        recordException(ViewNullPointerException(logTag))
    }

    companion object {
        const val DECREASED_OPACITY = 0.4f
    }
}
