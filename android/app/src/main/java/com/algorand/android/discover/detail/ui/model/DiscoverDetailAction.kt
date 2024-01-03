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

package com.algorand.android.discover.detail.ui.model

import com.google.gson.annotations.SerializedName

private const val BUY_ALGO_SERIALIZATION_VALUE = "buy-algo"
private const val SWAP_FROM_ALGO_SERIALIZATION_VALUE = "swap-from-algo"
private const val SWAP_FROM_TOKEN_SERIALIZATION_VALUE = "swap-from-token"
private const val SWAP_TO_TOKEN_SERIALIZATION_VALUE = "swap-to-token"

enum class DiscoverDetailAction(val value: String?) {
    @SerializedName(BUY_ALGO_SERIALIZATION_VALUE)
    BUY_ALGO(BUY_ALGO_SERIALIZATION_VALUE),

    @SerializedName(SWAP_FROM_ALGO_SERIALIZATION_VALUE)
    SWAP_FROM_ALGO(SWAP_FROM_ALGO_SERIALIZATION_VALUE),

    @SerializedName(SWAP_FROM_TOKEN_SERIALIZATION_VALUE)
    SWAP_FROM_TOKEN(SWAP_FROM_TOKEN_SERIALIZATION_VALUE),

    @SerializedName(SWAP_TO_TOKEN_SERIALIZATION_VALUE)
    SWAP_TO_TOKEN(SWAP_TO_TOKEN_SERIALIZATION_VALUE),

    UNKNOWN(null)
}
