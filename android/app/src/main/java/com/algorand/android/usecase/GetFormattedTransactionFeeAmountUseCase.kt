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

package com.algorand.android.usecase

import com.algorand.android.utils.MIN_FEE
import com.algorand.android.utils.formatAsAlgoAmount
import com.algorand.android.utils.formatAsAlgoString
import javax.inject.Inject

class GetFormattedTransactionFeeAmountUseCase @Inject constructor() {

    fun getTransactionFee(): String {
        // TODO: 5.05.2022 I talked with iOS team and they said that For now, the calculation of transactions
        //  fee is hard. So, we use `MIN_FEE` for representing `Adding Asset Transaction Fee `
        return MIN_FEE.formatAsAlgoString().formatAsAlgoAmount()
    }
}
