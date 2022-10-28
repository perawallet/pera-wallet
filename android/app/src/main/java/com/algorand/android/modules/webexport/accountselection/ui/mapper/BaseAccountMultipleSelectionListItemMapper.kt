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

package com.algorand.android.modules.webexport.accountselection.ui.mapper

import androidx.annotation.ColorRes
import androidx.annotation.DimenRes
import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import androidx.annotation.StyleRes
import com.algorand.android.R
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.customviews.accountasseticonnameitem.model.AccountAssetIconNameConfiguration
import com.algorand.android.modules.webexport.accountselection.ui.model.BaseAccountMultipleSelectionListItem
import javax.inject.Inject

class BaseAccountMultipleSelectionListItemMapper @Inject constructor() {

    fun mapToTextItem(
        @StringRes textResId: Int,
        @StyleRes textAppearanceResId: Int = R.style.TextAppearance_Body,
        @ColorRes textColorRestId: Int? = null,
        @DimenRes topMarginResId: Int? = null
    ): BaseAccountMultipleSelectionListItem.TextItem {
        return BaseAccountMultipleSelectionListItem.TextItem(
            textResId = textResId,
            textAppearanceResId = textAppearanceResId,
            textColorRestId = textColorRestId,
            topMarginResId = topMarginResId
        )
    }

    fun mapToHeaderItem(
        @PluralsRes titleRes: Int,
        accountCount: Int,
        checkboxState: TriStatesCheckBox.CheckBoxState,
        @DimenRes topMarginResId: Int? = null
    ): BaseAccountMultipleSelectionListItem.HeaderItem {
        return BaseAccountMultipleSelectionListItem.HeaderItem(
            titleRes = titleRes,
            accountCount = accountCount,
            checkboxState = checkboxState,
            topMarginResId = topMarginResId
        )
    }

    fun mapToAccountItem(
        accountAddress: String,
        accountAssetIconNameConfiguration: AccountAssetIconNameConfiguration,
        isChecked: Boolean,
        @DimenRes topMarginResId: Int? = null
    ): BaseAccountMultipleSelectionListItem.AccountItem {
        return BaseAccountMultipleSelectionListItem.AccountItem(
            address = accountAddress,
            accountAssetIconNameConfiguration = accountAssetIconNameConfiguration,
            isChecked = isChecked,
            topMarginResId = topMarginResId
        )
    }
}
