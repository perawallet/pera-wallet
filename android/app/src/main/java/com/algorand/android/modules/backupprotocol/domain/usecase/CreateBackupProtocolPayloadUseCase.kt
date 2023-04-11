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

package com.algorand.android.modules.backupprotocol.domain.usecase

import com.algorand.android.core.AccountManager
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.models.Account
import com.algorand.android.modules.backupprotocol.mapper.BackupProtocolElementMapper
import com.algorand.android.modules.backupprotocol.mapper.BackupProtocolPayloadMapper
import com.algorand.android.modules.backupprotocol.model.BackupProtocolPayload
import com.algorand.android.modules.backupprotocol.util.BackupProtocolUtils.convertAccountTypeToBackupProtocolAccountType
import com.algorand.android.utils.extensions.encodeBase64
import javax.inject.Inject

class CreateBackupProtocolPayloadUseCase @Inject constructor(
    private val deviceIdUseCase: DeviceIdUseCase,
    private val accountManager: AccountManager,
    private val backupProtocolElementMapper: BackupProtocolElementMapper,
    private val backupProtocolPayloadMapper: BackupProtocolPayloadMapper
) {

    suspend operator fun invoke(accountList: List<String>): BackupProtocolPayload? {
        val deviceId = deviceIdUseCase.getSelectedNodeDeviceId() ?: return null
        val accountBackupProtocolElementList = accountList.mapNotNull { accountAddress ->
            val account = accountManager.getAccount(accountAddress) ?: return@mapNotNull null
            if (account.type != Account.Type.STANDARD) return@mapNotNull null
            val accountType = convertAccountTypeToBackupProtocolAccountType(account.type) ?: return@mapNotNull null
            backupProtocolElementMapper.mapToBackupProtocolElement(
                address = account.address,
                name = account.name,
                accountType = accountType,
                privateKey = account.getSecretKey()?.encodeBase64() ?: return@mapNotNull null,
                metadata = null
            )
        }
        return backupProtocolPayloadMapper.mapToBackupProtocolPayload(
            deviceId = deviceId,
            providerName = DEFAULT_PROVIDER_NAME,
            accounts = accountBackupProtocolElementList
        )
    }

    companion object {
        private const val DEFAULT_PROVIDER_NAME = "Pera Wallet"
    }
}
