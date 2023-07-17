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

package com.algorand.android.modules.walletconnect.client.v2.ui.launchback.usecase

import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.utils.TXN_DATE_PATTERN
import com.algorand.android.utils.format
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import javax.inject.Inject

class GetFormattedWCSessionMaxExpirationDateUseCase @Inject constructor(
    private val walletConnectManager: WalletConnectManager
) {

    suspend operator fun invoke(sessionIdentifier: WalletConnectSessionIdentifier): String {
        return walletConnectManager.getMaxSessionExpirationDateTimeStampAsSec(sessionIdentifier)
            ?.getZonedDateTimeFromTimeStamp()
            ?.format(TXN_DATE_PATTERN)
            .orEmpty()
    }

    suspend operator fun invoke(sessionIdentifier: WalletConnect.SessionIdentifier): String {
        return walletConnectManager.getMaxSessionExpirationDateTimeStampAsSec(sessionIdentifier)
            ?.getZonedDateTimeFromTimeStamp()
            ?.format(TXN_DATE_PATTERN)
            .orEmpty()
    }
}
