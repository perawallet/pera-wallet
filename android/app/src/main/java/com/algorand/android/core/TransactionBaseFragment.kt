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

package com.algorand.android.core

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.View
import androidx.annotation.LayoutRes
import androidx.annotation.StringRes
import androidx.lifecycle.Observer
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.customviews.LedgerLoadingDialog
import com.algorand.android.models.Account
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.models.TransactionManagerResult
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.BLE_OPEN_REQUEST_CODE
import com.algorand.android.utils.Event
import com.algorand.android.utils.LOCATION_PERMISSION_REQUEST_CODE
import com.algorand.android.utils.isBluetoothEnabled
import com.algorand.android.utils.showWithStateCheck
import javax.inject.Inject

abstract class TransactionBaseFragment(
    @LayoutRes layoutResId: Int
) : DaggerBaseFragment(layoutResId), LedgerLoadingDialog.Listener {

    @Inject
    lateinit var transactionManager: TransactionManager

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    private var bleWaitingTransactionData: TransactionData? = null
    private var ledgerLoadingDialog: LedgerLoadingDialog? = null

    abstract val transactionFragmentListener: TransactionFragmentListener

    private val transactionManagerObserver = Observer<Event<TransactionManagerResult>?> { event ->
        event?.consume()?.run {
            when (this) {
                is TransactionManagerResult.Success -> {
                    hideLoading()
                    transactionFragmentListener.onSignTransactionFinished(this.signedTransactionDetail)
                }
                is TransactionManagerResult.Error -> {
                    showTransactionError(this)
                }
                TransactionManagerResult.Loading -> {
                    transactionFragmentListener.onSignTransactionLoading()
                }
                TransactionManagerResult.LedgerWaitingForApproval -> {
                    showLedgerLoading()
                }
                TransactionManagerResult.LedgerScanFailed -> {
                    hideLoading()
                    navigateToConnectionIssueBottomSheet()
                }
            }
        }
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        transactionManager.setup(lifecycle)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        transactionManager.transactionManagerResultLiveData.observe(viewLifecycleOwner, transactionManagerObserver)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
                sendWaitingTransactionData()
            } else {
                permissionDeniedOnTransactionData(R.string.error_location_message, R.string.error_permission_title)
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == BLE_OPEN_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                sendWaitingTransactionData()
            } else {
                permissionDeniedOnTransactionData(R.string.error_bluetooth_message, R.string.error_bluetooth_title)
            }
        }
    }

    internal fun permissionDeniedOnTransactionData(@StringRes errorResId: Int, @StringRes titleResId: Int) {
        bleWaitingTransactionData = null
        showTransactionError(TransactionManagerResult.Error.Defined(AnnotatedString(errorResId), titleResId))
    }

    private fun sendWaitingTransactionData() {
        bleWaitingTransactionData?.run {
            sendTransaction(this)
        }
    }

    private fun hideLoading() {
        transactionFragmentListener.onSignTransactionLoadingFinished()
        ledgerLoadingDialog?.dismissAllowingStateLoss()
    }

    private fun showLedgerLoading() {
        ledgerLoadingDialog = LedgerLoadingDialog.createLedgerLoadingDialog()
        ledgerLoadingDialog?.showWithStateCheck(childFragmentManager)
    }

    private fun navigateToConnectionIssueBottomSheet() {
        nav(HomeNavigationDirections.actionGlobalLedgerConnectionIssueBottomSheet())
    }

    fun sendTransaction(transactionData: TransactionData) {
        val accountCacheData = transactionData.accountCacheData

        when (accountCacheData.account.type) {
            Account.Type.LEDGER, Account.Type.REKEYED, Account.Type.REKEYED_AUTH -> {
                if (isBluetoothEnabled().not()) {
                    bleWaitingTransactionData = transactionData
                    return
                }
            }
        }
        transactionManager.signTransaction(transactionData)
    }

    private fun showTransactionError(error: TransactionManagerResult.Error) {
        hideLoading()
        val (title, errorMessage) = error.getMessage(requireContext())
        showGlobalError(errorMessage, title)
        transactionManager.manualStopAllResources()
    }

    override fun onLedgerLoadingCancelled() {
        hideLoading()
        transactionManager.manualStopAllResources()
    }

    interface TransactionFragmentListener {
        fun onSignTransactionLoadingFinished() {
            // This blank line is here to disable mandatory overriding operation
        }

        fun onSignTransactionLoading() {
            // This blank line is here to disable mandatory overriding operation
        }

        fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail)
    }
}
