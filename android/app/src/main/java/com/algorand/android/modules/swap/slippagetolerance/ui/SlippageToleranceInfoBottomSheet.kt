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

package com.algorand.android.modules.swap.slippagetolerance.ui

import com.algorand.android.R
import com.algorand.android.modules.informationbottomsheet.ui.BaseInformationBottomSheet

class SlippageToleranceInfoBottomSheet : BaseInformationBottomSheet() {
    override val titleTextResId: Int = R.string.slippage_tolerance
    override val descriptionTextResId: Int = R.string.slippage_is_the_price_difference
    override val neutralButtonTextResId: Int = R.string.close

    override fun onNeutralButtonClick() {
        navBack()
    }
}
