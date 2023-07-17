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

package com.algorand.android.modules.rekey.baserekeyconfirmation.ui

import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.LoadingDialogFragment
import com.algorand.android.databinding.FragmentBaseRekeyConfirmationBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.SignedTransactionDetail
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
import kotlinx.coroutines.flow.map

abstract class BaseRekeyConfirmationFragment : TransactionBaseFragment(R.layout.fragment_base_rekey_confirmation) {

    private var loadingDialogFragment: LoadingDialogFragment? = null

    private val binding by viewBinding(FragmentBaseRekeyConfirmationBinding::bind)

    override val transactionFragmentListener = object : TransactionFragmentListener {
        override fun onSignTransactionLoadingFinished() {
            loadingDialogFragment?.dismissAllowingStateLoss()
        }

        override fun onSignTransactionFailed() {
            onTransactionFailed()
        }

        override fun onSignTransactionLoading() {
            onTransactionLoading()
        }

        override fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail) {
            onTransactionSigned(signedTransactionDetail)
        }
    }

    abstract val baseRekeyConfirmationViewModel: BaseRekeyConfirmationViewModel

    private val subtitleTextResIdCollector: suspend (Int) -> Unit = { subtitleTextResId ->
        binding.subtitleTextView.setText(subtitleTextResId)
    }

    private val titleTextResIdCollector: suspend (Int) -> Unit = { titleResId ->
        binding.titleTextView.setText(titleResId)
    }

    private val onSendTransactionEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { onSendTransaction() }
    }

    private val navToRekeyedAccountConfirmationBottomSheetEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToRekeyedAccountConfirmationBottomSheet() }
    }

    private val showGlobalErrorEventCollector: suspend (Event<Pair<Int, String>>?) -> Unit = { event ->
        event?.consume()?.let { (title, description) ->
            showGlobalError(
                title = context?.getString(title),
                errorMessage = description
            )
        }
    }

    private val loadingStateVisibilityCollector: suspend (Boolean) -> Unit = { isVisible ->
        if (isVisible) {
            loadingDialogFragment = null
            loadingDialogFragment = LoadingDialogFragment.show(childFragmentManager, R.string.rekeying_account, true)
        } else {
            loadingDialogFragment?.dismissAllowingStateLoss()
        }
    }

    private val navToRekeyResultInfoFragmentEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToResultInfoFragment() }
    }

    private val formattedTransactionFeeCollector: suspend (String?) -> Unit = { formattedFee ->
        binding.transactionFeeTextView.text = formattedFee
    }

    private val transactionFeeGroupIsVisibilityCollector: suspend (Boolean) -> Unit = { isVisible ->
        binding.transactionFeeGroup.isVisible = isVisible
    }

    private val currentlyRekeyedAccountIconDrawableCollector: suspend (
        AccountIconDrawablePreview?
    ) -> Unit = { iconDrawable ->
        if (iconDrawable != null) {
            val drawable = AccountIconDrawable.create(binding.root.context, R.dimen.spacing_xxxlarge, iconDrawable)
            binding.currentlyRekeyedAccountTextView.setDrawable(start = drawable)
        }
    }

    private val currentlyRekeyedAccountDisplayNameCollector: suspend (AccountDisplayName?) -> Unit = { displayName ->
        binding.currentlyRekeyedAccountTextView.text = displayName?.getAccountPrimaryDisplayName()
    }

    private val currentlyRekeyedAccountGroupVisiblityCollector: suspend (Boolean) -> Unit = { isVisible ->
        binding.currentlyRekeyedGroup.isVisible = isVisible
    }

    private val authAccountIconResourceCollector: suspend (AccountIconDrawablePreview) -> Unit = { iconDrawable ->
        val drawable = AccountIconDrawable.create(binding.root.context, R.dimen.spacing_xxxlarge, iconDrawable)
        binding.authAccountItemView.setStartIconDrawable(drawable)
    }

    private val authAccountDisplayNameCollector: suspend (AccountDisplayName) -> Unit = { displayName ->
        with(binding.authAccountItemView) {
            setTitleText(displayName.getAccountPrimaryDisplayName())
            setDescriptionText(displayName.getAccountSecondaryDisplayName(resources))
        }
    }

    private val rekeyedAccountIconResourceCollector: suspend (AccountIconDrawablePreview) -> Unit = { iconDrawable ->
        val drawable = AccountIconDrawable.create(binding.root.context, R.dimen.spacing_xxxlarge, iconDrawable)
        binding.rekeyedAccountItemView.setStartIconDrawable(drawable)
    }

    private val rekeyedAccountDisplayNameCollector: suspend (AccountDisplayName) -> Unit = { displayName ->
        with(binding.rekeyedAccountItemView) {
            setTitleText(displayName.getAccountPrimaryDisplayName())
            setDescriptionText(displayName.getAccountSecondaryDisplayName(resources))
        }
    }

    private val descriptionAnnotatedStringCollector: suspend (AnnotatedString) -> Unit = { annotatedString ->
        val linkTextColor = ContextCompat.getColor(binding.root.context, R.color.link_primary)
        val clickSpannable = getCustomClickableSpan(
            clickableColor = linkTextColor,
            onClick = { context?.openUrl(LEDGER_SUPPORT_URL) }
        )
        val clickableAnnotatedString = annotatedString.copy(
            customAnnotationList = listOf("learn_more" to clickSpannable)
        )
        binding.descriptionTextView.text = context?.getXmlStyledString(clickableAnnotatedString)
    }

    abstract fun navToResultInfoFragment()
    abstract fun navToRekeyedAccountConfirmationBottomSheet()
    abstract fun onConfirmClick()
    abstract fun onSendTransaction()
    abstract fun onTransactionLoading()
    abstract fun onTransactionFailed()
    abstract fun onTransactionSigned(signedTransactionDetail: SignedTransactionDetail)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    protected open fun initUi() {
        with(binding) {
            confirmRekeyButton.setOnClickListener { onConfirmClick() }
            descriptionTextView.apply {
                highlightColor = ContextCompat.getColor(binding.root.context, R.color.transparent)
                movementMethod = LinkMovementMethod.getInstance()
            }
        }
    }

    @SuppressWarnings("LongMethod")
    protected open fun initObservers() {
        with(baseRekeyConfirmationViewModel.baseRekeyConfirmationFieldsFlow) {
            collectLatestOnLifecycle(
                flow = map { it.isLoading },
                collection = loadingStateVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.showGlobalErrorEvent },
                collection = showGlobalErrorEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.descriptionAnnotatedString },
                collection = descriptionAnnotatedStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.rekeyedAccountDisplayName },
                collection = rekeyedAccountDisplayNameCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.rekeyedAccountIconResource },
                collection = rekeyedAccountIconResourceCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.authAccountDisplayName },
                collection = authAccountDisplayNameCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.authAccountIconResource },
                collection = authAccountIconResourceCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isCurrentlyRekeyedAccountGroupVisible },
                collection = currentlyRekeyedAccountGroupVisiblityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.currentlyRekeyedAccountDisplayName },
                collection = currentlyRekeyedAccountDisplayNameCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.currentlyRekeyedAccountIconDrawable },
                collection = currentlyRekeyedAccountIconDrawableCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isTransactionFeeGroupIsVisible },
                collection = transactionFeeGroupIsVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.formattedTransactionFee },
                collection = formattedTransactionFeeCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.navToRekeyResultInfoFragmentEvent },
                collection = navToRekeyResultInfoFragmentEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.navToRekeyedAccountConfirmationBottomSheetEvent },
                collection = navToRekeyedAccountConfirmationBottomSheetEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.onSendTransactionEvent },
                collection = onSendTransactionEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.titleTextResId },
                collection = titleTextResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.subtitleTextResId },
                collection = subtitleTextResIdCollector
            )
        }
    }
}
