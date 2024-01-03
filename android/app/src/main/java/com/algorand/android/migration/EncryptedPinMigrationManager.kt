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

package com.algorand.android.migration

import com.algorand.android.usecase.EncryptedPinUseCase
import com.algorand.android.usecase.NotEncryptedPinUseCase
import javax.inject.Inject

class EncryptedPinMigrationManager @Inject constructor(
    private val notEncryptedPinUseCase: NotEncryptedPinUseCase,
    private val encryptedPinUseCase: EncryptedPinUseCase
) : BaseMigrationManager<String?>() {

    override fun isMigrationNeeded(): Boolean {
        return notEncryptedPinUseCase.isNotEncryptedPinSet()
    }

    override fun getDataToBeMigrated(): String? {
        return notEncryptedPinUseCase.getNotEncryptedPin()
    }

    override fun createMigratedData(data: String?): String? {
        return notEncryptedPinUseCase.getNotEncryptedPin()
    }

    override fun handleMigratedData(migratedData: String?) {
        encryptedPinUseCase.setPin(migratedData)
        notEncryptedPinUseCase.clearNotEncryptedPin()
    }
}
