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

package com.algorand.android.deviceregistration.domain.usecase

import com.algorand.android.deviceregistration.domain.repository.UserDeviceIdRepository
import com.algorand.android.usecase.NodeSettingsUseCase
import com.algorand.android.utils.MAINNET_NETWORK_SLUG
import com.algorand.android.utils.TESTNET_NETWORK_SLUG
import javax.inject.Inject
import javax.inject.Named

class DeviceIdMigrationUseCase @Inject constructor(
    @Named(UserDeviceIdRepository.USER_DEVICE_ID_REPOSITORY_INJECTION_NAME)
    private val userDeviceIdRepository: UserDeviceIdRepository,
    private val nodeSettingsUseCase: NodeSettingsUseCase
) {

    suspend fun migrateDeviceIdIfNeed() {
        val oldDeviceId = userDeviceIdRepository.getNotificationUserId() ?: return
        when (nodeSettingsUseCase.getActiveNodeOrDefault().networkSlug) {
            MAINNET_NETWORK_SLUG -> migrateOldDeviceIdToMainnet(oldDeviceId)
            TESTNET_NETWORK_SLUG -> migrateOldDeviceIdToTestnet(oldDeviceId)
        }
    }

    private fun migrateOldDeviceIdToMainnet(oldDeviceId: String) {
        migrateDeviceId { it.setMainnetDeviceId(oldDeviceId) }
    }

    private fun migrateOldDeviceIdToTestnet(oldDeviceId: String) {
        migrateDeviceId { it.setTestnetDeviceId(oldDeviceId) }
    }

    private fun migrateDeviceId(migrationAction: (UserDeviceIdRepository) -> Unit) {
        with(userDeviceIdRepository) {
            migrationAction(this)
            userDeviceIdRepository.setNotificationUserId(null)
        }
    }
}
