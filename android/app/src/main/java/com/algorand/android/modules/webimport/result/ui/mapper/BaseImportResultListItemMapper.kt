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

package com.algorand.android.modules.webimport.result.ui.mapper

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import androidx.annotation.StyleRes
import com.algorand.android.R
import com.algorand.android.customviews.accountasseticonnameitem.model.AccountAssetIconNameConfiguration
import com.algorand.android.modules.webimport.result.ui.model.BaseAccountResultListItem
import javax.inject.Inject

class BaseImportResultListItemMapper @Inject constructor() {

    fun mapToImageItem(
        @DrawableRes drawableResId: Int,
        width: Int,
        height: Int,
        @ColorRes drawableTintResId: Int? = null
    ): BaseAccountResultListItem.ImageItem {
        return BaseAccountResultListItem.ImageItem(
            drawableResId = drawableResId,
            width = width,
            height = height,
            drawableTintResId = drawableTintResId
        )
    }

    fun mapToTextItem(
        @StringRes @PluralsRes
        textResId: Int,
        textIntParam: Int? = null,
        @StyleRes textAppearanceResId: Int = R.style.TextAppearance_Body,
        @ColorRes textColorResId: Int? = null
    ): BaseAccountResultListItem.TextItem {
        return BaseAccountResultListItem.TextItem(
            textResId = textResId,
            textIntParam = textIntParam,
            textAppearanceResId = textAppearanceResId,
            textColorResId = textColorResId
        )
    }

    @Suppress("LongParameterList")
    fun mapToWarningBoxItem(
        @StringRes titleResId: Int,
        @PluralsRes descriptionResId: Int,
        @DrawableRes iconResId: Int,
        textIntParam: Int? = null,
        @StyleRes titleTextAppearanceResId: Int = R.style.TextAppearance_Body,
        @StyleRes descriptionTextAppearanceResId: Int = R.style.TextAppearance_Body,
        @ColorRes iconColorResId: Int? = null,
        @ColorRes backgroundColorResId: Int? = null,
        @ColorRes textColorResId: Int? = null
    ): BaseAccountResultListItem.WarningBoxItem {
        return BaseAccountResultListItem.WarningBoxItem(
            titleResId = titleResId,
            descriptionResId = descriptionResId,
            iconResId = iconResId,
            textIntParam = textIntParam,
            titleTextAppearanceResId = titleTextAppearanceResId,
            descriptionTextAppearanceResId = descriptionTextAppearanceResId,
            iconColorResId = iconColorResId,
            backgroundColorResId = backgroundColorResId,
            textColorResId = textColorResId
        )
    }

    fun mapToAccountItem(
        accountAddress: String,
        accountAssetIconNameConfiguration: AccountAssetIconNameConfiguration
    ): BaseAccountResultListItem.AccountItem {
        return BaseAccountResultListItem.AccountItem(
            address = accountAddress,
            accountAssetIconNameConfiguration = accountAssetIconNameConfiguration
        )
    }
}
