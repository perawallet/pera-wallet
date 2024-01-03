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

package com.algorand.android.modules.firebase.token.usecase

import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.network.IndexerInterceptor
import com.algorand.android.network.MobileHeaderInterceptor
import com.algorand.android.repository.NodeRepository
import com.algorand.android.usecase.CoreCacheUseCase
import javax.inject.Inject

class ApplyNodeChangesUseCase @Inject constructor(
    private val coreCacheUseCase: CoreCacheUseCase,
    private val mobileHeaderInterceptor: MobileHeaderInterceptor,
    private val indexerInterceptor: IndexerInterceptor,
    private val algodInterceptor: AlgodInterceptor,
    private val nodeRepository: NodeRepository
) {

    suspend operator fun invoke() {
        coreCacheUseCase.handleNodeChange()
        nodeRepository.getActiveNode()?.activate(
            indexerInterceptor = indexerInterceptor,
            mobileHeaderInterceptor = mobileHeaderInterceptor,
            algodInterceptor = algodInterceptor
        )
    }
}
