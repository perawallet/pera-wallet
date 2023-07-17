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

package com.algorand.android.modules.accountdetail.accountstatusdetail.ui

import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetAccountStatusDetailBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.Event
import com.algorand.android.utils.browser.LEDGER_SUPPORT_URL
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AccountStatusDetailBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_account_status_detail) {

    private val accountStatusDetailViewModel by viewModels<AccountStatusDetailViewModel>()

    private val binding by viewBinding(BottomSheetAccountStatusDetailBinding::bind)

    private val rekeyToStandardAccountVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.rekeyToStandardAccountButton.isVisible = isVisible == true
    }

    private val rekeyToLedgerAccountVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.rekeyToLedgerAccountButton.isVisible = isVisible == true
    }

    private val rekeyGroupVisiblityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.rekeyGroup.isVisible = isVisible == true
    }

    private val authAccountIconDrawablePreviewCollector: suspend (
        AccountIconDrawablePreview?
    ) -> Unit = { drawablePreview ->
        binding.authAccountItemView.apply {
            if (drawablePreview != null) {
                val drawable = AccountIconDrawable.create(context, R.dimen.spacing_xxxxlarge, drawablePreview)
                setStartIconDrawable(drawable)
            }
        }
    }

    private val accountTypeDrawablePreviewCollector: suspend (
        AccountIconDrawablePreview?
    ) -> Unit = { drawablePreview ->
        if (drawablePreview != null) {
            binding.accountStateTextView.apply {
                val drawable = AccountIconDrawable.create(context, R.dimen.spacing_xxxxlarge, drawablePreview)
                setDrawable(start = drawable)
            }
        }
    }

    private val accountOriginalTypeIconDrawablePreviewCollector: suspend (
        AccountIconDrawablePreview?
    ) -> Unit = { drawablePreview ->
        if (drawablePreview != null) {
            binding.accountItemView.apply {
                val drawable = AccountIconDrawable.create(context, R.dimen.spacing_xxxxlarge, drawablePreview)
                setStartIconDrawable(drawable)
            }
        }
    }

    private val titleStringCollector: suspend (String?) -> Unit = { titleString ->
        binding.accountTypeTextView.text = titleString
    }

    private val accountTypeStringCollector: suspend (String?) -> Unit = { accountTypeString ->
        binding.accountStateTextView.text = accountTypeString
    }

    private val descriptionAnnotatedStringCollector: suspend (AnnotatedString?) -> Unit = { annotatedString ->
        if (annotatedString != null) {
            val linkTextColor = ContextCompat.getColor(binding.root.context, R.color.link_primary)
            val clickSpannable = getCustomClickableSpan(
                clickableColor = linkTextColor,
                onClick = { context?.openUrl(LEDGER_SUPPORT_URL) }
            )
            val clickableAnnotatedString = annotatedString.copy(
                customAnnotationList = listOf("learn_more" to clickSpannable)
            )
            binding.accountStateDescriptionTextView.text = context?.getXmlStyledString(clickableAnnotatedString)
        }
    }

    private val authAccountDisplayNameCollector: suspend (AccountDisplayName?) -> Unit = { displayName ->
        binding.authAccountItemView.apply {
            setTitleText(displayName?.getAccountPrimaryDisplayName())
            setDescriptionText(displayName?.getAccountSecondaryDisplayName(resources))
            setOnLongClickListener { onAccountAddressCopied(displayName?.getRawAccountAddress().orEmpty()); true }
        }
    }

    private val accountDisplayNameCollector: suspend (AccountDisplayName?) -> Unit = { displayName ->
        binding.accountItemView.apply {
            setTitleText(displayName?.getAccountPrimaryDisplayName())
            setDescriptionText(displayName?.getAccountSecondaryDisplayName(resources))
            setOnLongClickListener { onAccountAddressCopied(displayName?.getRawAccountAddress().orEmpty()); true }
        }
    }

    private val copyAccountAddressToClipboardEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { onAccountAddressCopied(accountStatusDetailViewModel.accountAddress) }
    }

    private val navToUndoRekeyNavigationEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToUndoRekeyNavigation() }
    }

    private val authAccountActionButtonCollector: suspend (AccountAssetItemButtonState?) -> Unit = { buttonState ->
        if (buttonState != null) {
            binding.authAccountItemView.apply {
                setButtonState(buttonState)
                setActionTextButtonClickListener { accountStatusDetailViewModel.onAuthAccountActionButtonClicked() }
            }
        }
    }

    private val accountOriginalActionButtonCollector: suspend (AccountAssetItemButtonState?) -> Unit = { buttonState ->
        if (buttonState != null) {
            binding.accountItemView.apply {
                setButtonState(buttonState)
                setActionButtonClickListener { accountStatusDetailViewModel.onAccountActionButtonClicked() }
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            accountStateDescriptionTextView.apply {
                highlightColor = ContextCompat.getColor(context, R.color.transparent)
                movementMethod = LinkMovementMethod.getInstance()
            }
            rekeyToStandardAccountButton.setOnClickListener { navToRekeyToStandardAccountNavigation() }
            rekeyToLedgerAccountButton.setOnClickListener { navToRekeyToLedgerAccountNavigation() }
        }
    }

    @SuppressWarnings("LongMethod")
    private fun initObservers() {
        with(accountStatusDetailViewModel.accountStatusDetailPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.accountOriginalTypeDisplayName }.distinctUntilChanged(),
                collection = accountDisplayNameCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.accountOriginalTypeIconDrawablePreview }.distinctUntilChanged(),
                collection = accountOriginalTypeIconDrawablePreviewCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.accountTypeString }.distinctUntilChanged(),
                collection = accountTypeStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.accountTypeDrawablePreview }.distinctUntilChanged(),
                collection = accountTypeDrawablePreviewCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.authAccountDisplayName }.distinctUntilChanged(),
                collection = authAccountDisplayNameCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.descriptionAnnotatedString }.distinctUntilChanged(),
                collection = descriptionAnnotatedStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.titleString }.distinctUntilChanged(),
                collection = titleStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.authAccountIconDrawablePreview }.distinctUntilChanged(),
                collection = authAccountIconDrawablePreviewCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isRekeyGroupVisible }.distinctUntilChanged(),
                collection = rekeyGroupVisiblityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isRekeyToLedgerAccountVisible }.distinctUntilChanged(),
                collection = rekeyToLedgerAccountVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isRekeyToStandardAccountVisible }.distinctUntilChanged(),
                collection = rekeyToStandardAccountVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.accountOriginalActionButton }.distinctUntilChanged(),
                collection = accountOriginalActionButtonCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.authAccountActionButton }.distinctUntilChanged(),
                collection = authAccountActionButtonCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.navToUndoRekeyNavigationEvent }.distinctUntilChanged(),
                collection = navToUndoRekeyNavigationEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.copyAccountAddressToClipboardEvent }.distinctUntilChanged(),
                collection = copyAccountAddressToClipboardEventCollector
            )
        }
    }

    private fun navToRekeyToLedgerAccountNavigation() {
        val accountAddress = accountStatusDetailViewModel.accountAddress
        nav(
            AccountStatusDetailBottomSheetDirections
                .actionAccountStatusDetailBottomSheetToRekeyLedgerNavigation(accountAddress)
        )
    }

    private fun navToRekeyToStandardAccountNavigation() {
        val accountAddress = accountStatusDetailViewModel.accountAddress
        nav(
            AccountStatusDetailBottomSheetDirections
                .actionAccountStatusDetailBottomSheetToRekeyToStandardAccountNavigation(accountAddress)
        )
    }

    private fun navToUndoRekeyNavigation() {
        val accountAddress = accountStatusDetailViewModel.accountAddress
        nav(
            AccountStatusDetailBottomSheetDirections
                .actionAccountStatusDetailBottomSheetToRekeyUndoNavigation(accountAddress)
        )
    }
}
