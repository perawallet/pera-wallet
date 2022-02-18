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

import java.math.BigInteger

data class TransactionRequestTransactionInfo(
    val fromDisplayedAddress: BaseWalletConnectDisplayedAddress? = null,
    val fromAccountIcon: AccountIcon? = null,
    val toDisplayedAddress: String? = null,
    val accountBalance: BigInteger? = null,
    val assetInformation: TransactionRequestAssetInformation? = null,
    val rekeyToAccountAddress: BaseWalletConnectDisplayedAddress? = null,
    val closeToAccountAddress: BaseWalletConnectDisplayedAddress? = null,
    val assetCloseToAddress: BaseWalletConnectDisplayedAddress? = null,
    val assetUnitName: String? = null,
    val assetName: String? = null,
    val reconfigurationAsset: TransactionRequestAssetInformation? = null,
    val showDeletionWarning: Boolean = false,
    val isAssetUnnamed: Boolean = false,
    val isLocalAccountSigner: Boolean = true
)
