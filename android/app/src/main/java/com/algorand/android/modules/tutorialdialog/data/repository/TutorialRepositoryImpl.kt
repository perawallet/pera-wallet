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

package com.algorand.android.modules.tutorialdialog.data.repository

import com.algorand.android.modules.tutorialdialog.data.local.TutorialIdsLocalSource
import com.algorand.android.modules.tutorialdialog.data.local.TutorialSingleLocalCache
import com.algorand.android.modules.tutorialdialog.data.model.Tutorial
import com.algorand.android.modules.tutorialdialog.domain.repository.TutorialRepository
import com.algorand.android.utils.CacheResult
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class TutorialRepositoryImpl(
    private val tutorialIdsLocalSource: TutorialIdsLocalSource,
    private val tutorialSingleLocalCache: TutorialSingleLocalCache
) : TutorialRepository {

    override suspend fun cacheTutorial(tutorial: Tutorial) {
        tutorialSingleLocalCache.put(CacheResult.Success.create(tutorial))
    }

    override suspend fun getCachedTutorial(): Flow<Tutorial?> {
        return tutorialSingleLocalCache.cacheFlow.map { it?.data }
    }

    override suspend fun removeDismissedTutorialFromCache(tutorialId: Int) {
        tutorialSingleLocalCache.remove()
    }

    override suspend fun setTutorialDismissed(tutorialId: Int) {
        tutorialIdsLocalSource.saveData(listOf(tutorialId))
    }

    override suspend fun getDismissedTutorialIdList(): List<Int> {
        return tutorialIdsLocalSource.getDataOrNull() ?: emptyList()
    }

    override suspend fun clearDismissedTutorialIds() {
        tutorialIdsLocalSource.clear()
    }

    override suspend fun clearTutorialCache() {
        tutorialSingleLocalCache.clear()
    }
}
