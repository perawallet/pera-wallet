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

package com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.LoadingDialogFragment
import com.algorand.android.databinding.FragmentRekeyConfirmationBinding
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class RekeyToStandardAccountConfirmationFragment : TransactionBaseFragment(
    R.layout.fragment_rekey_to_standard_account_confirmation
) {

    private var loadingDialogFragment: LoadingDialogFragment? = null

    private val rekeyToStandardAccountConfirmationViewModel by viewModels<RekeyToStandardAccountConfirmationViewModel>()

    private val binding by viewBinding(FragmentRekeyConfirmationBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override val transactionFragmentListener = object : TransactionFragmentListener {

        override fun onSignTransactionLoadingFinished() {
            loadingDialogFragment?.dismissAllowingStateLoss()
        }

        override fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail) {
            if (signedTransactionDetail is SignedTransactionDetail.RekeyToStandardAccountOperation) {
                rekeyToStandardAccountConfirmationViewModel.sendRekeyTransaction(signedTransactionDetail)
            }
        }
    }

    private val displayCalculatedTransactionFeeEventCollector: suspend (Event<String>?) -> Unit = { event ->
        event?.consume()?.run { binding.feeTextView.text = getString(R.string.total_rekeying_fee, this) }
    }

    private val oldAccountTypeIconResourceCollector: suspend (AccountIconResource) -> Unit = { oldAccountIconRes ->
        binding.oldAccountTypeImageView.setImageResource(oldAccountIconRes.iconResId)
    }

    private val oldAccountTitleTextResIdCollector: suspend (Int) -> Unit = { oldAccountTitleRes ->
        binding.oldAccountLabelTextView.setText(oldAccountTitleRes)
    }

    private val oldAccountDisplayNameCollector: suspend (String) -> Unit = { oldAccountDisplayName ->
        binding.oldAccountNameTextView.text = oldAccountDisplayName
    }

    private val newAccountTypeIconResourceCollector: suspend (AccountIconResource) -> Unit = { newAccountIconRes ->
        val accountIconDrawable = AccountIconDrawable.create(
            context = binding.root.context,
            accountIconResource = newAccountIconRes,
            size = resources.getDimension(R.dimen.account_icon_size_large).toInt()
        )
        binding.newAccountTypeImageView.setImageDrawable(accountIconDrawable)
    }

    private val newAccountTitleTextResIdCollector: suspend (Int) -> Unit = { newAccountTitleRes ->
        binding.newLedgerLabel.setText(newAccountTitleRes)
    }

    private val newAccountDisplayNameCollector: suspend (String) -> Unit = { newAccountDisplayName ->
        binding.newLedgerNameTextView.text = newAccountDisplayName
    }

    private val navToRekeyToStandardAccountVerifyFragmentEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToVerifyFragment() }
    }

    private val showGlobalErrorEventCollector: suspend (Event<String>?) -> Unit = { event ->
        event?.consume()?.run { showGlobalError(errorMessage = this) }
    }

    private val loadingStateCollector: suspend (Boolean) -> Unit = { isVisible ->
        if (isVisible) {
            loadingDialogFragment = null
            loadingDialogFragment = LoadingDialogFragment.show(childFragmentManager, R.string.rekeying_account)
        } else {
            loadingDialogFragment?.dismissAllowingStateLoss()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
    }

    private fun initUi() {
        binding.confirmButton.setOnClickListener { onConfirmClick() }
    }

    private fun initObservers() {
        with(rekeyToStandardAccountConfirmationViewModel.rekeyToStandardAccountConfirmationPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.newAccountDisplayName },
                collection = newAccountDisplayNameCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.newAccountTitleTextResId },
                collection = newAccountTitleTextResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.newAccountTypeIconResource },
                collection = newAccountTypeIconResourceCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.oldAccountDisplayName },
                collection = oldAccountDisplayNameCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.oldAccountTitleTextResId },
                collection = oldAccountTitleTextResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.oldAccountTypeIconResource },
                collection = oldAccountTypeIconResourceCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.onDisplayCalculatedTransactionFeeEvent },
                collection = displayCalculatedTransactionFeeEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.navToRekeyToStandardAccountVerifyFragmentEvent },
                collection = navToRekeyToStandardAccountVerifyFragmentEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.showGlobalErrorEvent },
                collection = showGlobalErrorEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isLoading },
                collection = loadingStateCollector
            )
        }
    }

    private fun onConfirmClick() {
        val rekeyTx = rekeyToStandardAccountConfirmationViewModel.createRekeyToStandardAccountTransaction() ?: return
        sendTransaction(rekeyTx)
    }

    private fun navToVerifyFragment() {
        val accountName = rekeyToStandardAccountConfirmationViewModel.accountAddress
        val authAccountName = rekeyToStandardAccountConfirmationViewModel.authAccountAddress
        nav(
            RekeyToStandardAccountConfirmationFragmentDirections
                .actionRekeyToStandardAccountConfirmationFragmentToRekeyToStandardAccountVerifyInfoFragment(
                    accountAddress = accountName,
                    authAccountAddress = authAccountName
                )
        )
    }
}
