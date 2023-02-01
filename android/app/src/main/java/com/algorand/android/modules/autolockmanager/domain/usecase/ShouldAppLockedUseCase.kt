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

package com.algorand.android.modules.autolockmanager.domain.usecase

import com.algorand.android.repository.SecurityRepository
import com.algorand.android.usecase.EncryptedPinUseCase
import com.algorand.android.usecase.GetLocalAccountsUseCase
import javax.inject.Inject

class ShouldAppLockedUseCase @Inject constructor(
    private val getAppAtBackgroundTimeUseCase: GetAppAtBackgroundTimeUseCase,
    private val encryptedPinUseCase: EncryptedPinUseCase,
    private val securityRepository: SecurityRepository,
    private val getLocalAccountsUseCase: GetLocalAccountsUseCase
) {

    operator fun invoke(): Boolean {
        val appAtBackgroundTime = getAppAtBackgroundTimeUseCase.invoke()
        return when {
            !encryptedPinUseCase.isEncryptedPinSet() -> false
            !isThereAnyRegisteredAccount() -> false
            isAppFreshOpened(appAtBackgroundTime) -> true
            isThresholdExpired(appAtBackgroundTime) -> true
            isPenaltyTimeActive() -> true
            else -> false
        }
    }

    private fun isAppFreshOpened(appAtBackgroundTime: Long?): Boolean {
        return with(appAtBackgroundTime) { this == null || this == appAtBackgroundDefaultPreference }
    }

    private fun isThresholdExpired(appAtBackgroundTime: Long?): Boolean {
        if (appAtBackgroundTime == null) return false
        val timeInBackground = System.currentTimeMillis() - appAtBackgroundTime
        return timeInBackground > AUTO_LOCK_THRESHOLD
    }

    private fun isPenaltyTimeActive(): Boolean {
        return securityRepository.getLockPenaltyRemainingTime() != defaultLockPenaltyRemainingTimePreference
    }

    private fun isThereAnyRegisteredAccount(): Boolean {
        return getLocalAccountsUseCase.getLocalAccountsFromAccountManagerCache().isNotEmpty()
    }

    companion object {
        private const val AUTO_LOCK_THRESHOLD = 60_000
        const val appAtBackgroundDefaultPreference = 0L
        const val defaultLockPenaltyRemainingTimePreference = 0L
    }
}
