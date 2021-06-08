/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.utils

import android.net.Uri
import android.widget.ImageView
import androidx.annotation.DrawableRes
import com.algorand.android.R
import com.bumptech.glide.Glide

fun ImageView.loadContactProfileImage(
    uri: Uri?,
    useSecondaryBackground: Boolean = false,
    shouldUsePlaceHolder: Boolean = true
) {
    if (uri == null) {
        if (shouldUsePlaceHolder.not()) return

        setBackgroundResource(
            if (useSecondaryBackground) {
                R.drawable.bg_photo_secondary
            } else {
                R.drawable.bg_photo_primary
            }
        )
        Glide.with(this)
            .load(R.drawable.ic_profile_photo_placeholder)
            .into(this)
    } else {
        Glide.with(this)
            .load(uri)
            .circleCrop()
            .into(this)
    }
}

fun ImageView.loadImage(@DrawableRes drawableResId: Int) {
    Glide.with(this)
        .load(drawableResId)
        .into(this)
}
