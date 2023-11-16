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

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.ui.common.walletconnect.WalletConnectArbitraryDataSummaryCardView
import com.algorand.android.ui.wcarbitrarydatarequest.WalletConnectArbitraryDataListItem.ItemType.ARBITRARY_DATA
import com.algorand.android.ui.wcarbitrarydatarequest.viewholder.BaseWalletConnectArbitraryDataViewHolder
import com.algorand.android.ui.wcarbitrarydatarequest.viewholder.WalletConnectArbitraryDataRequestViewHolder

class WalletConnectArbitraryDataAdapter(
    private val listener: Listener
) : ListAdapter<WalletConnectArbitraryDataListItem, BaseWalletConnectArbitraryDataViewHolder>(
    BaseDiffUtil<WalletConnectArbitraryDataListItem>()
) {

    private val arbitraryDataShowDetailClick =
        WalletConnectArbitraryDataSummaryCardView.OnShowDetailClickListener {
            listener.onArbitraryDataClick(it)
        }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).getItemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseWalletConnectArbitraryDataViewHolder {
        return when (viewType) {

            ARBITRARY_DATA.ordinal -> createArbitraryDataViewHolder(
                parent,
                arbitraryDataShowDetailClick
            )

            else -> throw IllegalArgumentException("$logTag: Item View Type is Unknown.")
        }
    }

    override fun onBindViewHolder(holder: BaseWalletConnectArbitraryDataViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    private fun createArbitraryDataViewHolder(
        parent: ViewGroup,
        onShowDetailClickListener: WalletConnectArbitraryDataSummaryCardView.OnShowDetailClickListener
    ): BaseWalletConnectArbitraryDataViewHolder {
        return WalletConnectArbitraryDataRequestViewHolder.create(parent, onShowDetailClickListener)
    }

    interface Listener {
        fun onArbitraryDataClick(arbitraryData: WalletConnectArbitraryData) {}
    }

    companion object {
        private val logTag = WalletConnectArbitraryDataAdapter::class.java.simpleName
    }
}
