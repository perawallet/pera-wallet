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

package com.algorand.android.tutorialdialog.ui

import android.content.Context
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes

class TutorialDialogBuilder private constructor(private val context: Context) {

    private val tutorialDialogParams = TutorialDialogParams()

    fun setImageView(@DrawableRes imageRes: Int?): TutorialDialogBuilder {
        tutorialDialogParams.tutorialImageRes = imageRes
        return this
    }

    fun setTitleTextView(@StringRes textRes: Int): TutorialDialogBuilder {
        tutorialDialogParams.tutorialTitleRes = textRes
        return this
    }

    fun setDescriptionTextView(@StringRes textRes: Int): TutorialDialogBuilder {
        tutorialDialogParams.tutorialDescriptionRes = textRes
        return this
    }

    fun setNeutralButton(@StringRes textRes: Int, onClick: (() -> Unit)? = null): TutorialDialogBuilder {
        with(tutorialDialogParams) {
            tutorialNeutralButtonTextRes = textRes
            neutralButtonClickListener = onClick
        }
        return this
    }

    fun show() {
        TutorialDialog.create(context).apply {
            applyParams(tutorialDialogParams)
            show()
        }
    }

    companion object {
        fun create(context: Context): TutorialDialogBuilder {
            return TutorialDialogBuilder(context)
        }
    }
}
