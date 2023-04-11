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

package com.algorand.android.modules.asb.importbackup.accountselection.utils

import com.algorand.android.core.AccountManager
import com.algorand.android.models.Account
import com.algorand.android.modules.algosdk.cryptoutil.domain.usecase.IsAccountAddressMatchWithSecretKeyUseCase
import com.algorand.android.modules.asb.importbackup.accountselection.ui.mapper.AsbAccountImportResultMapper
import com.algorand.android.modules.asb.importbackup.accountselection.ui.model.AsbAccountImportResult
import com.algorand.android.modules.asb.util.AlgorandSecureBackupUtils
import com.algorand.android.modules.backupprotocol.model.BackupProtocolElement
import com.algorand.android.utils.extensions.decodeBase64ToByteArray
import com.algorand.android.utils.isValidAddress
import javax.inject.Inject

class AsbAccountImportParser @Inject constructor(
    private val accountManager: AccountManager,
    private val asbAccountImportResultMapper: AsbAccountImportResultMapper,
    private val isAccountAddressMatchWithSecretKeyUseCase: IsAccountAddressMatchWithSecretKeyUseCase
) {

    fun parseAsbImportedAccounts(
        accountImportMap: List<Pair<String, BackupProtocolElement>>,
        unsupportedAccounts: List<BackupProtocolElement>?
    ): AsbAccountImportResult {
        val importedAccountList = mutableListOf<String>()
        val existingAccountList = mutableListOf<String>()
        val unsupportedAccountList = unsupportedAccounts?.mapNotNull { it.address }.orEmpty()
        accountImportMap.forEach { (accountAddress, _) ->
            val isAccountAlreadyExist = accountManager.isThereAnyAccountWithPublicKey(accountAddress)
            if (isAccountAlreadyExist) {
                existingAccountList.add(accountAddress)
                return@forEach
            }

            importedAccountList.add(accountAddress)
        }
        return asbAccountImportResultMapper.mapToAsbAccountImportResult(
            importedAccountList = importedAccountList,
            existingAccountList = existingAccountList,
            unsupportedAccountList = unsupportedAccountList
        )
    }

    suspend fun isAccountSupported(backupProtocolElement: BackupProtocolElement): Boolean {
        val accountPrivateKey = backupProtocolElement.privateKey?.decodeBase64ToByteArray()
        if (accountPrivateKey == null || accountPrivateKey.isEmpty()) {
            return false
        }

        val isSecretKeyValid = isAccountAddressMatchWithSecretKeyUseCase.invoke(
            accountAddress = backupProtocolElement.address.orEmpty(),
            secretKey = accountPrivateKey
        )
        if (!isSecretKeyValid) {
            return false
        }

        val isAccountAddressValid = backupProtocolElement.address.isValidAddress()
        if (!isAccountAddressValid) {
            return false
        }

        val isAccountTypeEligible = isAccountTypeEligible(backupProtocolElement.accountType)
        if (!isAccountTypeEligible) {
            return false
        }

        return true
    }

    private fun isAccountTypeEligible(accountTypeName: String?): Boolean {
        val accountType = Account.Type.valueOf(accountTypeName ?: return false)
        return AlgorandSecureBackupUtils.eligibleAccountTypes.contains(accountType)
    }
}
