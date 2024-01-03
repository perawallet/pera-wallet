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

package com.algorand.android.modules.asb.createbackup.accountselection.ui.model

import com.algorand.android.models.ScreenState
import com.algorand.android.modules.basemultipleaccountselection.ui.model.BaseMultipleAccountSelectionFields
import com.algorand.android.modules.basemultipleaccountselection.ui.model.MultipleAccountSelectionListItem
import com.algorand.android.utils.Event

data class AsbCreationAccountSelectionPreview(
    override val multipleAccountSelectionList: List<MultipleAccountSelectionListItem>,
    override val isActionButtonEnabled: Boolean,
    override val actionButtonTextResId: Int,
    override val isLoadingVisible: Boolean,
    override val checkedAccountCount: Int,
    override val emptyScreenState: ScreenState?,
    val navToStoreKeyEvent: Event<List<String>>? = null
) : BaseMultipleAccountSelectionFields
