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

import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.utils.ListQueuingHelper
import javax.inject.Inject

class WalletConnectSigningHelper @Inject constructor() : ListQueuingHelper<BaseWalletConnectTransaction, ByteArray>() {

    override val totalItemCount
        get() = transactionToSignCount

    override val currentItemIndex
        get() = dequeuedItemList.filterNotNull().size + 1

    private var transactionToSignCount = enqueuedItemCount

    override fun initItemsToBeEnqueued(enqueuedItems: List<BaseWalletConnectTransaction>) {
        transactionToSignCount = enqueuedItems.filter { it.signer.address?.decodedAddress != null }.size
        super.initItemsToBeEnqueued(enqueuedItems)
    }
}
