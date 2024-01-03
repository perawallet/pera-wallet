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

package com.algorand.android.modules.inapppin.pin.ui.usecase

import android.app.NotificationManager
import com.algorand.android.modules.autolockmanager.domain.usecase.ShouldAppLockedUseCase.Companion.defaultLockPenaltyRemainingTimePreference
import com.algorand.android.modules.inapppin.pin.ui.mapper.InAppPinPreviewMapper
import com.algorand.android.modules.inapppin.pin.ui.model.InAppPinPreview
import com.algorand.android.modules.security.domain.usecase.GetLockAttemptCountUseCase
import com.algorand.android.modules.security.domain.usecase.GetLockPenaltyRemainingTimeUseCase
import com.algorand.android.modules.security.domain.usecase.IsBiometricActiveUseCase
import com.algorand.android.modules.security.domain.usecase.SetLockAttemptCountUseCase
import com.algorand.android.modules.security.domain.usecase.SetLockPenaltyRemainingTimeUseCase
import com.algorand.android.sharedpref.LockAttemptCountLocalSource.Companion.defaultLockAttemptCountPreference
import com.algorand.android.usecase.DeleteAllDataUseCase
import com.algorand.android.usecase.EncryptedPinUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.ONE_SECOND_IN_MILLIS
import com.algorand.android.utils.getTimeAsMinSecondPair
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn

class InAppPinPreviewUseCase @Inject constructor(
    private val inAppPinPreviewMapper: InAppPinPreviewMapper,
    private val encryptedPinUseCase: EncryptedPinUseCase,
    private val deleteAllDataUseCase: DeleteAllDataUseCase,
    private val notificationManager: NotificationManager?,
    private val getLockAttemptCountUseCase: GetLockAttemptCountUseCase,
    private val getLockPenaltyRemainingTimeUseCase: GetLockPenaltyRemainingTimeUseCase,
    private val isBiometricActiveUseCase: IsBiometricActiveUseCase,
    private val setLockAttemptCountUseCase: SetLockAttemptCountUseCase,
    private val setLockPenaltyRemainingTimeUseCase: SetLockPenaltyRemainingTimeUseCase
) {

    fun updatePreviewWithDeletionOfAllData(preview: InAppPinPreview?) = flow {
        if (preview == null) return@flow
        deleteAllDataUseCase.deleteAllData(
            notificationManager = notificationManager,
            onDeletionCompleted = {
                clearLockRelatedPreferences()
                val pinPenaltyPreview = preview.pinPenaltyPreview?.copy(restartActivityEvent = Event(Unit))
                val inAppPreview = preview.copy(pinPenaltyPreview = pinPenaltyPreview)
                emit(inAppPreview)
            }
        )
    }.flowOn(Dispatchers.IO)

    fun updatePreviewWithDeletionOfAllDataEvent(preview: InAppPinPreview?): InAppPinPreview? {
        if (preview == null) return null
        val pinPenaltyPreview = preview.pinPenaltyPreview?.copy(
            removeAllDataEvent = Event(Unit)
        )
        return preview.copy(pinPenaltyPreview = pinPenaltyPreview)
    }

    fun updatePreviewWithPenaltyPreview(preview: InAppPinPreview?) = channelFlow {
        if (preview == null) return@channelFlow
        val pinAttemptCount = getLockAttemptCountUseCase.invoke()
        val remainingTime = calculatePinPenaltyTime(pinAttemptCount)

        createPinPenaltyPreviewFlow(
            initialPreview = preview,
            remainingTime = remainingTime
        ).collectLatest { preview ->
            send(preview)
        }

        val pinEntryPreview = createPinEntryFlow(preview)
        send(pinEntryPreview)
    }.flowOn(Dispatchers.IO)

    suspend fun updatePreviewWithEnteredPinCode(preview: InAppPinPreview?, pinCode: String): InAppPinPreview? {
        if (preview == null) return null
        val isEnteredPinCodeCorrect = encryptedPinUseCase.getEncryptedPin() == pinCode
        val pinAttemptCount = getLockAttemptCountUseCase.invoke()
        val newPinAttemptCount = if (isEnteredPinCodeCorrect) pinAttemptCount else pinAttemptCount.inc()
        val isPinAttemptCountExceed = isPinAttemptCountExceed(newPinAttemptCount)

        if (isEnteredPinCodeCorrect) {
            clearLockRelatedPreferences()
        } else {
            setLockAttemptCountUseCase.invoke(newPinAttemptCount)
        }

        val pinEntryPreview = preview.pinEntryPreview?.copy(
            onStartPenaltyTimeEvent = if (isPinAttemptCountExceed) Event(Unit) else null,
            onPinCodeIncorrectEvent = if (isEnteredPinCodeCorrect) null else Event(Unit),
            popInAppPinNavigationEvent = if (isEnteredPinCodeCorrect) Event(Unit) else null
        )
        return preview.copy(pinEntryPreview = pinEntryPreview)
    }

    suspend fun updatePreviewWithBiometricAuthSucceed(preview: InAppPinPreview?): InAppPinPreview? {
        if (preview == null) return null

        clearLockRelatedPreferences()

        val pinEntryPreview = preview.pinEntryPreview?.copy(popInAppPinNavigationEvent = Event(Unit))
        return preview.copy(pinEntryPreview = pinEntryPreview)
    }

    fun getInAppPinPreview() = channelFlow {
        val initialPreview = inAppPinPreviewMapper.mapToInAppPinPreview()
        val remainingTime = getLockPenaltyRemainingTimeUseCase.invoke()
        val isPenaltyActive = isPenaltyActive(remainingTime)

        if (isPenaltyActive) {
            createPinPenaltyPreviewFlow(
                initialPreview = initialPreview,
                remainingTime = remainingTime
            ).collectLatest { preview ->
                send(preview)
            }
        }

        val pinEntryPreview = createPinEntryFlow(initialPreview)
        send(pinEntryPreview)
    }.flowOn(Dispatchers.IO)

    private fun createPinPenaltyPreviewFlow(initialPreview: InAppPinPreview, remainingTime: Long) = flow {
        var safeRemainingTime = remainingTime
        var formattedRemainingPenaltyTime = formatPenaltyRemainingTime(safeRemainingTime)
        var pinPenaltyPreview = inAppPinPreviewMapper.mapToPinPenaltyPreview(
            formattedRemainingPenaltyTime = formattedRemainingPenaltyTime
        )
        emit(initialPreview.copy(pinPenaltyPreview = pinPenaltyPreview))

        while (safeRemainingTime > 0) {
            setLockPenaltyRemainingTimeUseCase.invoke(safeRemainingTime)
            safeRemainingTime -= ONE_SECOND_IN_MILLIS
            delay(ONE_SECOND_IN_MILLIS)

            formattedRemainingPenaltyTime = formatPenaltyRemainingTime(safeRemainingTime)
            pinPenaltyPreview = pinPenaltyPreview.copy(formattedRemainingPenaltyTime = formattedRemainingPenaltyTime)
            emit(initialPreview.copy(pinPenaltyPreview = pinPenaltyPreview))
        }
        setLockPenaltyRemainingTimeUseCase.invoke(defaultLockPenaltyRemainingTimePreference)
    }

    private suspend fun createPinEntryFlow(initialPreview: InAppPinPreview): InAppPinPreview {
        val isBiometricActive = isBiometricActiveUseCase.invoke()
        val pinEntryPreview = inAppPinPreviewMapper.mapToPinEntryPreview(
            askBiometricAuthEvent = if (isBiometricActive) Event(Unit) else null,
        )
        return initialPreview.copy(pinPenaltyPreview = null, pinEntryPreview = pinEntryPreview)
    }

    private fun isPenaltyActive(remainingPenaltyTime: Long): Boolean {
        return remainingPenaltyTime != defaultLockPenaltyRemainingTimePreference
    }

    private fun isPinAttemptCountExceed(attemptCount: Int): Boolean {
        return attemptCount % PENALTY_PER_INTERVAL == 0
    }

    private fun calculatePinPenaltyTime(attemptCount: Int): Long {
        return attemptCount / PENALTY_PER_INTERVAL * PENALTY_PER_ATTEMPT
    }

    private suspend fun clearLockRelatedPreferences() {
        setLockPenaltyRemainingTimeUseCase.invoke(defaultLockPenaltyRemainingTimePreference)
        setLockAttemptCountUseCase.invoke(defaultLockAttemptCountPreference)
    }

    private fun formatPenaltyRemainingTime(remainingTime: Long): String {
        val (minutes, seconds) = remainingTime.getTimeAsMinSecondPair()
        return String.format(PENALTY_REMAINING_TIME_PATTERN, minutes, seconds)
    }

    companion object {
        private const val PENALTY_REMAINING_TIME_PATTERN = "%02d:%02d"
        private const val PENALTY_PER_ATTEMPT = 30_000L
        private const val PENALTY_PER_INTERVAL = 5
    }
}
