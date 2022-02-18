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

package com.algorand.android.ui.ledgersearch

import android.bluetooth.BluetoothDevice
import com.algorand.android.models.RecyclerListItem

sealed class LedgerBaseItem : RecyclerListItem {

    data class LedgerItem(val device: BluetoothDevice) : LedgerBaseItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is LedgerItem && device.address == other.device.address
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is LedgerItem && this == other
        }
    }

    object LedgerLoadingItem : LedgerBaseItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is LedgerLoadingItem
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is LedgerLoadingItem
        }
    }
}
