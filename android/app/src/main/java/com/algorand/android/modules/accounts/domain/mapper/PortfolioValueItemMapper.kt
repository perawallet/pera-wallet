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

package com.algorand.android.modules.accounts.domain.mapper

import com.algorand.android.R
import com.algorand.android.modules.accounts.domain.model.BasePortfolioValueItem
import javax.inject.Inject

class PortfolioValueItemMapper @Inject constructor() {

    fun mapToPortfolioValuesSuccessItem(
        formattedPrimaryAccountValue: String,
        formattedSecondaryAccountValue: String
    ): BasePortfolioValueItem.SuccessPortfolioValueItem {
        return BasePortfolioValueItem.SuccessPortfolioValueItem(
            formattedPrimaryAccountValue = formattedPrimaryAccountValue,
            formattedSecondaryAccountValue = formattedSecondaryAccountValue,
            titleColorResId = R.color.secondary_text_color
        )
    }

    fun mapToPortfolioValuesPartialErrorItem(
        formattedPrimaryAccountValue: String,
        formattedSecondaryAccountValue: String
    ): BasePortfolioValueItem.PartialErrorPortfolioValueItem {
        return BasePortfolioValueItem.PartialErrorPortfolioValueItem(
            titleColorResId = R.color.error_text_color,
            errorStringResId = R.string.sorry_there_was,
            formattedPrimaryAccountValueResId = formattedPrimaryAccountValue,
            formattedSecondaryAccountValueResId = formattedSecondaryAccountValue
        )
    }

    fun mapToPortfolioValuesErrorItem(): BasePortfolioValueItem.ErrorPortfolioValueItem {
        return BasePortfolioValueItem.ErrorPortfolioValueItem(
            titleColorResId = R.color.error_text_color,
            errorStringResId = R.string.sorry_we_cant_show_portfolio,
            primaryAccountValueErrorResId = R.string.not_available_shortened,
            secondaryAccountValueErrorResId = R.string.not_available_shortened
        )
    }
}
