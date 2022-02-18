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

package com.algorand.android.utils.walletconnect

import com.algorand.android.models.BaseWalletConnectErrorProvider

/**
 * This class will be provided by hilt and its only purpose is to support multi language error messages
 */
data class WalletConnectTransactionErrorProvider(
    val rejected: BaseWalletConnectErrorProvider.RequestRejectedErrorProvider,
    val unauthorized: BaseWalletConnectErrorProvider.UnauthorizedRequestErrorProvider,
    val unsupported: BaseWalletConnectErrorProvider.UnsupportedRequestErrorProvider,
    val invalidInput: BaseWalletConnectErrorProvider.InvalidInputErrorProvider
)
