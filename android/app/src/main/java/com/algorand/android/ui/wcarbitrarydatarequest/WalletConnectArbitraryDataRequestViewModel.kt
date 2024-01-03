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

package com.algorand.android.ui.wcarbitrarydatarequest

import android.content.SharedPreferences
import android.os.Bundle
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LiveData
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.R
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.models.WalletConnectRequest.WalletConnectArbitraryDataRequest
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.builder.WalletConnectArbitraryDataListBuilder
import com.algorand.android.modules.walletconnect.domain.WalletConnectErrorProvider
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.ui.wcarbitrarydatarequest.ui.model.WalletConnectArbitraryDataRequestPreview
import com.algorand.android.ui.wcarbitrarydatarequest.ui.usecase.WalletConnectArbitraryDataRequestPreviewUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.preference.getFirstWalletConnectRequestBottomSheetShown
import com.algorand.android.utils.preference.setFirstWalletConnectRequestBottomSheetShown
import com.algorand.android.utils.walletconnect.WalletConnectArbitraryDataSignManager
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class WalletConnectArbitraryDataRequestViewModel @Inject constructor(
    private val walletConnectManager: WalletConnectManager,
    private val errorProvider: WalletConnectErrorProvider,
    private val sharedPreferences: SharedPreferences,
    private val walletConnectArbitraryDataSignManager: WalletConnectArbitraryDataSignManager,
    private val arbitraryDataListBuilder: WalletConnectArbitraryDataListBuilder,
    private val walletConnectArbitraryDataRequestPreviewUseCase: WalletConnectArbitraryDataRequestPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val requestResultLiveData: LiveData<Event<Resource<AnnotatedString>>>
        get() = walletConnectManager.requestResultLiveData

    val signResultLiveData: LiveData<WalletConnectSignResult>
        get() = walletConnectArbitraryDataSignManager.signResultLiveData

    val arbitraryData: WalletConnectArbitraryDataRequest?
        get() = walletConnectManager.wcRequest as? WalletConnectArbitraryDataRequest

    private val walletConnectSession: WalletConnectSession?
        get() = arbitraryData?.session

    private val shouldSkipConfirmation = savedStateHandle.getOrElse(SHOULD_SKIP_CONFIRMATION_KEY, false)

    private val _walletConnectArbitraryDataRequestPreviewFlow = MutableStateFlow(getInitialPreview())
    val walletConnectArbitraryDataRequestPreviewFlow: StateFlow<WalletConnectArbitraryDataRequestPreview>
        get() = _walletConnectArbitraryDataRequestPreviewFlow

    fun setupWalletConnectSignManager(lifecycle: Lifecycle) {
        walletConnectArbitraryDataSignManager.setup(lifecycle)
    }

    fun rejectRequest() {
        viewModelScope.launch {
            arbitraryData?.let {
                walletConnectManager.rejectRequest(
                    sessionIdentifier = it.session.sessionIdentifier,
                    requestId = it.requestId,
                    errorResponse = errorProvider.getUserRejectionError()
                )
            }
        }
    }

    fun shouldShowFirstRequestBottomSheet(): Boolean {
        return !sharedPreferences.getFirstWalletConnectRequestBottomSheetShown().also {
            sharedPreferences.setFirstWalletConnectRequestBottomSheetShown()
        }
    }

    fun signArbitraryDataRequest(arbitraryData: WalletConnectArbitraryDataRequest) {
        viewModelScope.launch {
            walletConnectArbitraryDataSignManager.signArbitraryData(arbitraryData)
        }
    }

    fun signArbitraryData(arbitraryData: WalletConnectArbitraryDataRequest) {
        viewModelScope.launch {
            walletConnectArbitraryDataSignManager.signArbitraryData(arbitraryData)
        }
    }

    fun processWalletConnectSignResult(result: WalletConnectSignResult) {
        viewModelScope.launch {
            walletConnectManager.processWalletConnectSignResult(result)
        }
    }

    fun stopAllResources() {
        walletConnectArbitraryDataSignManager.manualStopAllResources()
    }

    fun isBluetoothNeededToSignTxns(arbitraryData: WalletConnectArbitraryDataRequest): Boolean {
        return walletConnectArbitraryDataRequestPreviewUseCase.isBluetoothNeededToSignTxns(arbitraryData)
    }

    fun handleStartDestinationAndArgs(arbitraryDataList: List<WalletConnectArbitraryDataListItem>): Pair<Int, Bundle?> {
        val startDestination = if (
            arbitraryDataList.count() == 1 &&
            arbitraryDataList.first() is WalletConnectArbitraryDataListItem.ArbitraryDataItem
        ) {
            R.id.walletConnectSingleArbitraryDataFragment
        } else {
            R.id.walletConnectMultipleArbitraryDataFragment
        }

        val startDestinationArgs = when (startDestination) {
            R.id.walletConnectSingleArbitraryDataFragment -> {
                Bundle().apply { putParcelable(SINGLE_ARBITRARY_DATA_KEY, arbitraryDataList.first()) }
            }

            R.id.walletConnectMultipleArbitraryDataFragment -> {
                Bundle().apply { putParcelableArray(MULTIPLE_ARBITRARY_DATA_KEY, arbitraryDataList.toTypedArray()) }
            }

            else -> null
        }

        return Pair(startDestination, startDestinationArgs)
    }

    fun createArbitraryDataListItems(
        arbitraryDataList: List<WalletConnectArbitraryData>
    ): List<WalletConnectArbitraryDataListItem> {
        return arbitraryDataListBuilder.createArbitraryDataItems(arbitraryDataList)
    }

    fun onArbitraryDataConfirmed() {
        viewModelScope.launch {
            val preview = walletConnectArbitraryDataRequestPreviewUseCase.updatePreviewWithLaunchBackBrowserNavigation(
                shouldSkipConfirmation = shouldSkipConfirmation,
                walletConnectSession = walletConnectSession,
                preview = _walletConnectArbitraryDataRequestPreviewFlow.value
            )
            _walletConnectArbitraryDataRequestPreviewFlow.emit(preview)
        }
    }

    private fun getInitialPreview(): WalletConnectArbitraryDataRequestPreview {
        return walletConnectArbitraryDataRequestPreviewUseCase.getInitialWalletConnectArbitraryDataRequestPreview()
    }

    companion object {
        private const val MULTIPLE_ARBITRARY_DATA_KEY = "arbitraryDatas"
        private const val SINGLE_ARBITRARY_DATA_KEY = "arbitraryData"
        private const val SHOULD_SKIP_CONFIRMATION_KEY = "shouldSkipConfirmation"
    }
}
