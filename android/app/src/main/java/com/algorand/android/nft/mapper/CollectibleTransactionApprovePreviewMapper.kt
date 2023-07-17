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

package com.algorand.android.nft.mapper

import com.algorand.android.models.ui.CollectibleTransactionApprovePreview
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import javax.inject.Inject

class CollectibleTransactionApprovePreviewMapper @Inject constructor() {

    @SuppressWarnings("LongParameterList")
    fun mapToPreview(
        senderAccountPublicKey: String,
        senderAccountDisplayText: String,
        senderAccountIconResource: AccountIconDrawablePreview,
        receiverAccountPublicKey: String,
        receiverAccountDisplayText: String,
        receiverAccountIconDrawablePreview: AccountIconDrawablePreview?,
        formattedTransactionFee: String,
        isOptOutGroupVisible: Boolean,
        nftDomainName: String?,
        nftDomainLogoUrl: String?
    ): CollectibleTransactionApprovePreview {
        return CollectibleTransactionApprovePreview(
            senderAccountPublicKey = senderAccountPublicKey,
            senderAccountDisplayText = senderAccountDisplayText,
            senderAccountIconDrawablePreview = senderAccountIconResource,
            receiverAccountPublicKey = receiverAccountPublicKey,
            receiverAccountDisplayText = receiverAccountDisplayText,
            receiverAccountIconResource = receiverAccountIconDrawablePreview,
            formattedTransactionFee = formattedTransactionFee,
            isOptOutGroupVisible = isOptOutGroupVisible,
            nftDomainName = nftDomainName,
            nftDomainLogoUrl = nftDomainLogoUrl
        )
    }
}
