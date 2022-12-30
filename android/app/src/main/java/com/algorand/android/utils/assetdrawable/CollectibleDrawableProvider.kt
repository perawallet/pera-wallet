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

package com.algorand.android.utils.assetdrawable

import android.content.Context
import android.graphics.drawable.Drawable
import android.widget.ImageView
import androidx.core.view.doOnLayout
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.createPrismUrl
import com.algorand.android.utils.loadImage
import kotlinx.parcelize.Parcelize

@Parcelize
class CollectibleDrawableProvider(
    override val assetName: AssetName,
    override val logoUri: String?
) : BaseAssetDrawableProvider() {

    override fun getAssetDrawable(
        imageView: ImageView,
        onPreparePlaceHolder: (Context, Int) -> Drawable?,
        onResourceReady: (Drawable) -> Unit,
        onResourceFailed: (Drawable?) -> Unit,
        onUriReady: (String) -> Unit
    ) {
        imageView.setImageDrawable(null)
        imageView.doOnLayout {
            val placeHolder = onPreparePlaceHolder(imageView.context, it.measuredWidth)
            if (!logoUri.isNullOrBlank()) {
                val uri = createPrismUrl(url = logoUri, width = it.measuredWidth).also(onUriReady)
                imageView.loadImage(
                    uri = uri,
                    onResourceReady = { drawable -> onResourceReady(drawable) },
                    onLoadFailed = { drawable -> onResourceFailed(drawable) },
                    placeHolder = placeHolder
                )
            } else {
                onResourceFailed(placeHolder)
            }
        }
    }

    override fun createPlaceHolder(context: Context, width: Int): Drawable {
        return CollectibleNameDrawable(assetName.getAsAvatarNameOrDefault(context.resources), width).toDrawable(context)
    }

    override fun equals(other: Any?): Boolean {
        if (other !is CollectibleDrawableProvider) return false
        if (logoUri != other.logoUri) return false
        if (assetName != other.assetName) return false
        return true
    }

    @Suppress("MagicNumber")
    override fun hashCode(): Int {
        var result = assetName.hashCode()
        result = 31 * result + logoUri.hashCode()
        return result
    }
}
