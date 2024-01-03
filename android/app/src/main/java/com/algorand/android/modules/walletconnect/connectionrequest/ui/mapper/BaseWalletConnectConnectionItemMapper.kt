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

import androidx.annotation.PluralsRes
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WalletConnectConnectionNetworkItem
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

    fun mapToTitleItem(
        @PluralsRes titleTextResId: Int,
        memberCount: Int
    ): BaseWalletConnectConnectionItem.TitleItem {
        return BaseWalletConnectConnectionItem.TitleItem(
            titleTextResId = titleTextResId,
            memberCount = memberCount
        )
    }

    fun mapToAccountItem(
        accountAddress: String,
        accountIconDrawablePreview: AccountIconDrawablePreview,
        accountDisplayName: AccountDisplayName?,
        buttonState: AccountAssetItemButtonState,
        isChecked: Boolean
    ): BaseWalletConnectConnectionItem.AccountItem {
        return BaseWalletConnectConnectionItem.AccountItem(
            accountAddress = accountAddress,
            accountIconDrawablePreview = accountIconDrawablePreview,
            accountDisplayName = accountDisplayName,
            buttonState = buttonState,
            isChecked = isChecked
        )
    }

    fun mapToWalletConnectConnectionNetworkItem(
        networkCount: Int,
        walletConnectConnectionNetworkList: List<WalletConnectConnectionNetworkItem>,
    ): BaseWalletConnectConnectionItem.NetworkItem {
        return BaseWalletConnectConnectionItem.NetworkItem(
            networkCount = networkCount,
            networkList = walletConnectConnectionNetworkList
        )
    }

    fun mapToEventItem(
        eventCount: Int,
        eventList: List<String>
    ): BaseWalletConnectConnectionItem.EventItem {
        return BaseWalletConnectConnectionItem.EventItem(
            eventCount = eventCount,
            eventList = eventList
        )
    }
}
