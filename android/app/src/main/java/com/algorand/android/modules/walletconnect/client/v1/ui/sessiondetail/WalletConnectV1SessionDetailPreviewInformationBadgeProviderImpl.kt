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

package com.algorand.android.modules.walletconnect.client.v1.ui.sessiondetail

import com.algorand.android.R
import com.algorand.android.modules.walletconnect.sessiondetail.ui.mapper.WalletConnectSessionDetailInformationBadgeMapper
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewInformationBadgeProvider
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier

class WalletConnectV1SessionDetailPreviewInformationBadgeProviderImpl(
    private val informationBadgeMapper: WalletConnectSessionDetailInformationBadgeMapper
) : WalletConnectSessionDetailPreviewInformationBadgeProvider {

    override fun getInformationBadgeDetail(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreview.InformationBadge {
        return informationBadgeMapper.mapToInformationBadge(
            badgeTextResId = R.string.wc_v1,
            informationTextResId = R.string.this_session_is_using
        )
    }

    companion object {
        const val INJECTION_NAME = "walletConnectV1SessionDetailPreviewInformationBadgeProviderImplInjectionName"
    }
}
