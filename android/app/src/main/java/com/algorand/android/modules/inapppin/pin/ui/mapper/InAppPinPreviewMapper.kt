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

package com.algorand.android.modules.inapppin.pin.ui.mapper

import com.algorand.android.modules.inapppin.pin.ui.model.InAppPinPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class InAppPinPreviewMapper @Inject constructor() {

    fun mapToInAppPinPreview(
        pinEntryPreview: InAppPinPreview.PinEntryPreview? = null,
        pinPenaltyPreview: InAppPinPreview.PinPenaltyPreview? = null
    ): InAppPinPreview {
        return InAppPinPreview(
            pinEntryPreview = pinEntryPreview,
            pinPenaltyPreview = pinPenaltyPreview
        )
    }

    fun mapToPinEntryPreview(
        askBiometricAuthEvent: Event<Unit>? = null,
        popInAppPinNavigationEvent: Event<Unit>? = null,
        onPinCodeIncorrectEvent: Event<Unit>? = null,
        onStartPenaltyTimeEvent: Event<Unit>? = null
    ): InAppPinPreview.PinEntryPreview {
        return InAppPinPreview.PinEntryPreview(
            askBiometricAuthEvent = askBiometricAuthEvent,
            popInAppPinNavigationEvent = popInAppPinNavigationEvent,
            onPinCodeIncorrectEvent = onPinCodeIncorrectEvent,
            onStartPenaltyTimeEvent = onStartPenaltyTimeEvent
        )
    }

    fun mapToPinPenaltyPreview(
        formattedRemainingPenaltyTime: String,
        removeAllDataEvent: Event<Unit>? = null,
        restartActivityEvent: Event<Unit>? = null
    ): InAppPinPreview.PinPenaltyPreview {
        return InAppPinPreview.PinPenaltyPreview(
            formattedRemainingPenaltyTime = formattedRemainingPenaltyTime,
            removeAllDataEvent = removeAllDataEvent,
            restartActivityEvent = restartActivityEvent
        )
    }
}
