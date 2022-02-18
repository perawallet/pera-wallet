/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.models

import androidx.annotation.DrawableRes

data class TransactionRequestSenderInfo(
    val senderDisplayedAddress: String? = null,
    @DrawableRes val toAccountTypeImageResId: Int? = null,
    val toDisplayedAddress: BaseWalletConnectDisplayedAddress? = null,
    val rekeyToAccountAddress: String? = null,
    val assetInformation: TransactionRequestAssetInformation? = null,
    val appId: Long? = null,
    val onCompletion: BaseAppCallTransaction.AppOnComplete? = null,
    val appGlobalScheme: ApplicationCallStateSchema? = null,
    val appLocalScheme: ApplicationCallStateSchema? = null,
    val appExtraPages: Int? = null,
    val approvalHash: String? = null,
    val clearStateHash: String? = null,
    val warningCount: Int? = null
)
