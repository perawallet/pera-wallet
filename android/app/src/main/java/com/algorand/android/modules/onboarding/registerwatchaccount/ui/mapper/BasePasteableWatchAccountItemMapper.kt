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

package com.algorand.android.modules.onboarding.registerwatchaccount.ui.mapper

import com.algorand.android.modules.onboarding.registerwatchaccount.ui.model.BasePasteableWatchAccountItem
import javax.inject.Inject

class BasePasteableWatchAccountItemMapper @Inject constructor() {

    fun mapToAccountAddressItem(
        accountAddress: String,
        formattedAccountAddress: String
    ): BasePasteableWatchAccountItem.AccountAddressItem {
        return BasePasteableWatchAccountItem.AccountAddressItem(
            accountAddress = accountAddress,
            shortenedAccountAddress = formattedAccountAddress
        )
    }

    fun mapToNfDomainItem(
        nfDomainName: String,
        nfDomainAccountAddress: String,
        formattedNfDomainAccountAddress: String,
        nfDomainLogoUrl: String?
    ): BasePasteableWatchAccountItem.NfDomainItem {
        return BasePasteableWatchAccountItem.NfDomainItem(
            nfDomainName = nfDomainName,
            nfDomainAccountAddress = nfDomainAccountAddress,
            nfDomainLogoUrl = nfDomainLogoUrl,
            formattedNfDomainAccountAddress = formattedNfDomainAccountAddress
        )
    }
}
