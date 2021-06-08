/*
 * Copyright 2019 Algorand, Inc.
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
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.LoadingDialogFragment
import com.algorand.android.databinding.FragmentRekeyConfirmationBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.SingleButtonBottomSheet
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RekeyConfirmationFragment : TransactionBaseFragment(R.layout.fragment_rekey_confirmation) {

    private var accountCacheData: AccountCacheData? = null
    private var loadingDialogFragment: LoadingDialogFragment? = null

    private val args: RekeyConfirmationFragmentArgs by navArgs()

    private val rekeyConfirmationViewModel: RekeyConfirmationViewModel by viewModels()

    private val binding by viewBinding(FragmentRekeyConfirmationBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.confirm_rekeying,
        startIconResId = R.drawable.ic_back_navigation,
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
                nav(
                    MainNavigationDirections.actionGlobalSingleButtonBottomSheet(
                        titleResId = R.string.account_rekeyed,
                        drawableResId = R.drawable.ic_check_sign,
                        descriptionAnnotatedString = AnnotatedString(
                            stringResId = R.string.the_account_name,
                            replacementList = listOf("account_name" to accountCacheData?.account?.name.orEmpty())
                        ),
                        buttonTextResId = R.string.close,
                        isResultNeeded = true
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
        accountCacheData = rekeyConfirmationViewModel.getAccountCacheData(args.rekeyAddress)
        initDialogSavedStateListener()
        initObservers()
        setupTransferView()
        setupCollapsibleAccountView()
        binding.confirmButton.setOnClickListener { onConfirmClick() }
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.rekeyConfirmationFragment) {
            useSavedStateValue<Boolean>(SingleButtonBottomSheet.ACCEPT_KEY) {
                nav(RekeyConfirmationFragmentDirections.actionRekeyConfirmationFragmentToHomeNavigation())
            }
        }
    }

    private fun initObservers() {
        rekeyConfirmationViewModel.feeLiveData.observe(viewLifecycleOwner, feeObserver)
        rekeyConfirmationViewModel.transactionResourceLiveData.observe(viewLifecycleOwner, transactionResultObserver)
    }

    private fun setupTransferView() {
        val authAddress = accountCacheData?.authAddress
        if (authAddress.isNullOrEmpty()) {
            when (val accountDetail = accountCacheData?.account?.detail) {
                is Account.Detail.Standard -> {
                    binding.oldAccountLabelTextView.setText(R.string.passphrase)
                    binding.oldAccountNameTextView.setText(R.string.hidden_passphrase)
                }
                is Account.Detail.Ledger -> {
                    binding.oldAccountLabelTextView.setText(R.string.old_ledger)
                    binding.oldAccountNameTextView.text =
                        accountDetail.bluetoothName ?: accountCacheData?.account?.name
                }
                is Account.Detail.Rekeyed, is Account.Detail.RekeyedAuth -> {
                    binding.oldAccountLabelTextView.setText(R.string.old_ledger)
                    binding.oldAccountNameTextView.text = accountCacheData?.account?.name
                }
            }
        } else {
            binding.oldAccountLabelTextView.setText(R.string.old_ledger)

            val authAccount = accountCacheManager.getAuthAccount(accountCacheData?.account)
            binding.oldAccountNameTextView.text = authAccount?.name ?: authAddress.toShortenedAddress()
        }

        binding.newLedgerNameTextView.text = args.rekeyAdminAddress.toShortenedAddress()
    }

    private fun setupCollapsibleAccountView() {
        rekeyConfirmationViewModel.getAccountCacheData(args.rekeyAddress)?.let {
            binding.collapsibleAccountView.setAccountBalanceInformation(it)
        }
    }

    private fun setupFee(fee: Long) {
        binding.feeTextView.text = getString(R.string.total_rekeying_fee, fee.formatAsAlgoString())
    }

    private fun onConfirmClick() {
        loadingDialogFragment = LoadingDialogFragment.show(childFragmentManager, R.string.rekeying_account)
        accountCacheData?.let { safeAccountCacheData ->
            val rekeyTx = TransactionData.Rekey(safeAccountCacheData, args.rekeyAdminAddress, args.ledgerDetail)
            sendTransaction(rekeyTx)
        }
    }
}
