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

package com.algorand.android.ui.wcarbitrarydatarequest.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemWalletConnectArbitraryDataRequestBinding
import com.algorand.android.ui.common.walletconnect.WalletConnectArbitraryDataSummaryCardView
import com.algorand.android.ui.wcarbitrarydatarequest.WalletConnectArbitraryDataListItem
import com.algorand.android.ui.wcarbitrarydatarequest.WalletConnectArbitraryDataListItem.ArbitraryDataItem

class WalletConnectArbitraryDataRequestViewHolder(
    private val binding: ItemWalletConnectArbitraryDataRequestBinding,
    private val listener: WalletConnectArbitraryDataSummaryCardView.OnShowDetailClickListener
) : BaseWalletConnectArbitraryDataViewHolder(binding.root) {

    override fun bind(item: WalletConnectArbitraryDataListItem) {
        if (item !is ArbitraryDataItem) return
        binding.summaryCardView.initArbitraryData(item, listener)
    }

    companion object {
        fun create(
            parent: ViewGroup,
            listener: WalletConnectArbitraryDataSummaryCardView.OnShowDetailClickListener
        ): WalletConnectArbitraryDataRequestViewHolder {
            val binding = ItemWalletConnectArbitraryDataRequestBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return WalletConnectArbitraryDataRequestViewHolder(binding, listener)
        }
    }
}
