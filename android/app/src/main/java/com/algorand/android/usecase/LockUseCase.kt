/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.usecase

import com.algorand.android.repository.SecurityRepository
import javax.inject.Inject

class LockUseCase @Inject constructor(
    private val securityRepository: SecurityRepository
) {

    fun getCurrentPassword(): String? {
        return securityRepository.getCurrentPassword()
    }

    fun getLockPenaltyRemainingTime(): Long {
        return securityRepository.getLockPenaltyRemainingTime()
    }

    fun getLockAttemptCount(): Int {
        return securityRepository.getLockAttemptCount()
    }

    fun setLockAttemptCount(lockAttemptCount: Int) {
        securityRepository.setLockAttemptCount(lockAttemptCount)
    }

    fun setLockPenaltyRemainingTime(penaltyRemainingTime: Long) {
        securityRepository.setLockPenaltyRemainingTime(penaltyRemainingTime)
    }

    fun isPinCodeEnabled(): Boolean {
        return securityRepository.isPinCodeEnabled()
    }

    fun shouldShowBiometricDialog(): Boolean {
        return isBiometricActive() && getLockPenaltyRemainingTime() == 0L
    }

    private fun isBiometricActive(): Boolean {
        return securityRepository.isBiometricActive()
    }
}
