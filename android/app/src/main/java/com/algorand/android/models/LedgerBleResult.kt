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

package com.algorand.android.models

import android.bluetooth.BluetoothDevice
import androidx.annotation.StringRes

sealed class LedgerBleResult {
    object LedgerWaitingForApproval : LedgerBleResult()

    data class SignedTransactionResult(
        val transactionByteArray: ByteArray
    ) : LedgerBleResult()

    data class AccountResult(
        val accountList: List<AccountInformation>,
        val bluetoothDevice: BluetoothDevice
    ) : LedgerBleResult()

    data class PublicKeyResult(
        val publicKey: String,
        val bluetoothAddress: String,
        val bluetoothName: String?
    ) : LedgerBleResult()

    data class VerifyPublicKeyResult(
        val isVerified: Boolean,
        val ledgerPublicKey: String,
        val originalPublicKey: String
    ) : LedgerBleResult()

    data class LedgerErrorResult(val errorMessage: String) : LedgerBleResult()

    data class AppErrorResult(
        @StringRes val errorMessageId: Int,
        @StringRes val titleResId: Int
    ) : LedgerBleResult()

    object OnLedgerDisconnected : LedgerBleResult()

    object OperationCancelledResult : LedgerBleResult()

    object OnBondingFailed : LedgerBleResult()

    object OnMissingBytes : LedgerBleResult()
}
