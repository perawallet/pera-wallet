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
 *
 */

package com.algorand.android.repository

import com.algorand.android.modules.autolockmanager.domain.usecase.ShouldAppLockedUseCase.Companion.defaultLockPenaltyRemainingTimePreference
import com.algorand.android.sharedpref.BiometricRegistrationLocalSource
import com.algorand.android.sharedpref.BiometricRegistrationLocalSource.Companion.defaultBiometricRegistrationPreference
import com.algorand.android.sharedpref.LockAttemptCountLocalSource
import com.algorand.android.sharedpref.LockAttemptCountLocalSource.Companion.defaultLockAttemptCountPreference
import com.algorand.android.sharedpref.LockPenaltyRemainingTimeLocalSource
import com.algorand.android.sharedpref.LockPreferencesLocalSource
import javax.inject.Inject

class SecurityRepository @Inject constructor(
    private val lockPreferencesLocalSource: LockPreferencesLocalSource,
    private val biometricRegistrationLocalSource: BiometricRegistrationLocalSource,
    private val lockPenaltyRemainingTimeLocalSource: LockPenaltyRemainingTimeLocalSource,
    private val lockAttemptCountLocalSource: LockAttemptCountLocalSource
) {

    fun canAskLockPreferences(): Boolean {
        return lockPreferencesLocalSource.getData(
            LockPreferencesLocalSource.defaultLockPreferences
        ) != LockPreferencesLocalSource.DONT_SHOW_AGAIN_COUNT
    }

    fun setBiometricRegistrationPreference(isEnabled: Boolean) {
        biometricRegistrationLocalSource.saveData(isEnabled)
    }

    fun isBiometricActive(): Boolean {
        return biometricRegistrationLocalSource.getData(defaultBiometricRegistrationPreference)
    }

    fun setLockPenaltyRemainingTime(penaltyRemainingTime: Long) {
        lockPenaltyRemainingTimeLocalSource.saveData(penaltyRemainingTime)
    }

    fun getLockPenaltyRemainingTime(): Long {
        return lockPenaltyRemainingTimeLocalSource.getData(defaultLockPenaltyRemainingTimePreference)
    }

    fun setLockAttemptCount(lockAttemptCount: Int) {
        lockAttemptCountLocalSource.saveData(lockAttemptCount)
    }

    fun getLockAttemptCount(): Int {
        return lockAttemptCountLocalSource.getData(defaultLockAttemptCountPreference)
    }
}
