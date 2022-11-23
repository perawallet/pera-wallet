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

package com.algorand.android.modules.walletconnect.connectionrequest.ui.mapper

import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem
import com.algorand.android.utils.AccountDisplayName
import javax.inject.Inject

class BaseWalletConnectConnectionItemMapper @Inject constructor() {

    fun mapToDappInfoItem(
        name: String,
        url: String,
        peerIconUri: String
    ): BaseWalletConnectConnectionItem.DappInfoItem {
        return BaseWalletConnectConnectionItem.DappInfoItem(
            name = name,
            url = url,
            peerIconUri = peerIconUri
        )
    }

    fun mapToAccountsTitleItem(accountCount: Int): BaseWalletConnectConnectionItem.AccountsTitleItem {
        return BaseWalletConnectConnectionItem.AccountsTitleItem(accountCount = accountCount)
    }

    fun mapToAccountItem(
        accountAddress: String,
        accountIconResource: AccountIconResource?,
        accountDisplayName: AccountDisplayName?,
        buttonState: AccountAssetItemButtonState,
        isChecked: Boolean
    ): BaseWalletConnectConnectionItem.AccountItem {
        return BaseWalletConnectConnectionItem.AccountItem(
            accountAddress = accountAddress,
            accountIconResource = accountIconResource,
            accountDisplayName = accountDisplayName,
            buttonState = buttonState,
            isChecked = isChecked
        )
    }
}
