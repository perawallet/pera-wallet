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

package com.algorand.android.modules.walletconnect.sessiondetail.ui.model

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.algorand.android.models.AnnotatedString
import com.algorand.android.utils.Event

data class WalletConnectSessionDetailPreview(
    val dappMetaData: DappMetaData,
    val sessionDate: SessionDate,
    val connectedAccountList: List<WalletConnectSessionDetailConnectedAccountItem>,
    val advancedPermissions: AdvancedPermissions,
    val isLoadingVisible: Boolean,
    val isInformationBadgeVisible: Boolean,
    val expandAdvancedPermissionsEvent: Event<Unit>?,
    val collapseAdvancedPermissionsEvent: Event<Unit>?,
    val isAdvancedPermissionsExpanded: Boolean,
    val isExtendExpirationDateButtonVisible: Boolean,
    val isExtendExpirationDateButtonEnabled: Boolean,
    val checkSessionStatus: CheckSessionStatus?,
    val isSessionStatusVisible: Boolean,
    val informationBadge: InformationBadge?,
    val navBackEvent: Event<Unit>?,
    val navExtendSessionApproveBottomSheet: Event<ExpirationDate>?,
    val navAdvancedPermissionsInfoBottomSheetEvent: Event<Unit>?,
    val showSuccessMessageEvent: Event<String>?,
    val showErrorMessageEvent: Event<String>?
) {

    data class AdvancedPermissions(
        val supportedMethods: String?,
        val isSupportedMethodsVisible: Boolean,
        val supportedEvents: String?,
        val isSupportedEventsVisible: Boolean,
        val isAdvancedPermissionsVisible: Boolean,
        val isDividerVisible: Boolean,
    )

    data class SessionDate(
        val formattedConnectionDate: AnnotatedString,
        val formattedExpirationDate: AnnotatedString?,
        val isFormattedExpirationDateVisible: Boolean
    )

    data class ExpirationDate(
        val formattedMaxExtendableExpirationDate: String,
        val formattedExtendedExpirationDate: String
    )

    data class DappMetaData(
        val name: String,
        val url: String,
        val imageUrl: String?,
        val description: String?,
        val isDescriptionVisible: Boolean
    )

    data class InformationBadge(
        @StringRes val badgeTextResId: Int,
        @StringRes val informationTextResId: Int
    )

    data class CheckSessionStatus(
        @StringRes val buttonTextResId: Int,
        @ColorRes val buttonTextColorResId: Int,
        val isButtonEnabled: Boolean,
        @DrawableRes val buttonStartIconResId: Int?
    ) {
        val buttonStartIconTintResId: Int
            get() = buttonTextColorResId
    }
}
