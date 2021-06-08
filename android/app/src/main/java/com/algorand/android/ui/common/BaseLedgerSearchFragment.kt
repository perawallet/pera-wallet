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

package com.algorand.android.ui.common

import android.app.Activity.RESULT_OK
import android.bluetooth.BluetoothDevice
import android.content.Intent
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.os.Bundle
import android.view.View
import androidx.annotation.StringRes
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.coroutineScope
import com.algorand.android.MainNavigationDirections.Companion.actionGlobalLedgerTroubleshootingFragment
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.LoadingDialogFragment
import com.algorand.android.databinding.FragmentLedgerSearchBinding
import com.algorand.android.ledger.LedgerBleOperationManager
import com.algorand.android.ledger.operations.AccountFetchAllOperation
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.LedgerBleResult
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.ledgersearch.LedgerSearchAdapter
import com.algorand.android.ui.ledgersearch.LedgerSearchViewModel
import com.algorand.android.utils.BLE_OPEN_REQUEST_CODE
import com.algorand.android.utils.Event
import com.algorand.android.utils.LOCATION_PERMISSION_REQUEST_CODE
import com.algorand.android.utils.isBluetoothEnabled
import com.algorand.android.utils.viewbinding.viewBinding
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

abstract class BaseLedgerSearchFragment(
    @StringRes titleResId: Int
) : DaggerBaseFragment(R.layout.fragment_ledger_search) {

    @Inject
    lateinit var ledgerBleOperationManager: LedgerBleOperationManager

    abstract fun onLedgerConnected(
        accountList: List<AccountInformation>,
        ledgerDevice: BluetoothDevice
    )

    private var isBluetoothEnableRequestFailed = false
    private var isLocationPermissionRequestFailed = false
    private var loadingDialogFragment: LoadingDialogFragment? = null

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = titleResId,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = { navBack() }
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentLedgerSearchBinding::bind)

    private val ledgerSearchViewModel: LedgerSearchViewModel by viewModels()

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val ledgerDevicesObserver = Observer<Set<BluetoothDevice>> { ledgerDevices ->
        ledgerSearchAdapter?.setItems(ledgerDevices)
    }

    private val ledgerResultObserver: (suspend (Event<LedgerBleResult>?) -> Unit) = { bluetoothResultEvent ->
        bluetoothResultEvent?.consume()?.run {
            when (this) {
                is LedgerBleResult.AccountResult -> {
                    onLedgerConnected(accountList, bluetoothDevice)
                }
                is LedgerBleResult.AppErrorResult -> {
                    showError(getString(errorMessageId))
                }
                is LedgerBleResult.LedgerErrorResult -> {
                    showError(errorMessage)
                }
            }
        }
    }

    // </editor-fold>

    private var ledgerSearchAdapter: LedgerSearchAdapter? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        setupLedgerBleOperationManager()
        initObservers()
        binding.troubleshootButton.setOnClickListener { onTroubleshootClick() }
    }

    private fun setupLedgerBleOperationManager() {
        ledgerBleOperationManager.setup(viewLifecycleOwner.lifecycle)
    }

    private fun setupRecyclerView() {
        if (ledgerSearchAdapter == null) {
            ledgerSearchAdapter = LedgerSearchAdapter(::connectLedger)
        }

        binding.ledgersRecyclerView.adapter = ledgerSearchAdapter
    }

    override fun onResume() {
        super.onResume()
        if (isBluetoothEnableRequestFailed.not() && isLocationPermissionRequestFailed.not()) {
            startBluetoothSearch()
        }
    }

    override fun onPause() {
        super.onPause()
        ledgerSearchViewModel.stopBluetoothSearch()
    }

    private fun initObservers() {
        ledgerSearchViewModel.ledgerDevicesLiveData.observe(viewLifecycleOwner, ledgerDevicesObserver)
        viewLifecycleOwner.lifecycle.coroutineScope.launch {
            ledgerBleOperationManager.ledgerBleResultFlow.collect(action = ledgerResultObserver)
        }
    }

    private fun connectLedger(bluetoothDevice: BluetoothDevice) {
        setLoadingVisibility(isVisible = true)
        ledgerBleOperationManager.startLedgerOperation(AccountFetchAllOperation(bluetoothDevice))
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            if (grantResults.firstOrNull() == PERMISSION_GRANTED) {
                startBluetoothSearch()
            } else {
                isLocationPermissionRequestFailed = true
                showError(getString(R.string.error_location_message), R.string.error_permission_title)
                navBack()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == BLE_OPEN_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                startBluetoothSearch()
            } else {
                isBluetoothEnableRequestFailed = true
                showError(getString(R.string.error_bluetooth_message), R.string.error_bluetooth_title)
                navBack()
            }
        }
    }

    private fun showError(errorMessage: String, @StringRes titleResId: Int = R.string.error_default_title) {
        setLoadingVisibility(isVisible = false)
        showGlobalError(errorMessage, getString(titleResId))
    }

    private fun startBluetoothSearch() {
        if (isBluetoothEnabled()) {
            ledgerSearchViewModel.startBluetoothSearch()
        }
    }

    fun setLoadingVisibility(isVisible: Boolean) {
        if (isVisible) {
            loadingDialogFragment = LoadingDialogFragment.show(childFragmentManager, R.string.connecting_to_ledger)
        } else {
            loadingDialogFragment?.dismissAllowingStateLoss()
        }
    }

    private fun onTroubleshootClick() {
        nav(actionGlobalLedgerTroubleshootingFragment())
    }
}
