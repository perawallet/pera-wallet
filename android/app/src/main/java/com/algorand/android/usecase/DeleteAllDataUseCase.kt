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

package com.algorand.android.usecase

import android.app.NotificationManager
import com.algorand.android.banner.domain.usecase.BannersUseCase
import com.algorand.android.core.AccountManager
import com.algorand.android.repository.ContactRepository
import com.algorand.android.utils.walletconnect.WalletConnectManager
import javax.inject.Inject

class DeleteAllDataUseCase @Inject constructor(
    private val contactRepository: ContactRepository,
    private val accountManager: AccountManager,
    private val walletConnectManager: WalletConnectManager,
    private val coreCacheUseCase: CoreCacheUseCase,
    private val bannersUseCase: BannersUseCase
) {
    suspend fun deleteAllData(notificationManager: NotificationManager?, onDeletionCompleted: (() -> Unit)) {
        accountManager.removeAllData()
        contactRepository.deleteAllContacts()
        walletConnectManager.killAllSessions()
        coreCacheUseCase.clearAllCachedData()
        bannersUseCase.clearBannerCacheAndDismissedBannerIdList()
        notificationManager?.cancelAll()
        onDeletionCompleted()
    }
}
