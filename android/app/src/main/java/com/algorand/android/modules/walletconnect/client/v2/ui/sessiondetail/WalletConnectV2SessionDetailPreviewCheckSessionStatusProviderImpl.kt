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

package com.algorand.android.modules.walletconnect.client.v2.ui.sessiondetail

import com.algorand.android.R
import com.algorand.android.modules.walletconnect.sessiondetail.ui.mapper.WalletConnectSessionDetailPreviewCheckSessionStatusMapper
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewCheckSessionStatusProvider
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier

class WalletConnectV2SessionDetailPreviewCheckSessionStatusProviderImpl(
    private val checkSessionStatusMapper: WalletConnectSessionDetailPreviewCheckSessionStatusMapper
) : WalletConnectSessionDetailPreviewCheckSessionStatusProvider {

    override fun getInitialCheckSessionStatus(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreview.CheckSessionStatus {
        return checkSessionStatusMapper.mapToCheckSessionStatus(
            buttonTextResId = R.string.check_status,
            buttonTextColorResId = R.color.positive,
            isButtonEnabled = true,
            buttonStartIconResId = null
        )
    }

    override fun getLoadingStateForCheckSessionStatus(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreview.CheckSessionStatus {
        return checkSessionStatusMapper.mapToCheckSessionStatus(
            buttonTextColorResId = R.color.text_gray,
            buttonTextResId = R.string.pinging,
            isButtonEnabled = false,
            buttonStartIconResId = null
        )
    }

    override fun getSuccessStateForCheckSessionStatus(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreview.CheckSessionStatus {
        return checkSessionStatusMapper.mapToCheckSessionStatus(
            buttonTextColorResId = R.color.positive,
            buttonTextResId = R.string.active,
            isButtonEnabled = false,
            buttonStartIconResId = R.drawable.ic_check_16dp
        )
    }

    override fun getErrorStateForCheckSessionStatus(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreview.CheckSessionStatus {
        return checkSessionStatusMapper.mapToCheckSessionStatus(
            buttonTextColorResId = R.color.negative,
            buttonTextResId = R.string.failed,
            isButtonEnabled = false,
            buttonStartIconResId = R.drawable.ic_close
        )
    }

    companion object {
        const val INJECTION_NAME = "walletConnectV2SessionDetailPreviewCheckSessionStatusProviderImplInjectionName"
    }
}
