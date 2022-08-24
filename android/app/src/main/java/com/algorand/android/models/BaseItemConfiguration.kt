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

package com.algorand.android.models

import android.graphics.drawable.Drawable
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import java.math.BigDecimal

sealed class BaseItemConfiguration {

    abstract val itemStatusDrawable: Drawable?

    abstract val primaryValueText: String?
    abstract val secondaryValueText: String?

    abstract val primaryValue: BigDecimal?
    abstract val secondaryValue: BigDecimal?

    abstract val showWarning: Boolean?

    abstract val actionButtonConfiguration: ButtonConfiguration?
    abstract val checkButtonConfiguration: ButtonConfiguration?
    abstract val dragButtonConfiguration: ButtonConfiguration?

    data class AssetItemConfiguration(
        val assetId: Long,
        val assetIconDrawableProvider: BaseAssetDrawableProvider? = null,
        val primaryAssetName: AssetName? = null,
        val secondaryAssetName: AssetName? = null,
        val isVerified: Boolean? = null, // TODO: use itemStatusDrawable instead of isVerified flag
        val showWithAssetId: Boolean? = null,
        override val itemStatusDrawable: Drawable? = null,
        override val primaryValueText: String? = null,
        override val secondaryValueText: String? = null,
        override val actionButtonConfiguration: ButtonConfiguration? = null,
        override val checkButtonConfiguration: ButtonConfiguration? = null,
        override val dragButtonConfiguration: ButtonConfiguration? = null,
        override val primaryValue: BigDecimal? = null,
        override val secondaryValue: BigDecimal? = null
    ) : BaseItemConfiguration() {

        override val showWarning: Boolean?
            get() = null
    }

    data class AccountItemConfiguration(
        val accountAddress: String,
        val accountIconResource: AccountIconResource? = null,
        val governorIconResource: GovernorIconResource? = null,
        val accountDisplayName: AccountDisplayName? = null,
        val accountType: Account.Type? = null,
        override val primaryValueText: String? = null,
        override val secondaryValueText: String? = null,
        override val showWarning: Boolean? = null,
        override val actionButtonConfiguration: ButtonConfiguration? = null,
        override val checkButtonConfiguration: ButtonConfiguration? = null,
        override val dragButtonConfiguration: ButtonConfiguration? = null,
        override val primaryValue: BigDecimal? = null,
        override val secondaryValue: BigDecimal? = null
    ) : BaseItemConfiguration() {

        override val itemStatusDrawable: Drawable?
            get() = null
    }
}
