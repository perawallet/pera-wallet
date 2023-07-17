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

package com.algorand.android.modules.walletconnect.sessiondetail.ui.mapper

import android.graphics.drawable.Drawable
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailConnectedAccountItem
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class WalletConnectSessionDetailPreviewMapper @Inject constructor(
    private val connectedAccountNodeTextColorDecider: ConnectedAccountNodeTextColorDecider
) {

    @Suppress("LongParameterList")
    fun mapToPreview(
        dappMetaData: WalletConnectSessionDetailPreview.DappMetaData,
        sessionDate: WalletConnectSessionDetailPreview.SessionDate,
        connectedAccountList: List<WalletConnectSessionDetailConnectedAccountItem>,
        advancedPermissions: WalletConnectSessionDetailPreview.AdvancedPermissions,
        isInformationBadgeVisible: Boolean,
        isLoadingVisible: Boolean,
        expandAdvancedPermissionsEvent: Event<Unit>?,
        collapseAdvancedPermissionsEvent: Event<Unit>?,
        isAdvancedPermissionsExpanded: Boolean,
        isExtendExpirationDateButtonEnabled: Boolean,
        isExtendExpirationDateButtonVisible: Boolean,
        navBackEvent: Event<Unit>?,
        showSuccessMessageEvent: Event<String>?,
        showErrorMessageEvent: Event<String>?,
        checkSessionStatus: WalletConnectSessionDetailPreview.CheckSessionStatus?,
        isSessionStatusVisible: Boolean,
        informationBadge: WalletConnectSessionDetailPreview.InformationBadge?,
        navExtendSessionApproveBottomSheet: Event<WalletConnectSessionDetailPreview.ExpirationDate>?,
        navAdvancedPermissionsInfoBottomSheetEvent: Event<Unit>?
    ): WalletConnectSessionDetailPreview {
        return WalletConnectSessionDetailPreview(
            dappMetaData = dappMetaData,
            sessionDate = sessionDate,
            connectedAccountList = connectedAccountList,
            advancedPermissions = advancedPermissions,
            isInformationBadgeVisible = isInformationBadgeVisible,
            isLoadingVisible = isLoadingVisible,
            expandAdvancedPermissionsEvent = expandAdvancedPermissionsEvent,
            collapseAdvancedPermissionsEvent = collapseAdvancedPermissionsEvent,
            isAdvancedPermissionsExpanded = isAdvancedPermissionsExpanded,
            navBackEvent = navBackEvent,
            showSuccessMessageEvent = showSuccessMessageEvent,
            showErrorMessageEvent = showErrorMessageEvent,
            isExtendExpirationDateButtonEnabled = isExtendExpirationDateButtonEnabled,
            isExtendExpirationDateButtonVisible = isExtendExpirationDateButtonVisible,
            checkSessionStatus = checkSessionStatus,
            isSessionStatusVisible = isSessionStatusVisible,
            informationBadge = informationBadge,
            navExtendSessionApproveBottomSheet = navExtendSessionApproveBottomSheet,
            navAdvancedPermissionsInfoBottomSheetEvent = navAdvancedPermissionsInfoBottomSheetEvent
        )
    }

    fun mapToSessionDate(
        formattedConnectionDate: AnnotatedString,
        formattedExpirationDate: AnnotatedString?,
        isFormattedExpirationDateVisible: Boolean
    ): WalletConnectSessionDetailPreview.SessionDate {
        return WalletConnectSessionDetailPreview.SessionDate(
            formattedConnectionDate = formattedConnectionDate,
            formattedExpirationDate = formattedExpirationDate,
            isFormattedExpirationDateVisible = isFormattedExpirationDateVisible
        )
    }

    fun mapToAdvancedPermissions(
        supportedMethods: String?,
        isSupportedMethodsVisible: Boolean,
        supportedEvents: String?,
        isSupportedEventsVisible: Boolean,
        isAdvancedPermissionsVisible: Boolean,
        isDividerVisible: Boolean
    ): WalletConnectSessionDetailPreview.AdvancedPermissions {
        return WalletConnectSessionDetailPreview.AdvancedPermissions(
            supportedMethods = supportedMethods,
            isSupportedMethodsVisible = isSupportedMethodsVisible,
            supportedEvents = supportedEvents,
            isSupportedEventsVisible = isSupportedEventsVisible,
            isAdvancedPermissionsVisible = isAdvancedPermissionsVisible,
            isDividerVisible = isDividerVisible
        )
    }

    fun mapToDappMetaData(
        name: String,
        url: String,
        imageUrl: String?,
        description: String?,
        isDescriptionVisible: Boolean
    ): WalletConnectSessionDetailPreview.DappMetaData {
        return WalletConnectSessionDetailPreview.DappMetaData(
            name = name,
            url = url,
            imageUrl = imageUrl,
            description = description,
            isDescriptionVisible = isDescriptionVisible
        )
    }

    fun mapToConnectedAccountItem(
        accountAddress: String,
        accountPrimaryText: String,
        accountSecondaryText: String,
        accountIconDrawable: Drawable?,
        isAccountSecondaryTextVisible: Boolean,
        connectedNodeItemList: List<WalletConnectSessionDetailConnectedAccountItem.ConnectedNodeItem>
    ): WalletConnectSessionDetailConnectedAccountItem {
        return WalletConnectSessionDetailConnectedAccountItem(
            accountAddress = accountAddress,
            accountPrimaryText = accountPrimaryText,
            accountSecondaryText = accountSecondaryText,
            accountIconDrawable = accountIconDrawable,
            isAccountSecondaryTextVisible = isAccountSecondaryTextVisible,
            connectedNodeItemList = connectedNodeItemList
        )
    }

    fun mapToConnectedNodeItem(
        chainIdentifier: WalletConnect.ChainIdentifier
    ): WalletConnectSessionDetailConnectedAccountItem.ConnectedNodeItem {
        return WalletConnectSessionDetailConnectedAccountItem.ConnectedNodeItem(
            nodeName = chainIdentifier.name,
            textColorResId = connectedAccountNodeTextColorDecider.decideTextColor(chainIdentifier)
        )
    }

    fun mapToExpirationDate(
        formattedMaxExtendableExpirationDate: String,
        formattedExtendedExpirationDate: String
    ): WalletConnectSessionDetailPreview.ExpirationDate {
        return WalletConnectSessionDetailPreview.ExpirationDate(
            formattedMaxExtendableExpirationDate = formattedMaxExtendableExpirationDate,
            formattedExtendedExpirationDate = formattedExtendedExpirationDate
        )
    }
}
