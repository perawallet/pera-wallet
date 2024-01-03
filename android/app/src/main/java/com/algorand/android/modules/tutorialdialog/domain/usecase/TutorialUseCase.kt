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

package com.algorand.android.modules.tutorialdialog.domain.usecase

import com.algorand.android.models.Account
import com.algorand.android.modules.appopencount.domain.usecase.ApplicationOpenCountPreferenceUseCase
import com.algorand.android.modules.tutorialdialog.data.model.Tutorial
import com.algorand.android.usecase.GetLocalAccountsUseCase
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow

class TutorialUseCase @Inject constructor(
    private val cacheTutorialUseCase: CacheTutorialUseCase,
    private val getCachedTutorialUseCase: GetCachedTutorialUseCase,
    private val getDismissedTutorialIdsUseCase: GetDismissedTutorialIdsUseCase,
    private val removeDismissedTutorialFromCacheUseCase: RemoveDismissedTutorialFromCacheUseCase,
    private val setTutorialDismissedUseCase: SetTutorialDismissedUseCase,
    private val applicationOpenCountPreferenceUseCase: ApplicationOpenCountPreferenceUseCase,
    private val getLocalAccountsUseCase: GetLocalAccountsUseCase
) {

    suspend fun initializeTutorial() {
        val applicationOpeningCount = applicationOpenCountPreferenceUseCase.getApplicationOpenCount()
        if (applicationOpeningCount < 1 || !isThereAnyNormalLocalAccount()) return

        val tutorials = Tutorial.values().toList()
        val dismissedTutorials = getDismissedTutorialIdsUseCase.getDismissedTutorialIdList()
        tutorials.firstOrNull { !dismissedTutorials.contains(it.ordinal) }?.let { upcomingTutorial ->
            cacheTutorialUseCase.cacheTutorial(upcomingTutorial)
        }
    }

    suspend fun getTutorial(): Flow<Tutorial?> {
        return getCachedTutorialUseCase.getCachedTutorial()
    }

    suspend fun dismissTutorial(tutorialId: Int) {
        setTutorialDismissedUseCase.setTutorialDismissed(tutorialId)
        removeDismissedTutorialFromCacheUseCase.removeDismissedTutorialFromCache(tutorialId)
    }

    private fun isThereAnyNormalLocalAccount(): Boolean {
        val localAccounts = getLocalAccountsUseCase.getLocalAccountsFromAccountManagerCache()
        return localAccounts.any { account -> account.type != Account.Type.WATCH }
    }
}
