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

package com.algorand.android.modules.walletconnectfallbackbrowser.domain.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.modules.walletconnectfallbackbrowser.domain.model.WalletConnectFallbackBrowser
import com.algorand.android.modules.walletconnectfallbackbrowser.domain.model.WalletConnectFallbackBrowserGroup
import javax.inject.Inject

class FallbackBrowserSelectionUseCase @Inject constructor() : BaseUseCase() {

    suspend fun getFilteredFallbackBrowserListByGroup(
        browserGroupResponse: String,
        installedApplicationPackageNameList: List<String>
    ): List<WalletConnectFallbackBrowser> {
        val browserGroup = WalletConnectFallbackBrowserGroup.getByDeeplinkResponse(browserGroupResponse)
        return WalletConnectFallbackBrowser.getBrowserListByGroup(browserGroup).filter {
            installedApplicationPackageNameList.contains(it.packageName)
        }
    }
}
