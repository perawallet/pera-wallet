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

package com.algorand.android.ui.register.ledger.verify

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import androidx.navigation.navGraphViewModels
import com.algorand.android.MainViewModel
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentVerifyLedgerAddressBinding
import com.algorand.android.ledger.LedgerBleOperationManager
import com.algorand.android.ledger.operations.VerifyAddressOperation
import com.algorand.android.models.Account
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.LedgerBleResult
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.register.ledger.PairLedgerNavigationViewModel
import com.algorand.android.utils.Event
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class VerifyLedgerAddressFragment : DaggerBaseFragment(R.layout.fragment_verify_ledger_address) {

    @Inject
    lateinit var ledgerBleOperationManager: LedgerBleOperationManager

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentVerifyLedgerAddressBinding::bind)

    private val mainViewModel: MainViewModel by activityViewModels()

    private val adapter = VerifiableLedgerAddressesAdapter()

    private val verifyLedgerAddressViewModel: VerifyLedgerAddressViewModel by viewModels()

    private val pairLedgerNavigationViewModel: PairLedgerNavigationViewModel by navGraphViewModels(
        R.id.pairLedgerNavigation
    ) {
        defaultViewModelProviderFactory
    }

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val listObserver = Observer<List<VerifyLedgerAddressListItem>> { list ->
        adapter.submitList(list)
    }

    private val isAllOperationDoneObserver = Observer<Event<Boolean>> { isAllOperationDoneEvent ->
        isAllOperationDoneEvent.consume()?.let { isAllOperationDone ->
            binding.confirmationButton.isVisible = isAllOperationDone
        }
    }

    private val ledgerResultCollector: suspend (Event<LedgerBleResult>?) -> Unit = { ledgerBleResultEvent ->
        ledgerBleResultEvent?.consume()?.let { ledgerBleResult ->
            when (ledgerBleResult) {
                is LedgerBleResult.OnLedgerDisconnected -> {
                    retryCurrentOperation()
                }
                is LedgerBleResult.AppErrorResult -> {
                    showGlobalError(
                        errorMessage = getString(ledgerBleResult.errorMessageId),
                        title = getString(ledgerBleResult.titleResId)
                    )
                    retryCurrentOperation()
                }
                is LedgerBleResult.LedgerErrorResult -> {
                    showGlobalError(errorMessage = ledgerBleResult.errorMessage)
                    retryCurrentOperation()
                }
                is LedgerBleResult.OperationCancelledResult -> {
                    verifyLedgerAddressViewModel.onCurrentOperationDone(isVerified = false)
                }
                is LedgerBleResult.VerifyPublicKeyResult -> {
                    verifyLedgerAddressViewModel.onCurrentOperationDone(isVerified = ledgerBleResult.isVerified)
                }
            }
        }
    }

    // </editor-fold>

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupLedgerBleOperationManager()
        setupViewModel()
        setupLedgerAddressesRecyclerView()
        initObservers()
        binding.confirmationButton.setOnClickListener { onConfirmationClick() }
    }

    private fun setupLedgerBleOperationManager() {
        ledgerBleOperationManager.setup(viewLifecycleOwner.lifecycle)
    }

    private fun setupLedgerAddressesRecyclerView() {
        binding.ledgerAddressesRecyclerView.adapter = adapter
    }

    private fun setupViewModel() {
        verifyLedgerAddressViewModel.createListAuthLedgerAccounts(
            authLedgerAccounts = pairLedgerNavigationViewModel.getSelectedAuthAccounts()
        )
    }

    private fun startVerifyOperation(account: Account?) {
        if (account == null) {
            return
        }
        val currentOperatedLedger = pairLedgerNavigationViewModel.pairedLedger
        if (currentOperatedLedger == null) {
            sendErrorLog("Ledger is not found while operating startVerifyOperation function.")
            return
        }
        if (account.detail is Account.Detail.Ledger) {
            ledgerBleOperationManager.startLedgerOperation(
                VerifyAddressOperation(currentOperatedLedger, account.detail.positionInLedger, account.address)
            )
        } else {
            sendErrorLog("Other than Ledger Account is in the verify operation.")
        }
    }

    private fun retryCurrentOperation() {
        viewLifecycleOwner.lifecycleScope.launch {
            delay(RETRY_DELAY)
            startVerifyOperation(verifyLedgerAddressViewModel.awaitingLedgerAccount)
        }
    }

    private fun initObservers() {
        verifyLedgerAddressViewModel.currentLedgerAddressesListLiveData.observe(viewLifecycleOwner, listObserver)

        verifyLedgerAddressViewModel.isVerifyOperationsDoneLiveData.observe(
            viewLifecycleOwner,
            isAllOperationDoneObserver
        )

        viewLifecycleOwner.lifecycleScope.launch {
            ledgerBleOperationManager.ledgerBleResultFlow.collectLatest(ledgerResultCollector)
        }

        verifyLedgerAddressViewModel.awaitingLedgerAccountLiveData.observe(viewLifecycleOwner) {
            startVerifyOperation(it)
        }
    }

    private fun onConfirmationClick() {
        val selectedVerifiedAccounts = verifyLedgerAddressViewModel.getSelectedVerifiedAccounts(
            pairLedgerNavigationViewModel.selectedAccounts
        )
        selectedVerifiedAccounts.forEach { selectedAccount ->
            val creationType = if (selectedAccount.type == Account.Type.REKEYED) {
                CreationType.REKEYED
            } else {
                CreationType.LEDGER
            }
            mainViewModel.addAccount(selectedAccount, creationType)
        }
        nav(VerifyLedgerAddressFragmentDirections.actionVerifyLedgerAddressFragmentToVerifyLedgerInfoFragment())
    }

    companion object {
        private const val RETRY_DELAY = 1000L
    }
}
