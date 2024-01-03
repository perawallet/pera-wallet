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

package com.algorand.android.models.builder

import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.ui.wcarbitrarydatarequest.WalletConnectArbitraryDataListItem
import javax.inject.Inject

class WalletConnectArbitraryDataListBuilder @Inject constructor(
    private val arbitraryDataSummaryUIBuilder: WalletConnectArbitraryDataSummaryUIBuilder
) {

    fun create(
        arbitraryDataList: List<WalletConnectArbitraryData>
    ): List<WalletConnectArbitraryDataListItem> {
        return mutableListOf<WalletConnectArbitraryDataListItem>().apply {
            addAll(
                arbitraryDataList.map {
                    WalletConnectArbitraryDataListItem.ArbitraryDataItem(
                        it,
                        arbitraryDataSummaryUIBuilder.buildArbitraryDataSummary(it)
                    )
                }
            )
        }
    }

    fun createArbitraryDataItems(
        arbitraryDataList: List<WalletConnectArbitraryData>
    ): List<WalletConnectArbitraryDataListItem> {
        return arbitraryDataList.map { arbitraryData ->
            WalletConnectArbitraryDataListItem.ArbitraryDataItem(
                arbitraryData,
                arbitraryDataSummaryUIBuilder.buildArbitraryDataSummary(arbitraryData)
            )
        }
    }
}
