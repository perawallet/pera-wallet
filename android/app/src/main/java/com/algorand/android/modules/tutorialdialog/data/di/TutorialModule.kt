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

package com.algorand.android.modules.tutorialdialog.data.di

import com.algorand.android.modules.tutorialdialog.data.local.TutorialIdsLocalSource
import com.algorand.android.modules.tutorialdialog.data.local.TutorialSingleLocalCache
import com.algorand.android.modules.tutorialdialog.data.repository.TutorialRepositoryImpl
import com.algorand.android.modules.tutorialdialog.domain.repository.TutorialRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object TutorialModule {

    @Singleton
    @Provides
    @Named(TutorialRepository.REPOSITORY_INJECTION_NAME)
    fun provideTutorialRepository(
        tutorialIdsLocalSource: TutorialIdsLocalSource,
        tutorialSingleLocalCache: TutorialSingleLocalCache
    ): TutorialRepository {
        return TutorialRepositoryImpl(
            tutorialIdsLocalSource = tutorialIdsLocalSource,
            tutorialSingleLocalCache = tutorialSingleLocalCache
        )
    }
}
