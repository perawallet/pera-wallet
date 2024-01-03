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

package com.algorand.android.modules.notification.ui.utils

import android.content.Context
import android.graphics.drawable.Drawable
import android.os.Parcelable
import android.widget.ImageView
import androidx.core.view.doOnLayout
import com.algorand.android.utils.createPrismUrl
import com.algorand.android.utils.loadImage
import kotlinx.parcelize.Parcelize

@Parcelize
class NotificationIconDrawableProvider private constructor(
    val isFailed: Boolean,
    val logoUri: String?
) : Parcelable {

    fun getNotificationIconDrawable(
        imageView: ImageView,
        onResourceFailed: (Drawable?) -> Unit,
        onResourceReady: (Drawable) -> Unit = {}
    ) {
        with(imageView) {
            setImageDrawable(null)
            if (isFailed) {
                onResourceFailed(createFailedNotificationIconDrawable(context))
                return
            }
            doOnLayout {
                val placeHolder = createPlaceHolder(it.context)
                if (!logoUri.isNullOrBlank()) {
                    val uri = createPrismUrl(url = logoUri, width = it.measuredWidth)
                    loadImage(
                        uri = uri,
                        onResourceReady = { drawable -> onResourceReady(drawable) },
                        onLoadFailed = { drawable -> onResourceFailed(drawable) },
                        placeHolder = placeHolder
                    )
                } else {
                    setImageDrawable(placeHolder)
                }
            }
        }
    }

    private fun createPlaceHolder(context: Context): Drawable {
        return NotificationPlaceholderDrawable().toDrawable(context)
    }

    private fun createFailedNotificationIconDrawable(context: Context): Drawable {
        return FailedNotificationIconDrawable().toDrawable(context)
    }

    override fun equals(other: Any?): Boolean {
        if (other !is NotificationIconDrawableProvider) return false
        if (logoUri != other.logoUri) return false
        if (isFailed != other.isFailed) return false
        return true
    }

    @Suppress("MagicNumber")
    override fun hashCode(): Int {
        var result = logoUri.hashCode()
        result = 31 * result + isFailed.hashCode()
        return result
    }

    companion object {
        fun create(isFailed: Boolean, logoUri: String?): NotificationIconDrawableProvider {
            return NotificationIconDrawableProvider(isFailed = isFailed, logoUri = logoUri)
        }
    }
}
