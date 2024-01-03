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
import android.util.AttributeSet
import com.algorand.android.R
import com.google.android.material.imageview.ShapeableImageView

class CollectibleImageView(
    context: Context,
    attrs: AttributeSet? = null
) : BaseCollectibleImageView(context, attrs) {

    override val shapeableImageView: ShapeableImageView? = inflateCollectibleImageView()

    private fun inflateCollectibleImageView(): ShapeableImageView? {
        return binding.collectibleImageViewStup.run {
            layoutResource = R.layout.layout_collectible_image_view
            inflate() as? ShapeableImageView
        }.also { if (it == null) recordViewNullException(logTag) }
    }

    companion object {
        private val logTag = CollectibleImageView::class.java.simpleName
    }
}
