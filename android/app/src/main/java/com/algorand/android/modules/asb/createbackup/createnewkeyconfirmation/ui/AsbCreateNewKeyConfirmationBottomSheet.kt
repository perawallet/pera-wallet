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

package com.algorand.android.modules.asb.createbackup.createnewkeyconfirmation.ui

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.utils.BaseDoubleButtonBottomSheet
import com.algorand.android.utils.setFragmentNavigationResult
import com.google.android.material.button.MaterialButton

class AsbCreateNewKeyConfirmationBottomSheet : BaseDoubleButtonBottomSheet() {
    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.create_new_key)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.setText(R.string.you_are_about_to_reset)
    }

    override fun setAcceptButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.i_understand_proceed)
            setOnClickListener {
                setFragmentNavigationResult(ASB_CREATE_NEW_KEY_CONFIRMATION_KEY, true)
                navBack()
            }
        }
    }

    override fun setCancelButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.cancel)
            setOnClickListener { navBack() }
        }
    }

    override fun setIconImageView(imageView: ImageView) {
        imageView.apply {
            setImageResource(R.drawable.ic_key)
            imageTintList = ContextCompat.getColorStateList(context, R.color.positive)
        }
    }

    companion object {
        const val ASB_CREATE_NEW_KEY_CONFIRMATION_KEY = "asbCreateNewKeyConfirmationKey"
    }
}
