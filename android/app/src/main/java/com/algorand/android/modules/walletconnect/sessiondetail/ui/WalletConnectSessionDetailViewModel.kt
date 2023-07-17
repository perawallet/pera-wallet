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

package com.algorand.android.modules.walletconnect.sessiondetail.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewUseCase
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.update

@HiltViewModel
class WalletConnectSessionDetailViewModel @Inject constructor(
    private val walletConnectSessionDetailPreviewUseCase: WalletConnectSessionDetailPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val sessionIdentifier = WalletConnectSessionDetailFragmentArgs.fromSavedStateHandle(savedStateHandle)
        .sessionIdentifier

    private val _sessionDetailPreview = MutableStateFlow<WalletConnectSessionDetailPreview?>(null)
    val sessionDetailPreview: StateFlow<WalletConnectSessionDetailPreview?>
        get() = _sessionDetailPreview

    private var checkSessionStatusJob: Job? = null

    init {
        initSessionDetailPreview()
    }

    fun onExtendSessionClick() {
        viewModelScope.launchIO {
            _sessionDetailPreview.update { currentPreview ->
                if (currentPreview == null) return@launchIO
                walletConnectSessionDetailPreviewUseCase.getExtendClickedPreview(sessionIdentifier, currentPreview)
            }
        }
    }

    fun onExtendSessionApproved() {
        viewModelScope.launchIO {
            _sessionDetailPreview.value?.let { safePreview ->
                walletConnectSessionDetailPreviewUseCase.getExtendSessionApprovedPreview(
                    sessionIdentifier,
                    safePreview
                ).collectLatest { updatedPreview ->
                    _sessionDetailPreview.emit(updatedPreview)
                }
            }
        }
    }

    fun onDisconnectFromSessionClick() {
        viewModelScope.launchIO {
            _sessionDetailPreview.update { currentPreview ->
                if (currentPreview == null) return@launchIO
                walletConnectSessionDetailPreviewUseCase.getDisconnectClickedPreview(sessionIdentifier, currentPreview)
            }
        }
    }

    fun onAdvancedPermissionsClick() {
        _sessionDetailPreview.update { currentPreview ->
            if (currentPreview == null) return
            walletConnectSessionDetailPreviewUseCase.getAdvancedPermissionClickedPreview(currentPreview)
        }
    }

    private fun initSessionDetailPreview() {
        viewModelScope.launchIO {
            walletConnectSessionDetailPreviewUseCase.getInitialPreview(sessionIdentifier).collectLatest { preview ->
                _sessionDetailPreview.value = preview
            }
        }
    }

    fun onCheckStatusClick() {
        if (checkSessionStatusJob?.isActive == true) return
        checkSessionStatusJob = viewModelScope.launchIO {
            walletConnectSessionDetailPreviewUseCase.getCheckStatusClickedPreview(sessionIdentifier).collectLatest {
                _sessionDetailPreview.emit(_sessionDetailPreview.value?.copy(checkSessionStatus = it))
            }
        }
    }

    fun onAdvancedPermissionsInfoClick() {
        _sessionDetailPreview.update { currentPreview ->
            if (currentPreview == null) return
            walletConnectSessionDetailPreviewUseCase.getAdvancedPermissionsInfoClickUpdatedPreview(currentPreview)
        }
    }
}
