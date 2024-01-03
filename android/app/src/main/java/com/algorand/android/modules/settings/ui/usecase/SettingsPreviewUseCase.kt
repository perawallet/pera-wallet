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

package com.algorand.android.modules.settings.ui.usecase

import com.algorand.android.modules.asb.backedupaccountssource.domain.usecase.AddBackedUpAccountListenerUseCase
import com.algorand.android.modules.asb.backedupaccountssource.domain.usecase.GetBackedUpAccountsUseCase
import com.algorand.android.modules.asb.backedupaccountssource.domain.usecase.RemoveBackedUpAccountListenerUseCase
import com.algorand.android.modules.asb.util.AlgorandSecureBackupUtils
import com.algorand.android.modules.settings.ui.mapper.SettingsPreviewMapper
import com.algorand.android.modules.settings.ui.model.SettingsPreview
import com.algorand.android.sharedpref.SharedPrefLocalSource
import com.algorand.android.usecase.GetLocalAccountsUseCase
import javax.inject.Inject
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow

class SettingsPreviewUseCase @Inject constructor(
    private val getLocalAccountsUseCase: GetLocalAccountsUseCase,
    private val getBackedUpAccountsUseCase: GetBackedUpAccountsUseCase,
    private val settingsPreviewMapper: SettingsPreviewMapper,
    private val removeBackedUpAccountListenerUseCase: RemoveBackedUpAccountListenerUseCase,
    private val addBackedUpAccountListenerUseCase: AddBackedUpAccountListenerUseCase
) {

    private fun addBackedUpAccountListener(listener: SharedPrefLocalSource.OnChangeListener<Set<String>>) {
        addBackedUpAccountListenerUseCase.invoke(listener)
    }

    private fun removeBackedUpAccountListener(listener: SharedPrefLocalSource.OnChangeListener<Set<String>>) {
        removeBackedUpAccountListenerUseCase.invoke(listener)
    }

    suspend fun getSettingsPreviewFlow() = callbackFlow<SettingsPreview> {
        val backedUpAccounts = getBackedUpAccountsUseCase.invoke()
        var preview = createSettingsPreview(backedUpAccounts)
        send(preview)

        val onChangeListener = SharedPrefLocalSource.OnChangeListener<Set<String>> { accounts ->
            preview = createSettingsPreview(accounts.orEmpty())
            trySend(preview)
        }
        addBackedUpAccountListener(onChangeListener)
        awaitClose { removeBackedUpAccountListener(onChangeListener) }
    }

    private fun createSettingsPreview(backedUpAccounts: Set<String>): SettingsPreview {
        val localAccounts = getLocalAccountsUseCase.getLocalAccountsFromAccountManagerCache().toSet()
        val localAccountAddresses = localAccounts.map { it.address }
        val remainingAccounts = localAccountAddresses - backedUpAccounts
        val eligibleLocalAccounts = remainingAccounts.filter { accountAddress ->
            val account = localAccounts.firstOrNull { it.address == accountAddress } ?: return@filter false
            AlgorandSecureBackupUtils.eligibleAccountTypes.contains(account.type)
        }
        return settingsPreviewMapper.mapToSettingsPreview(
            isAlgorandSecureBackupDescriptionVisible = eligibleLocalAccounts.isNotEmpty(),
            notBackedUpAccountCounts = eligibleLocalAccounts.size
        )
    }
}
