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
import com.algorand.android.models.Node
import com.algorand.android.usecase.NodeSettingsUseCase
import com.algorand.android.utils.MAINNET_NETWORK_SLUG
import com.algorand.android.utils.TESTNET_NETWORK_SLUG
import javax.inject.Inject
import javax.inject.Named

class DeviceIdUseCase @Inject constructor(
    @Named(UserDeviceIdRepository.USER_DEVICE_ID_REPOSITORY_INJECTION_NAME)
    private val userDeviceIdRepository: UserDeviceIdRepository,
    private val nodeSettingsUseCase: NodeSettingsUseCase
) {

    suspend fun getSelectedNodeDeviceId(): String? {
        return when (getSelectedNetworkSlug()) {
            MAINNET_NETWORK_SLUG -> userDeviceIdRepository.getMainnetDeviceId()
            TESTNET_NETWORK_SLUG -> userDeviceIdRepository.getTestnetDevideId()
            else -> null
        }
    }

    fun getNodeDeviceId(node: Node): String? {
        return when (node.networkSlug) {
            MAINNET_NETWORK_SLUG -> userDeviceIdRepository.getMainnetDeviceId()
            TESTNET_NETWORK_SLUG -> userDeviceIdRepository.getTestnetDevideId()
            else -> null
        }
    }

    suspend fun setSelectedNodeDeviceId(deviceId: String?) {
        when (getSelectedNetworkSlug()) {
            MAINNET_NETWORK_SLUG -> userDeviceIdRepository.setMainnetDeviceId(deviceId)
            TESTNET_NETWORK_SLUG -> userDeviceIdRepository.setTestnetDeviceId(deviceId)
        }
    }

    private suspend fun getSelectedNetworkSlug(): String = nodeSettingsUseCase.getActiveNodeOrDefault().networkSlug
}
