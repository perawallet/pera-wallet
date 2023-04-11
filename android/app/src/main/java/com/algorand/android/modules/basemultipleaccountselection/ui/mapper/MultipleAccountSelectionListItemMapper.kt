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

package com.algorand.android.modules.basemultipleaccountselection.ui.mapper

import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.basemultipleaccountselection.ui.model.MultipleAccountSelectionListItem
import com.algorand.android.utils.AccountDisplayName
import javax.inject.Inject

class MultipleAccountSelectionListItemMapper @Inject constructor() {

    fun mapToTitleItem(
        @StringRes textResId: Int
    ): MultipleAccountSelectionListItem.TitleItem {
        return MultipleAccountSelectionListItem.TitleItem(
            textResId = textResId
        )
    }

    fun mapToDescriptionItem(
        annotatedString: AnnotatedString
    ): MultipleAccountSelectionListItem.DescriptionItem {
        return MultipleAccountSelectionListItem.DescriptionItem(
            annotatedString = annotatedString
        )
    }

    fun mapToAccountHeaderItem(
        @PluralsRes titleRes: Int,
        accountCount: Int,
        checkboxState: TriStatesCheckBox.CheckBoxState,
    ): MultipleAccountSelectionListItem.AccountHeaderItem {
        return MultipleAccountSelectionListItem.AccountHeaderItem(
            titleRes = titleRes,
            accountCount = accountCount,
            checkboxState = checkboxState
        )
    }

    fun mapToAccountItem(
        accountDisplayName: AccountDisplayName,
        accountIconResource: AccountIconResource,
        accountViewButtonState: AccountAssetItemButtonState
    ): MultipleAccountSelectionListItem.AccountItem {
        return MultipleAccountSelectionListItem.AccountItem(
            accountDisplayName = accountDisplayName,
            accountIconResource = accountIconResource,
            accountViewButtonState = accountViewButtonState
        )
    }
}
