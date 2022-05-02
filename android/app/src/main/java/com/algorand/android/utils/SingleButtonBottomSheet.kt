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

package com.algorand.android.utils

import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.models.AnnotatedString

class SingleButtonBottomSheet : BaseSingleButtonBottomSheet() {

    private val args: SingleButtonBottomSheetArgs by navArgs()

    // TODO: Use theme instead of passing all individually
    override val title: AnnotatedString
        get() = args.titleAnnotatedString
    override val iconDrawableResId: Int
        get() = args.drawableResId
    override val iconDrawableTintResId: Int
        get() = args.drawableTintResId
    override val descriptionAnnotatedString: AnnotatedString?
        get() = args.descriptionAnnotatedString
    override val errorAnnotatedString: AnnotatedString?
        get() = args.errorAnnotatedString
    override val buttonStringResId: Int
        get() = args.buttonStringResId

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        if (args.isResultNeeded) {
            isCancelable = false
            setDraggableEnabled(false)
        }
    }

    override fun onConfirmationButtonClick() {
        if (args.isResultNeeded) {
            setNavigationResult(CLOSE_KEY, true)
        }
        dismissAllowingStateLoss()
    }

    companion object {
        const val CLOSE_KEY = "close_key"
    }
}
