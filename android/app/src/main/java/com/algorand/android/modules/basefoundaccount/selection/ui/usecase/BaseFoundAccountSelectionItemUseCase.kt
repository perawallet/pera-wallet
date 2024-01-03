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

package com.algorand.android.modules.basefoundaccount.selection.ui.usecase

import com.algorand.android.models.PluralAnnotatedString
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.basefoundaccount.selection.ui.mapper.BaseFoundAccountSelectionItemMapper
import com.algorand.android.modules.basefoundaccount.selection.ui.model.BaseFoundAccountSelectionItem
import com.algorand.android.utils.AccountDisplayName

open class BaseFoundAccountSelectionItemUseCase(
    private val baseFoundAccountSelectionItemMapper: BaseFoundAccountSelectionItemMapper
) {
    protected fun createIconItem(
        iconResId: Int
    ): BaseFoundAccountSelectionItem.IconItem {
        return baseFoundAccountSelectionItemMapper.mapToIconItem(
            iconResId = iconResId
        )
    }

    protected fun createTitleItem(
        titlePluralAnnotatedString: PluralAnnotatedString
    ): BaseFoundAccountSelectionItem.TitleItem {
        return baseFoundAccountSelectionItemMapper.mapToTitleItem(
            titlePluralAnnotatedString = titlePluralAnnotatedString
        )
    }

    protected fun createDescriptionItem(
        descriptionPluralAnnotatedString: PluralAnnotatedString
    ): BaseFoundAccountSelectionItem.DescriptionItem {
        return baseFoundAccountSelectionItemMapper.mapToDescriptionItem(
            descriptionPluralAnnotatedString = descriptionPluralAnnotatedString
        )
    }

    protected fun createAccountItem(
        accountIconDrawablePreview: AccountIconDrawablePreview,
        accountDisplayName: AccountDisplayName,
        selectorDrawableRes: Int,
        isSelected: Boolean
    ): BaseFoundAccountSelectionItem.AccountItem {
        return baseFoundAccountSelectionItemMapper.mapToAccountItem(
            accountIconDrawablePreview = accountIconDrawablePreview,
            accountDisplayName = accountDisplayName,
            selectorDrawableRes = selectorDrawableRes,
            isSelected = isSelected
        )
    }
}
