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

package com.algorand.android.deviceregistration.domain.mapper

import com.algorand.android.deviceregistration.domain.model.DeviceUpdateDTO
import javax.inject.Inject

class DeviceUpdateDTOMapper @Inject constructor() {

    fun mapToDeviceUpdateDTO(
        deviceId: String,
        token: String?,
        accountPublicKeyList: List<String>,
        application: String,
        platform: String,
        locale: String,
        networkSlug: String?
    ): DeviceUpdateDTO {
        return DeviceUpdateDTO(
            deviceId = deviceId,
            pushToken = token,
            accountPublicKeys = accountPublicKeyList,
            application = application,
            platform = platform,
            locale = locale,
            networkSlug = networkSlug
        )
    }
}
