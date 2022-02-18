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

package com.algorand.android.ui.rekey

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.LoadingDialogFragment
import com.algorand.android.databinding.FragmentRekeyConfirmationBinding
import com.algorand.android.models.Account
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RekeyConfirmationFragment : TransactionBaseFragment(R.layout.fragment_rekey_confirmation) {

    private var loadingDialogFragment: LoadingDialogFragment? = null

    private val args: RekeyConfirmationFragmentArgs by navArgs()

    private val rekeyConfirmationViewModel: RekeyConfirmationViewModel by viewModels()

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
            if (signedTransactionDetail is SignedTransactionDetail.RekeyOperation) {
                rekeyConfirmationViewModel.sendRekeyTransaction(signedTransactionDetail)
            }
        }
    }

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val feeObserver = Observer<Long> { rekeyConfirmationFee ->
        setupFee(rekeyConfirmationFee)
    }

    private val transactionResultObserver = Observer<Event<Resource<Any>>> { transactionResourceEvent ->
        transactionResourceEvent.consume()?.use(
            onSuccess = {
                val accountName = rekeyConfirmationViewModel.getCachedAccountName(args.rekeyAddress).orEmpty()
                nav(
                    RekeyConfirmationFragmentDirections.actionRekeyConfirmationFragmentToVerifyRekeyInfoFragment(
                        accountName
                    )
                )
            },
            onLoadingFinished = {
                loadingDialogFragment?.dismissAllowingStateLoss()
            },
            onFailed = { error ->
                showGlobalError(error.parse(requireContext()))
            }
        )
    }

    // </editor-fold>

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        setupTransferView()
        binding.confirmButton.setOnClickListener { onConfirmClick() }
    }

    private fun initObservers() {
        with(rekeyConfirmationViewModel) {
            feeLiveData.observe(viewLifecycleOwner, feeObserver)
            transactionResourceLiveData.observe(viewLifecycleOwner, transactionResultObserver)
        }
    }

    private fun setupTransferView() {
        val authAddress = rekeyConfirmationViewModel.getCachedAccountAuthAddress(args.rekeyAddress)
        val account = rekeyConfirmationViewModel.getCachedAccountData(args.rekeyAddress)
        if (authAddress.isNullOrEmpty()) {
            when (val accountDetail = account?.detail) {
                is Account.Detail.Standard -> setupTransferViewForStandardAccount()
                is Account.Detail.Ledger -> {
                    setupTransferViewForLedgerAccount(accountDetail.bluetoothName, account.name)
                }
                is Account.Detail.Rekeyed, is Account.Detail.RekeyedAuth -> {
                    setupTransferViewForRekeyedAccount(account.name)
                }
            }
        } else {
            val authAccount = accountCacheManager.getAuthAccount(account)
            setupTransferViewForLedgerToLedger(authAccount, authAddress)
        }
        binding.newLedgerNameTextView.text = args.rekeyAdminAddress.toShortenedAddress()
    }

    private fun setupTransferViewForStandardAccount() {
        with(binding) {
            oldAccountTypeImageView.setImageResource(R.drawable.ic_wallet)
            oldAccountLabelTextView.setText(R.string.passphrase)
            oldAccountNameTextView.setText(R.string.hidden_passphrase)
        }
    }

    private fun setupTransferViewForLedgerAccount(bluetoothName: String?, accountName: String) {
        with(binding) {
            oldAccountTypeImageView.setImageResource(R.drawable.ic_ledger)
            oldAccountLabelTextView.setText(R.string.old_ledger)
            oldAccountNameTextView.text = bluetoothName ?: accountName
        }
    }

    private fun setupTransferViewForRekeyedAccount(accountName: String) {
        with(binding) {
            oldAccountTypeImageView.setImageResource(R.drawable.ic_ledger)
            oldAccountLabelTextView.setText(R.string.old_ledger)
            oldAccountNameTextView.text = accountName
        }
    }

    private fun setupTransferViewForLedgerToLedger(authAccount: Account?, authAddress: String) {
        with(binding) {
            oldAccountLabelTextView.setText(R.string.old_ledger)
            oldAccountNameTextView.text = authAccount?.name ?: authAddress.toShortenedAddress()
            oldAccountTypeImageView.setImageResource(R.drawable.ic_ledger)
        }
    }

    private fun setupFee(fee: Long) {
        binding.feeTextView.text = getString(R.string.total_rekeying_fee, fee.formatAsAlgoString())
    }

    private fun onConfirmClick() {
        loadingDialogFragment = LoadingDialogFragment.show(childFragmentManager, R.string.rekeying_account)
        rekeyConfirmationViewModel.getAccountCacheData(args.rekeyAddress)?.let { safeAccountCacheData ->
            val rekeyTx = TransactionData.Rekey(safeAccountCacheData, args.rekeyAdminAddress, args.ledgerDetail)
            sendTransaction(rekeyTx)
        }
    }
}
