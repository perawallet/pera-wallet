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

package com.algorand.android.modules.tutorialdialog.util

import android.content.Context
import com.algorand.android.R
import com.algorand.android.modules.tutorialdialog.ui.TutorialDialogBuilder

fun Context.showCopyAccountAddressTutorialDialog(onDismiss: (() -> Unit)? = null) {
    TutorialDialogBuilder.create(this)
        .setImageView(R.drawable.ic_copy_address_tutorial, R.dimen.spacing_xxlarge)
        .setTitleTextView(R.string.press_and_hold_to)
        .setDescriptionTextView(R.string.you_can_quickly_copy)
        .setSecondaryButton(textRes = R.string.got_it, onClick = onDismiss)
        .show()
}

fun Context.showSwapFeatureTutorialDialog(onTrySwap: (() -> Unit)? = null, onLater: (() -> Unit)? = null) {
    TutorialDialogBuilder.create(this)
        .setImageView(imageRes = R.drawable.swap_dialog)
        .setTitleTextView(textRes = R.string.swap_in_pera)
        .setTagTextView(textRes = R.string.new_text)
        .setDescriptionTextView(textRes = R.string.pera_wallet_now_provides_an)
        .setPrimaryButton(textRes = R.string.try_swap, onClick = onTrySwap)
        .setSecondaryButton(textRes = R.string.later, onClick = onLater)
        .show()
}
