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

package com.algorand.android.modules.collectibles.profile.ui.model

import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.utils.Event

data class CollectibleProfilePreview(
    val isLoadingVisible: Boolean,
    val collectibleProfile: CollectibleProfile?,
    val collectibleStatusPreview: AsaStatusPreview?,
    val onTransactionLoadingEvent: Event<Unit>?,
    val onTransactionSuccess: Event<Unit>?,
    val onTransactionFailed: Event<Throwable?>?,
    val accountAddress: String
)
