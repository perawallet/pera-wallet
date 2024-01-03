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

package com.algorand.android.modules.rekey.undorekey.previousrekeyundoneconfirmation.ui

import android.text.method.LinkMovementMethod
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.utils.BaseDoubleButtonBottomSheet
import com.algorand.android.utils.browser.LEDGER_SUPPORT_URL
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setFragmentNavigationResult
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class PreviousRekeyUndoneConfirmationBottomSheet : BaseDoubleButtonBottomSheet() {

    private val previousRekeyUndoneConfirmationViewModel by viewModels<PreviousRekeyUndoneConfirmationViewModel>()

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.your_previous_rekey_will_be_undone)
    }

    override fun setDescriptionText(textView: TextView) {
        val accountAddress = previousRekeyUndoneConfirmationViewModel.accountDisplayName
            .getAccountPrimaryDisplayName()
        val authAccountAddress = previousRekeyUndoneConfirmationViewModel.authAccountDisplayName
            .getAccountPrimaryDisplayName()
        textView.apply {
            val linkTextColor = ContextCompat.getColor(context, R.color.link_primary)
            val clickSpannable = getCustomClickableSpan(
                clickableColor = linkTextColor,
                onClick = { context?.openUrl(LEDGER_SUPPORT_URL) }
            )
            val annotatedString = AnnotatedString(
                stringResId = R.string.auth_account_will_no_longer_be,
                replacementList = listOf(
                    "account_address" to accountAddress,
                    "auth_account_address" to authAccountAddress
                ),
                customAnnotationList = listOf("learn_more" to clickSpannable)
            )
            highlightColor = ContextCompat.getColor(context, R.color.transparent)
            movementMethod = LinkMovementMethod.getInstance()
            text = context?.getXmlStyledString(annotatedString)
        }
    }

    override fun setAcceptButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.confirm)
            setOnClickListener {
                setFragmentNavigationResult(PREVIOUS_REKEY_UNDONE_CONFIRMATION_KEY, true)
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
            setImageResource(R.drawable.ic_error)
            imageTintList = ContextCompat.getColorStateList(context, R.color.negative)
        }
    }

    companion object {
        const val PREVIOUS_REKEY_UNDONE_CONFIRMATION_KEY = "previous_rekey_undone_confirmation"
    }
}
