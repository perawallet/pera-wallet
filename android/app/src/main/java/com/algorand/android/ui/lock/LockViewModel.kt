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

package com.algorand.android.ui.lock

import android.app.NotificationManager
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.usecase.DeleteAllDataUseCase
import com.algorand.android.usecase.LockUseCase
import kotlinx.coroutines.launch

class LockViewModel @ViewModelInject constructor(
    private val deleteAllDataUseCase: DeleteAllDataUseCase,
    private val lockUseCase: LockUseCase
) : BaseViewModel() {

    fun deleteAllData(notificationManager: NotificationManager?, onDeletionCompleted: () -> Unit) {
        viewModelScope.launch {
            deleteAllDataUseCase.deleteAllData(notificationManager, onDeletionCompleted)
        }
    }

    fun shouldShowBiometricDialog(): Boolean {
        return lockUseCase.shouldShowBiometricDialog()
    }

    fun isPinCodeEnabled(): Boolean {
        return lockUseCase.isPinCodeEnabled()
    }

    fun getCurrentPassword(): String? {
        return lockUseCase.getCurrentPassword()
    }

    fun getLockPenaltyRemainingTime(): Long {
        return lockUseCase.getLockPenaltyRemainingTime()
    }

    fun getLockAttemptCount(): Int {
        return lockUseCase.getLockAttemptCount()
    }

    fun setLockAttemptCount(lockAttemptCount: Int) {
        lockUseCase.setLockAttemptCount(lockAttemptCount)
    }

    fun setLockPenaltyRemainingTime(penaltyRemainingTime: Long) {
        lockUseCase.setLockPenaltyRemainingTime(penaltyRemainingTime)
    }
}
