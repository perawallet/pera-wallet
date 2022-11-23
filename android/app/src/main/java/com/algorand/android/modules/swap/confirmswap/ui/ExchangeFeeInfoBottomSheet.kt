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

package com.algorand.android.modules.swap.confirmswap.ui

import com.algorand.android.R
import com.algorand.android.modules.informationbottomsheet.ui.BaseInformationBottomSheet

class ExchangeFeeInfoBottomSheet : BaseInformationBottomSheet() {

    override val titleTextResId: Int
        get() = R.string.exchange_fee

    override val descriptionTextResId: Int
        get() = R.string.this_is_the_fee_charged

    override val neutralButtonTextResId: Int
        get() = R.string.close

    override fun onNeutralButtonClick() {
        navBack()
    }
}
