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

package com.algorand.android.modules.asb.createbackup.filefailure.ui.usecase

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.asb.createbackup.filefailure.ui.mapper.AsbFileFailurePreviewMapper
import com.algorand.android.modules.asb.createbackup.filefailure.ui.model.AsbFileFailurePreview
import com.algorand.android.modules.baseresult.ui.mapper.ResultListItemMapper
import com.algorand.android.modules.baseresult.ui.usecase.BaseResultPreviewUseCase
import javax.inject.Inject

class AsbFileFailurePreviewUseCase @Inject constructor(
    private val asbFileFailurePreviewMapper: AsbFileFailurePreviewMapper,
    resultListItemMapper: ResultListItemMapper
) : BaseResultPreviewUseCase(resultListItemMapper) {

    fun getAsbFileFailurePreview(): AsbFileFailurePreview {
        val iconItem = createIconItem(
            iconTintColorResId = R.color.negative,
            iconResId = R.drawable.ic_close
        )
        val titleItem = createSingularTitleItem(
            titleTextResId = R.string.something_went_wrong
        )
        val descriptionItem = createSingularDescriptionItem(
            annotatedString = AnnotatedString(stringResId = R.string.an_error_occurred_while_generating),
            isClickable = true
        )
        val resultItemList = listOf(
            iconItem,
            titleItem,
            descriptionItem
        )
        return asbFileFailurePreviewMapper.mapToAsbFileFailurePreview(
            resultListItems = resultItemList
        )
    }
}
