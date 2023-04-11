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

package com.algorand.android.modules.baseresult.ui.usecase

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.PluralAnnotatedString
import com.algorand.android.modules.baseresult.ui.mapper.ResultListItemMapper
import com.algorand.android.modules.baseresult.ui.model.ResultListItem
import com.algorand.android.utils.AccountDisplayName

open class BaseResultPreviewUseCase constructor(
    private val resultListItemMapper: ResultListItemMapper
) : BaseUseCase() {

    protected fun createIconItem(
        @ColorRes iconTintColorResId: Int,
        @DrawableRes iconResId: Int
    ): ResultListItem.IconItem {
        return resultListItemMapper.mapToIconItem(
            iconTintColorResId = iconTintColorResId,
            iconResId = iconResId
        )
    }

    protected fun createSingularTitleItem(
        @StringRes titleTextResId: Int
    ): ResultListItem.TitleItem.Singular {
        return resultListItemMapper.mapToSingularTitleItem(
            titleTextResId = titleTextResId
        )
    }

    protected fun createPluralTitleItem(
        @PluralsRes titleTextResId: Int,
        quantity: Int
    ): ResultListItem.TitleItem.Plural {
        return resultListItemMapper.mapToPluralTitleItem(
            titleTextResId = titleTextResId,
            quantity = quantity
        )
    }

    protected fun createSingularDescriptionItem(
        annotatedString: AnnotatedString,
        isClickable: Boolean
    ): ResultListItem.DescriptionItem.Singular {
        return resultListItemMapper.mapToSingularDescriptionItem(
            annotatedString = annotatedString,
            isClickable = isClickable
        )
    }

    protected fun createPluralDescriptionItem(
        pluralAnnotatedString: PluralAnnotatedString,
        isClickable: Boolean
    ): ResultListItem.DescriptionItem.Plural {
        return resultListItemMapper.mapToPluralDescriptionItem(
            pluralAnnotatedString = pluralAnnotatedString,
            isClickable = isClickable
        )
    }

    protected fun createSingularInfoBoxItem(
        @DrawableRes infoIconResId: Int,
        @ColorRes infoIconTintResId: Int,
        @StringRes infoTitleTextResId: Int,
        @ColorRes infoTitleTintResId: Int,
        infoDescriptionAnnotatedString: AnnotatedString,
        @ColorRes infoDescriptionTintResId: Int,
        @ColorRes infoBoxTintColorResId: Int
    ): ResultListItem.InfoBoxItem.Singular {
        return resultListItemMapper.mapToSingularInfoBoxItem(
            infoIconResId = infoIconResId,
            infoIconTintResId = infoIconTintResId,
            infoTitleTextResId = infoTitleTextResId,
            infoTitleTintResId = infoTitleTintResId,
            infoDescriptionAnnotatedString = infoDescriptionAnnotatedString,
            infoDescriptionTintResId = infoDescriptionTintResId,
            infoBoxTintColorResId = infoBoxTintColorResId
        )
    }

    protected fun createPluralInfoBoxItem(
        @DrawableRes infoIconResId: Int,
        @ColorRes infoIconTintResId: Int,
        @StringRes infoTitleTextResId: Int,
        @ColorRes infoTitleTintResId: Int,
        infoDescriptionPluralAnnotatedString: PluralAnnotatedString,
        @ColorRes infoDescriptionTintResId: Int,
        @ColorRes infoBoxTintColorResId: Int
    ): ResultListItem.InfoBoxItem.Plural {
        return resultListItemMapper.mapToPluralInfoBoxItem(
            infoIconResId = infoIconResId,
            infoIconTintResId = infoIconTintResId,
            infoTitleTextResId = infoTitleTextResId,
            infoTitleTintResId = infoTitleTintResId,
            infoDescriptionPluralAnnotatedString = infoDescriptionPluralAnnotatedString,
            infoDescriptionTintResId = infoDescriptionTintResId,
            infoBoxTintColorResId = infoBoxTintColorResId
        )
    }

    protected fun createAccountItem(
        accountDisplayName: AccountDisplayName,
        accountIconResource: AccountIconResource,
    ): ResultListItem.AccountItem {
        return resultListItemMapper.mapToAccountItem(
            accountDisplayName = accountDisplayName,
            accountIconResource = accountIconResource
        )
    }
}
