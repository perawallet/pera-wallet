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

package com.algorand.android.modules.accountdetail.assets.ui.mapper

import com.algorand.android.modules.accountdetail.assets.ui.model.AccountAssetsPreview
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem
import javax.inject.Inject

class AccountAssetsPreviewMapper @Inject constructor() {

    fun mapToAccountAssetsPreview(
        accountDetailAssetsItemList: List<AccountDetailAssetsItem>,
        isFloatingActionButtonVisible: Boolean
    ): AccountAssetsPreview {
        return AccountAssetsPreview(
            accountDetailAssetsItemList = accountDetailAssetsItemList,
            isFloatingActionButtonVisible = isFloatingActionButtonVisible
        )
    }
}
