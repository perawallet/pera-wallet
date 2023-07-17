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

package com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.information.ui.mapper

import com.algorand.android.modules.basefoundaccount.information.ui.model.BaseFoundAccountInformationItem
import com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.information.ui.model.RekeyedAccountInformationPreview
import javax.inject.Inject

class RekeyedAccountInformationPreviewMapper @Inject constructor() {

    fun mapToRekeyedAccountInformationPreview(
        isLoading: Boolean,
        foundAccountInformationItemList: List<BaseFoundAccountInformationItem>
    ): RekeyedAccountInformationPreview {
        return RekeyedAccountInformationPreview(
            isLoading = isLoading,
            foundAccountInformationItemList = foundAccountInformationItemList
        )
    }
}
