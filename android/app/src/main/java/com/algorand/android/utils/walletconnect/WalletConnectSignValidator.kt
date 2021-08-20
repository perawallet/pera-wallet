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

package com.algorand.android.utils.walletconnect

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransaction
import javax.inject.Inject

class WalletConnectSignValidator @Inject constructor() {

    fun canTransactionBeSigned(transaction: WalletConnectTransaction): WalletConnectSignResult {
        return with(transaction) {
            when {
                areThereAnyMultisigTransaction(transactionList) -> onMultisigTransactionFound()
                areThereAnyUnsignableTransaction(transactionList) -> onUnsignableTransactionFound()
                else -> WalletConnectSignResult.CanBeSigned
            }
        }
    }

    private fun onUnsignableTransactionFound(): WalletConnectSignResult.Error {
        return WalletConnectSignResult.Error.Defined(AnnotatedString(R.string.the_requested_operation_and))
    }

    private fun onMultisigTransactionFound(): WalletConnectSignResult.Error {
        // TODO Change error res id
        return WalletConnectSignResult.Error.Defined(AnnotatedString(R.string.the_wallet_does_not_support))
    }

    private fun areThereAnyUnsignableTransaction(groupedTxnList: List<List<BaseWalletConnectTransaction>>): Boolean {
        return groupedTxnList.flatten().any {
            it.signer is WalletConnectSigner.Unsignable
        }
    }

    private fun areThereAnyMultisigTransaction(groupedTxnList: List<List<BaseWalletConnectTransaction>>): Boolean {
        return groupedTxnList.flatten().any {
            it.signer is WalletConnectSigner.Multisig
        }
    }
}
