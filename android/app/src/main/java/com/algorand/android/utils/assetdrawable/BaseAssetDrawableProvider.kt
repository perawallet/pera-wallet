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
import android.os.Parcelable
import android.widget.ImageView
import com.algorand.android.utils.AssetName

abstract class BaseAssetDrawableProvider : Parcelable {

    abstract val assetName: AssetName
    abstract val logoUri: String?

    fun provideAssetDrawable(
        imageView: ImageView?,
        onPreparePlaceHolder: (Context, Int) -> Drawable? = { context, width -> createPlaceHolder(context, width) },
        onResourceReady: (Drawable) -> Unit = {},
        onResourceFailed: (Drawable?) -> Unit = {},
        onUriReady: (String) -> Unit = {}
    ) {
        if (imageView == null) return
        getAssetDrawable(
            imageView = imageView,
            onResourceReady = onResourceReady,
            onResourceFailed = onResourceFailed,
            onUriReady = onUriReady,
            onPreparePlaceHolder = onPreparePlaceHolder
        )
    }

    protected abstract fun getAssetDrawable(
        imageView: ImageView,
        onPreparePlaceHolder: (Context, Int) -> Drawable?,
        onResourceReady: (Drawable) -> Unit,
        onResourceFailed: (Drawable?) -> Unit,
        onUriReady: (String) -> Unit = {}
    )

    protected abstract fun createPlaceHolder(context: Context, width: Int): Drawable?
}
