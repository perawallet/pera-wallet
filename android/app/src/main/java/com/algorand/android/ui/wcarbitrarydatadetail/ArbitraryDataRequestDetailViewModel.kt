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

package com.algorand.android.ui.wcarbitrarydatadetail

import androidx.lifecycle.ViewModel
import com.algorand.android.models.ArbitraryDataRequestAmountInfo
import com.algorand.android.models.ArbitraryDataRequestDataInfo
import com.algorand.android.models.ArbitraryDataRequestInfo
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.models.builder.ArbitraryDataDetailUiBuilder
import com.algorand.android.network.AlgodInterceptor
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class ArbitraryDataRequestDetailViewModel @Inject constructor(
    private val algodInterceptor: AlgodInterceptor,
    private val arbitraryDataDetailUiBuilder: ArbitraryDataDetailUiBuilder
) : ViewModel() {

    fun getNetworkSlug(): String? {
        return algodInterceptor.currentActiveNode?.networkSlug
    }

    fun buildArbitraryDataRequestInfo(arbitraryData: WalletConnectArbitraryData):
            ArbitraryDataRequestInfo? {
        return arbitraryDataDetailUiBuilder.buildArbitraryDataRequestInfo(arbitraryData)
    }

    fun buildArbitraryDataRequestAmountInfo(arbitraryData: WalletConnectArbitraryData): ArbitraryDataRequestAmountInfo {
        return arbitraryDataDetailUiBuilder.buildArbitraryDataRequestAmountInfo(arbitraryData)
    }

    fun buildArbitraryDataRequestDataInfo(arbitraryData: WalletConnectArbitraryData): ArbitraryDataRequestDataInfo? {
        return arbitraryDataDetailUiBuilder.buildArbitraryDataRequestDataInfo(arbitraryData)
    }
}
