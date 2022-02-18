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

package com.algorand.android.ui.common

import android.app.Activity.RESULT_OK
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.StringRes
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.coroutineScope
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.LoadingDialogFragment
import com.algorand.android.databinding.FragmentLedgerSearchBinding
import com.algorand.android.ledger.LedgerBleOperationManager
import com.algorand.android.ledger.operations.AccountFetchAllOperation
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.LedgerBleResult
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.ledgersearch.LedgerBaseItem
import com.algorand.android.ui.ledgersearch.LedgerPairInstructionsBottomSheet.Companion.BLUETOOTH_DEVICE_KEY
import com.algorand.android.ui.ledgersearch.LedgerSearchAdapter
import com.algorand.android.ui.ledgersearch.LedgerSearchViewModel
import com.algorand.android.utils.Event
import com.algorand.android.utils.LOCATION_PERMISSION
import com.algorand.android.utils.isLocationEnabled
import com.algorand.android.utils.isPermissionGranted
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import java.util.Timer
import java.util.TimerTask
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

abstract class BaseLedgerSearchFragment :
    DaggerBaseFragment(R.layout.fragment_ledger_search), LoadingDialogFragment.DismissListener {

    @Inject
    lateinit var ledgerBleOperationManager: LedgerBleOperationManager

    protected abstract val fragmentId: Int

    abstract fun onLedgerConnected(accountList: List<AccountInformation>, ledgerDevice: BluetoothDevice)

    abstract fun navToPairInstructionBottomSheet(bluetoothDevice: BluetoothDevice)

    private var isBluetoothEnableRequestFailed = false
    private var isLocationPermissionRequestFailed = false
    private var loadingDialogFragment: LoadingDialogFragment? = null

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentLedgerSearchBinding::bind)

    private val ledgerSearchViewModel: LedgerSearchViewModel by viewModels()

    private val bleRequestLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
        if (it.resultCode == RESULT_OK) {
            startBluetoothSearch()
        } else {
            isBluetoothEnableRequestFailed = true
            showError(getString(R.string.error_bluetooth_message), R.string.error_bluetooth_title)
            navBack()
        }
    }

    private val locationRequestLauncher = registerForActivityResult(ActivityResultContracts.RequestPermission()) {
        if (it) {
            startBluetoothSearch()
        } else {
            isLocationPermissionRequestFailed = true
            showError(getString(R.string.error_location_message), R.string.error_permission_title)
            navBack()
        }
    }

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val ledgerDevicesObserver = Observer<List<LedgerBaseItem>> { ledgerDevices ->
        binding.progressBar.isVisible = !ledgerDevices.any { it is LedgerBaseItem.LedgerItem }
        ledgerSearchAdapter?.submitList(ledgerDevices)
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
                is LedgerBleResult.OnBondingFailed -> {
                    showError(getString(R.string.pairing_failed))
                }
                is LedgerBleResult.OnMissingBytes -> {
                    connectToLatestLedgerDelayed(device)
                }
            }
        }
    }

    // </editor-fold>

    private var ledgerSearchAdapter: LedgerSearchAdapter? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureToolbar()
        setupRecyclerView()
        setupLedgerBleOperationManager()
        initObservers()
    }

    private fun configureToolbar() {
        getAppToolbar()?.addButtonToEnd(IconButton(R.drawable.ic_question_mark, onClick = ::onTroubleshootClick))
    }

    private fun setupLedgerBleOperationManager() {
        ledgerBleOperationManager.setup(viewLifecycleOwner.lifecycle)
    }

    private fun setupRecyclerView() {
        if (ledgerSearchAdapter == null) {
            ledgerSearchAdapter = LedgerSearchAdapter(::onLedgerSelected)
        }
        binding.ledgersRecyclerView.adapter = ledgerSearchAdapter
    }

    override fun onResume() {
        super.onResume()
        if (isBluetoothEnableRequestFailed.not() && isLocationPermissionRequestFailed.not()) {
            startBluetoothSearch()
        }
        initPairInstructionResultListener()
    }

    override fun onPause() {
        super.onPause()
        ledgerSearchViewModel.stopBluetoothSearch()
    }

    override fun onLoadingDialogDismissed() {
        ledgerBleOperationManager.stopAllResources()
    }

    private fun initObservers() {
        ledgerSearchViewModel.ledgerDevicesLiveData.observe(viewLifecycleOwner, ledgerDevicesObserver)
        viewLifecycleOwner.lifecycle.coroutineScope.launch {
            ledgerBleOperationManager.ledgerBleResultFlow.collect(ledgerResultObserver)
        }
    }

    private fun initPairInstructionResultListener() {
        startSavedStateListener(fragmentId) {
            useSavedStateValue<BluetoothDevice>(BLUETOOTH_DEVICE_KEY) { bluetoothDevice ->
                connectLedger(bluetoothDevice)
            }
        }
    }

    private fun onLedgerSelected(bluetoothDevice: BluetoothDevice) {
        if (ledgerBleOperationManager.isBondingRequired(bluetoothDevice.address)) {
            navToPairInstructionBottomSheet(bluetoothDevice)
        } else {
            connectLedger(bluetoothDevice)
        }
    }

    private fun connectToLatestLedgerDelayed(device: BluetoothDevice) {
        Timer().schedule(object : TimerTask() {
            override fun run() {
                try {
                    runBlocking(Dispatchers.Main) { connectLedger(device) }
                } catch (exception: Exception) {
                    showError(getString(R.string.an_error_occured))
                }
            }
        }, MISSING_BYTE_RETRY_DELAY)
    }

    private fun connectLedger(bluetoothDevice: BluetoothDevice) {
        setLoadingVisibility(isVisible = true)
        ledgerBleOperationManager.startLedgerOperation(AccountFetchAllOperation(bluetoothDevice))
    }

    private fun showError(errorMessage: String, @StringRes titleResId: Int = R.string.error_default_title) {
        setLoadingVisibility(isVisible = false)
        showGlobalError(errorMessage, getString(titleResId))
    }

    private fun startBluetoothSearch() {
        if (arePermissionsTaken()) {
            ledgerSearchViewModel.startBluetoothSearch()
        }
    }

    fun setLoadingVisibility(isVisible: Boolean) {
        if (isVisible) {
            loadingDialogFragment = LoadingDialogFragment
                .show(childFragmentManager, R.string.connecting_to_ledger, true)
        } else {
            loadingDialogFragment?.dismissAllowingStateLoss()
        }
    }

    private fun onTroubleshootClick() {
        nav(MainNavigationDirections.actionGlobalLedgerTroubleshootFragment())
    }

    private fun arePermissionsTaken(): Boolean {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter() ?: return false
        if (context?.isPermissionGranted(LOCATION_PERMISSION) != true) {
            requestLocationPermission()
            return false
        }
        if (bluetoothAdapter.isEnabled.not()) {
            requestBluetoothPermission()
            return false
        }
        if (context?.isLocationEnabled() != true) {
            showGlobalError(getString(R.string.please_ensure), getString(R.string.bluetooth_location_services))
            navBack()
            return false
        }
        return true
    }

    private fun requestBluetoothPermission() {
        Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE).apply { bleRequestLauncher.launch(this) }
    }

    private fun requestLocationPermission() {
        locationRequestLauncher.launch(android.Manifest.permission.ACCESS_FINE_LOCATION)
    }

    companion object {
        private const val MISSING_BYTE_RETRY_DELAY = 1000L
    }
}
