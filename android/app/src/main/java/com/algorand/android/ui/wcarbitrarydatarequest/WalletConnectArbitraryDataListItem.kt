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

package com.algorand.android.ui.wcarbitrarydatarequest

import android.os.Parcelable
import androidx.annotation.Keep
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.models.WalletConnectArbitraryDataSummary
import kotlinx.parcelize.Parcelize

@Keep
sealed class WalletConnectArbitraryDataListItem : Parcelable, RecyclerListItem {

    enum class ItemType {
        ARBITRARY_DATA
    }

    abstract val getItemType: ItemType

    @Parcelize
    @Keep
    data class ArbitraryDataItem(
        val arbitraryData: WalletConnectArbitraryData,
        val arbitraryDataSummary: WalletConnectArbitraryDataSummary
    ) : WalletConnectArbitraryDataListItem() {

        override val getItemType: ItemType
            get() = ItemType.ARBITRARY_DATA

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            if (other !is ArbitraryDataItem) return false
            val arbitraryDataMsgPack = arbitraryData.data
            val otherArbitraryDataMsgPack = other.arbitraryData.data
            return arbitraryDataMsgPack == otherArbitraryDataMsgPack
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is ArbitraryDataItem && arbitraryData == other.arbitraryData
        }
    }
}
