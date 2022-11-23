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

package com.algorand.android.modules.swap.introduction.ui.usecase

import com.algorand.android.modules.swap.introduction.domain.usecase.SetSwapFeatureIntroductionPageVisibilityUseCase
import com.algorand.android.modules.swap.introduction.ui.SwapIntroductionFragmentDirections
import com.algorand.android.modules.swap.introduction.ui.mapper.SwapIntroductionPreviewMapper
import com.algorand.android.modules.swap.introduction.ui.model.SwapIntroductionPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class SwapIntroductionPreviewUseCase @Inject constructor(
    private val setSwapFeatureIntroductionPageVisibilityUseCase: SetSwapFeatureIntroductionPageVisibilityUseCase,
    private val swapIntroductionPreviewMapper: SwapIntroductionPreviewMapper
) {

    suspend fun getSwapClickUpdatedPreview(accountAddress: String?): SwapIntroductionPreview {
        setIntroductionPageAsShowed()
        val navDirectionEvent = if (accountAddress.isNullOrBlank()) {
            SwapIntroductionFragmentDirections.actionSwapIntroductionFragmentToSwapAccountSelectionNavigation()
        } else {
            SwapIntroductionFragmentDirections.actionSwapIntroductionFragmentToSwapNavigation(accountAddress)
        }
        return swapIntroductionPreviewMapper.mapToSwapIntroductionPreview(
            navigationDirectionEvent = Event(navDirectionEvent)
        )
    }

    private suspend fun setIntroductionPageAsShowed() {
        setSwapFeatureIntroductionPageVisibilityUseCase.setSwapFeatureIntroductionPageVisibility(false)
    }
}
