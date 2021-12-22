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

import androidx.navigation.fragment.navArgs
import com.algorand.android.models.AnnotatedString

class SingleButtonBottomSheet : BaseSingleButtonBottomSheet() {

    private val args: SingleButtonBottomSheetArgs by navArgs()
    // TODO: Use theme instead of passing all individually
    override val titleResId: Int
        get() = args.titleResId
    override val iconDrawableResId: Int
        get() = args.drawableResId
    override val iconDrawableTintResId: Int
        get() = args.drawableTintResId
    override val descriptionAnnotatedString: AnnotatedString
        get() = args.descriptionAnnotatedString
    override val imageBackgroundTintResId: Int
        get() = args.imageBackgroundTintResId
    override val buttonTextResId: Int
        get() = args.buttonTextResId
    override val buttonTextColorResId: Int
        get() = args.buttonTextColorResId
    override val buttonBackgroundTintResId: Int
        get() = args.buttonBackgroundTintResId

    override fun onConfirmationButtonClick() {
        if (args.isResultNeeded) {
            setNavigationResult(ACCEPT_KEY, true)
        }
        navBack()
    }

    companion object {
        const val ACCEPT_KEY = "accept_key"
    }
}
