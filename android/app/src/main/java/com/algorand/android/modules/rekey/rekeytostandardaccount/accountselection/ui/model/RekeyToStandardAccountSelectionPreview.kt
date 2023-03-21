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

package com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.model

import com.algorand.android.models.ScreenState
import com.algorand.android.modules.basesingleaccountselection.ui.model.BaseSingleAccountSelectionFields
import com.algorand.android.modules.basesingleaccountselection.ui.model.SingleAccountSelectionListItem

data class RekeyToStandardAccountSelectionPreview(
    override val isLoading: Boolean,
    override val singleAccountSelectionListItems: List<SingleAccountSelectionListItem>,
    override val screenState: ScreenState?
) : BaseSingleAccountSelectionFields
