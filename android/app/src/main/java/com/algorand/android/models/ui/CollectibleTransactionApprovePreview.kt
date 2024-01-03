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

package com.algorand.android.models.ui

import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview

data class CollectibleTransactionApprovePreview(
    val senderAccountPublicKey: String,
    val senderAccountDisplayText: String,
    val senderAccountIconDrawablePreview: AccountIconDrawablePreview,
    val receiverAccountPublicKey: String,
    val receiverAccountDisplayText: String,
    val receiverAccountIconResource: AccountIconDrawablePreview?,
    val formattedTransactionFee: String,
    val isOptOutGroupVisible: Boolean,
    val nftDomainName: String?,
    val nftDomainLogoUrl: String?
)
