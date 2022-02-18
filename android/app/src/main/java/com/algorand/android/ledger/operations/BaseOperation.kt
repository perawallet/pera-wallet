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

package com.algorand.android.ledger.operations

import android.bluetooth.BluetoothDevice
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.TransactionData

sealed class BaseOperation {
    abstract val bluetoothDevice: BluetoothDevice
    var nextIndex: Int = 0
}

data class VerifyAddressOperation(
    override val bluetoothDevice: BluetoothDevice,
    val indexOfAddress: Int,
    val address: String
) : BaseOperation()

data class AccountFetchAllOperation(
    override val bluetoothDevice: BluetoothDevice,
    val accounts: MutableList<AccountInformation> = mutableListOf()
) : BaseOperation()

sealed class BaseTransactionOperation(
    override val bluetoothDevice: BluetoothDevice
) : BaseOperation() {

    abstract val transactionByteArray: ByteArray?

    abstract val isRekeyedToAnotherAccount: Boolean

    abstract val accountAddress: String

    abstract val accountAuthAddress: String?
}

data class TransactionOperation(
    override val bluetoothDevice: BluetoothDevice,
    val transactionData: TransactionData
) : BaseTransactionOperation(bluetoothDevice) {

    override val transactionByteArray: ByteArray?
        get() = transactionData.transactionByteArray

    override val accountAddress: String
        get() = transactionData.accountCacheData.account.address

    override val accountAuthAddress: String?
        get() = transactionData.accountCacheData.authAddress

    override val isRekeyedToAnotherAccount: Boolean
        get() = transactionData.accountCacheData.isRekeyedToAnotherAccount()
}

data class WalletConnectTransactionOperation(
    override val bluetoothDevice: BluetoothDevice,
    val transaction: BaseWalletConnectTransaction
) : BaseTransactionOperation(bluetoothDevice) {

    override val transactionByteArray: ByteArray?
        get() = transaction.decodedTransaction

    override val accountAddress: String
        get() = transaction.signer.address?.decodedAddress.orEmpty()

    override val accountAuthAddress: String?
        get() = transaction.authAddress

    override val isRekeyedToAnotherAccount: Boolean
        get() = transaction.isRekeyedToAnotherAccount()
}
