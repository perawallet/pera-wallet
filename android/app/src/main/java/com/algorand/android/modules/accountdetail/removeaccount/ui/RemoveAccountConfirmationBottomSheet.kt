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

package com.algorand.android.modules.accountdetail.removeaccount.ui

import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.PluralAnnotatedString
import com.algorand.android.utils.BaseDoubleButtonBottomSheet
import com.algorand.android.utils.Event
import com.algorand.android.utils.emptyString
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getXmlStyledPluralString
import com.algorand.android.utils.setFragmentNavigationResult
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class RemoveAccountConfirmationBottomSheet : BaseDoubleButtonBottomSheet() {

    private val removeAccountConfirmationViewModel: RemoveAccountConfirmationViewModel by viewModels()

    private val showGlobalErrorEventCollector: suspend (Event<PluralAnnotatedString>?) -> Unit = { event ->
        event?.consume()?.let { errorAnnotatedString ->
            showGlobalError(
                title = context?.getXmlStyledPluralString(errorAnnotatedString).toString(),
                tag = baseActivityTag,
                errorMessage = emptyString()
            )
        }
    }

    private val navBackEventCollector: suspend (Event<Boolean>?) -> Unit = { event ->
        event?.consume()?.let { isConfirmed ->
            setFragmentNavigationResult(ACCOUNT_REMOVE_CONFIRMATION_KEY, isConfirmed)
            navBack()
        }
    }

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.remove_account)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.setText(removeAccountConfirmationViewModel.descriptionTextResId)
    }

    override fun setAcceptButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.remove)
            setOnClickListener { removeAccountConfirmationViewModel.onRemoveAccountClick() }
        }
    }

    override fun setCancelButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.keep_it)
            setOnClickListener { navBack() }
        }
    }

    override fun setIconImageView(imageView: ImageView) {
        imageView.apply {
            setImageResource(R.drawable.ic_trash)
            imageTintList = ContextCompat.getColorStateList(context, R.color.negative)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
    }

    private fun initObservers() {
        with(removeAccountConfirmationViewModel.removeAccountConfirmationPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.showGlobalErrorEvent },
                collection = showGlobalErrorEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.navBackEvent },
                collection = navBackEventCollector
            )
        }
    }

    companion object {
        const val ACCOUNT_REMOVE_CONFIRMATION_KEY = "account_remove_confirmation"
    }
}
