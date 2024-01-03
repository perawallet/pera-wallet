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

package com.algorand.android.modules.accountdetail.haveyoubackedupconfirmation.ui

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.utils.BaseDoubleButtonBottomSheet
import com.algorand.android.utils.setFragmentNavigationResult
import com.google.android.material.button.MaterialButton

class HaveYouBackedUpAccountConfirmationBottomSheet : BaseDoubleButtonBottomSheet() {

    override fun setTitleText(textView: TextView) {
        textView.text = getString(R.string.have_you_backed_up_your)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.text = getString(R.string.if_you_don_t_have)
    }

    override fun setAcceptButton(materialButton: MaterialButton) {
        materialButton.apply {
            text = context.getString(R.string.yes_continue)
            setOnClickListener {
                navBack()
                setFragmentNavigationResult(HAVE_YOU_BACKED_UP_ACCOUNT_CONFIRMATION_KEY, true)
            }
        }
    }

    override fun setCancelButton(materialButton: MaterialButton) {
        materialButton.apply {
            text = context.getString(R.string.no_keep_account)
            setOnClickListener { navBack() }
        }
    }

    override fun setIconImageView(imageView: ImageView) {
        imageView.apply {
            setImageResource(R.drawable.ic_error)
            imageTintList = ContextCompat.getColorStateList(context, R.color.negative)
        }
    }

    companion object {
        const val HAVE_YOU_BACKED_UP_ACCOUNT_CONFIRMATION_KEY = "have_you_backed_up_account_confirmation"
    }
}
