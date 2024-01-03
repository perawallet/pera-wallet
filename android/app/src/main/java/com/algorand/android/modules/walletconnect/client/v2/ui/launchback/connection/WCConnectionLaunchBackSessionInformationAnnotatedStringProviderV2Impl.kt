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

package com.algorand.android.modules.walletconnect.client.v2.ui.launchback.connection

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WCConnectionLaunchBackSessionInformationAnnotatedStringProvider
import com.algorand.android.utils.TXN_DATE_PATTERN
import com.algorand.android.utils.format
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp

class WCConnectionLaunchBackSessionInformationAnnotatedStringProviderV2Impl :
    WCConnectionLaunchBackSessionInformationAnnotatedStringProvider {

    override suspend fun provideAnnotatedString(sessionDetail: WalletConnect.SessionDetail): AnnotatedString {
        val formattedExpirationDate = sessionDetail.expiry?.seconds
            ?.getZonedDateTimeFromTimeStamp()
            ?.format(TXN_DATE_PATTERN)
            .orEmpty()

        return AnnotatedString(
            stringResId = R.string.this_session_is_valid_until,
            replacementList = listOf("session_expiry_date" to formattedExpirationDate),
            customAnnotationList = listOf("color" to R.color.text_gray)
        )
    }

    companion object {
        const val INJECTION_NAME = "wcConnectionLaunchBackSessionInformationAnnotatedStringV2InjectionName"
    }
}
