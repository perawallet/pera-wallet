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

package com.algorand.android.modules.baseresult.ui.mapper

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.PluralAnnotatedString
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.baseresult.ui.model.ResultListItem
import com.algorand.android.utils.AccountDisplayName
import javax.inject.Inject

class ResultListItemMapper @Inject constructor() {

    fun mapToIconItem(
        @ColorRes iconTintColorResId: Int,
        @DrawableRes iconResId: Int
    ): ResultListItem.IconItem {
        return ResultListItem.IconItem(
            iconTintColorResId = iconTintColorResId,
            iconResId = iconResId
        )
    }

    fun mapToSingularTitleItem(
        @StringRes titleTextResId: Int
    ): ResultListItem.TitleItem.Singular {
        return ResultListItem.TitleItem.Singular(
            titleTextResId = titleTextResId
        )
    }

    fun mapToPluralTitleItem(
        @PluralsRes titleTextResId: Int,
        quantity: Int
    ): ResultListItem.TitleItem.Plural {
        return ResultListItem.TitleItem.Plural(
            titleTextResId = titleTextResId,
            quantity = quantity
        )
    }

    fun mapToSingularDescriptionItem(
        annotatedString: AnnotatedString,
        isClickable: Boolean
    ): ResultListItem.DescriptionItem.Singular {
        return ResultListItem.DescriptionItem.Singular(
            annotatedString = annotatedString,
            isClickable = isClickable
        )
    }

    fun mapToPluralDescriptionItem(
        pluralAnnotatedString: PluralAnnotatedString,
        isClickable: Boolean
    ): ResultListItem.DescriptionItem.Plural {
        return ResultListItem.DescriptionItem.Plural(
            pluralAnnotatedString = pluralAnnotatedString,
            isClickable = isClickable
        )
    }

    fun mapToSingularInfoBoxItem(
        @DrawableRes infoIconResId: Int,
        @ColorRes infoIconTintResId: Int,
        @StringRes infoTitleTextResId: Int,
        @ColorRes infoTitleTintResId: Int,
        infoDescriptionAnnotatedString: AnnotatedString,
        @ColorRes infoDescriptionTintResId: Int,
        @ColorRes infoBoxTintColorResId: Int
    ): ResultListItem.InfoBoxItem.Singular {
        return ResultListItem.InfoBoxItem.Singular(
            infoIconResId = infoIconResId,
            infoIconTintResId = infoIconTintResId,
            infoTitleTextResId = infoTitleTextResId,
            infoTitleTintResId = infoTitleTintResId,
            infoDescriptionAnnotatedString = infoDescriptionAnnotatedString,
            infoDescriptionTintResId = infoDescriptionTintResId,
            infoBoxTintColorResId = infoBoxTintColorResId
        )
    }

    fun mapToPluralInfoBoxItem(
        @DrawableRes infoIconResId: Int,
        @ColorRes infoIconTintResId: Int,
        @StringRes infoTitleTextResId: Int,
        @ColorRes infoTitleTintResId: Int,
        infoDescriptionPluralAnnotatedString: PluralAnnotatedString,
        @ColorRes infoDescriptionTintResId: Int,
        @ColorRes infoBoxTintColorResId: Int
    ): ResultListItem.InfoBoxItem.Plural {
        return ResultListItem.InfoBoxItem.Plural(
            infoIconResId = infoIconResId,
            infoIconTintResId = infoIconTintResId,
            infoTitleTextResId = infoTitleTextResId,
            infoTitleTintResId = infoTitleTintResId,
            infoDescriptionPluralAnnotatedString = infoDescriptionPluralAnnotatedString,
            infoDescriptionTintResId = infoDescriptionTintResId,
            infoBoxTintColorResId = infoBoxTintColorResId
        )
    }

    fun mapToAccountItem(
        accountDisplayName: AccountDisplayName,
        accountIconDrawablePreview: AccountIconDrawablePreview,
    ): ResultListItem.AccountItem {
        return ResultListItem.AccountItem(
            accountDisplayName = accountDisplayName,
            accountIconDrawablePreview = accountIconDrawablePreview
        )
    }
}
