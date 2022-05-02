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

package com.algorand.android.models

import com.algorand.android.utils.Event

// TODO: 19.04.2022 Create a model class instead of passing parameters as Pair
data class NotificationCenterPreview(
    val onGoingCollectibleDetailEvent: Event<Pair<String, Long>>?,
    val onGoingAssetDetailEvent: Event<Pair<String, Long>>?,
    val onHistoryNotAvailableEvent: Event<String>?,
    val onTransactionReceivedEvent: Event<Pair<String, Long>>?,
    val onTransactionSentEvent: Event<Pair<String, Long>>?,
    val onAssetSupportRequestEvent: Event<AssetAction>?
)
