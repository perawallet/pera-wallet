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

package com.algorand.android.modules.inapppin.pin.ui.model

import com.algorand.android.utils.Event

data class InAppPinPreview(
    val pinEntryPreview: PinEntryPreview?,
    val pinPenaltyPreview: PinPenaltyPreview?
) {

    val isBackPressDispatchersEnabled: Boolean get() = pinPenaltyPreview != null

    val isPinPenaltyPreviewVisible get() = pinPenaltyPreview != null

    val isPinEntryPreviewVisible get() = pinEntryPreview != null

    data class PinEntryPreview(
        val askBiometricAuthEvent: Event<Unit>?,
        val popInAppPinNavigationEvent: Event<Unit>?,
        val onPinCodeIncorrectEvent: Event<Unit>?,
        val onStartPenaltyTimeEvent: Event<Unit>?
    )

    data class PinPenaltyPreview(
        val formattedRemainingPenaltyTime: String,
        val removeAllDataEvent: Event<Unit>?,
        val restartActivityEvent: Event<Unit>?
    )
}
