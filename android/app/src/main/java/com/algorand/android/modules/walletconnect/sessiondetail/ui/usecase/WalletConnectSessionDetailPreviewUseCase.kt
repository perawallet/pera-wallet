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

package com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase

import android.content.Context
import android.text.style.ForegroundColorSpan
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.walletconnect.client.v2.ui.launchback.usecase.GetFormattedWCSessionExtendedExpirationDateUseCase
import com.algorand.android.modules.walletconnect.client.v2.ui.launchback.usecase.GetFormattedWCSessionMaxExpirationDateUseCase
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import com.algorand.android.modules.walletconnect.sessiondetail.ui.mapper.WalletConnectSessionDetailPreviewMapper
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailConnectedAccountItem
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.Event
import com.algorand.android.utils.HOUR_MINUTE_AM_PM_PATTERN
import com.algorand.android.utils.MONTH_DAY_YEAR_PATTERN
import com.algorand.android.utils.format
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class WalletConnectSessionDetailPreviewUseCase @Inject constructor(
    @ApplicationContext private val appContext: Context,
    private val walletConnectManager: WalletConnectManager,
    private val sessionDetailPreviewMapper: WalletConnectSessionDetailPreviewMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase,
    @Named(WalletConnectSessionDetailPreviewStateProvider.INJECTION_NAME)
    private val previewStateProvider: WalletConnectSessionDetailPreviewStateProvider,
    private val getFormattedWCSessionMaxExpirationDateUseCase: GetFormattedWCSessionMaxExpirationDateUseCase,
    private val getFormattedWCSessionExtendedExpirationDateUseCase: GetFormattedWCSessionExtendedExpirationDateUseCase
) {

    fun getInitialPreview(sessionIdentifier: WalletConnectSessionIdentifier) = flow<WalletConnectSessionDetailPreview> {
        // TODO Handle null case
        val sessionDetail = walletConnectManager.getWalletConnectSession(sessionIdentifier) ?: return@flow
        val sessionStatusInitialState = previewStateProvider.getInitialCheckSessionStatus(sessionIdentifier)
        val informationBadge = previewStateProvider.getInformationBadgeDetail(sessionIdentifier)
        val sessionDetailPreview = sessionDetailPreviewMapper.mapToPreview(
            dappMetaData = getDappMetaData(sessionDetail),
            sessionDate = getSessionDate(sessionDetail),
            connectedAccountList = getConnectedAccountsList(sessionDetail),
            advancedPermissions = getAdvancedPermissions(sessionDetail),
            isLoadingVisible = false,
            expandAdvancedPermissionsEvent = null,
            collapseAdvancedPermissionsEvent = null,
            isAdvancedPermissionsExpanded = false,
            navBackEvent = null,
            showSuccessMessageEvent = null,
            showErrorMessageEvent = null,
            isExtendExpirationDateButtonEnabled = previewStateProvider
                .isExtendExpirationDateButtonEnabled(sessionIdentifier),
            isExtendExpirationDateButtonVisible = previewStateProvider
                .isExtendExpirationDateButtonVisible(sessionIdentifier),
            isSessionStatusVisible = sessionStatusInitialState != null,
            checkSessionStatus = sessionStatusInitialState,
            isInformationBadgeVisible = informationBadge != null,
            informationBadge = informationBadge,
            navExtendSessionApproveBottomSheet = null,
            navAdvancedPermissionsInfoBottomSheetEvent = null
        )
        emit(sessionDetailPreview)
    }

    private fun getDappMetaData(
        sessionDetail: WalletConnect.SessionDetail
    ): WalletConnectSessionDetailPreview.DappMetaData {
        return with(sessionDetail.peerMeta) {
            sessionDetailPreviewMapper.mapToDappMetaData(
                name = name,
                url = url,
                imageUrl = icons?.first(),
                description = description,
                isDescriptionVisible = !description.isNullOrBlank()
            )
        }
    }

    private fun getSessionDate(
        sessionDetail: WalletConnect.SessionDetail
    ): WalletConnectSessionDetailPreview.SessionDate {
        val connectionDateAnnotatedString = getDateAnnotatedString(sessionDetail.creationDateTimestamp)
        val expirationDateAnnotatedString: AnnotatedString? = if (sessionDetail.expiry != null) {
            getDateAnnotatedString(sessionDetail.expiry.seconds)
        } else {
            null
        }
        return sessionDetailPreviewMapper.mapToSessionDate(
            formattedConnectionDate = connectionDateAnnotatedString,
            formattedExpirationDate = expirationDateAnnotatedString,
            isFormattedExpirationDateVisible = sessionDetail.expiry != null
        )
    }

    private fun getDateAnnotatedString(timeStampAsSecond: Long): AnnotatedString {
        val timeStampZonedDateTime = timeStampAsSecond.getZonedDateTimeFromTimeStamp()
        val formattedDate = timeStampZonedDateTime.format(MONTH_DAY_YEAR_PATTERN)
        val formattedHour = timeStampZonedDateTime.format(HOUR_MINUTE_AM_PM_PATTERN)
        val hourTextColor = ContextCompat.getColor(appContext, R.color.text_gray)
        return AnnotatedString(
            stringResId = R.string.date_hour_pair_formatted_and_colored,
            replacementList = listOf(
                "date" to formattedDate,
                "hour" to formattedHour
            ),
            customAnnotationList = listOf("hour_text_color" to ForegroundColorSpan(hourTextColor))
        )
    }

    private fun getAdvancedPermissions(
        sessionDetail: WalletConnect.SessionDetail
    ): WalletConnectSessionDetailPreview.AdvancedPermissions {
        val algorandNamespace = sessionDetail.namespaces[WalletConnectBlockchain.ALGORAND]
        val events = algorandNamespace?.events?.joinToString(NEW_LINE_ESCAPE_CHAR) { it.value }
        val methods = algorandNamespace?.methods?.joinToString(NEW_LINE_ESCAPE_CHAR) { it.value }
        val isEventPermissionsVisible = !events.isNullOrEmpty()
        val isMethodPermissionsVisible = !methods.isNullOrEmpty()
        return sessionDetailPreviewMapper.mapToAdvancedPermissions(
            supportedMethods = methods,
            isSupportedMethodsVisible = isMethodPermissionsVisible,
            supportedEvents = events,
            isSupportedEventsVisible = isEventPermissionsVisible,
            isAdvancedPermissionsVisible = isEventPermissionsVisible || isMethodPermissionsVisible,
            isDividerVisible = isEventPermissionsVisible && isMethodPermissionsVisible
        )
    }

    fun getAdvancedPermissionClickedPreview(
        previousPreview: WalletConnectSessionDetailPreview,
    ): WalletConnectSessionDetailPreview {
        return if (previousPreview.isAdvancedPermissionsExpanded) {
            previousPreview.copy(
                collapseAdvancedPermissionsEvent = Event(Unit),
                isAdvancedPermissionsExpanded = false
            )
        } else {
            previousPreview.copy(
                expandAdvancedPermissionsEvent = Event(Unit),
                isAdvancedPermissionsExpanded = true
            )
        }
    }

    suspend fun getDisconnectClickedPreview(
        sessionIdentifier: WalletConnectSessionIdentifier,
        previousPreview: WalletConnectSessionDetailPreview
    ): WalletConnectSessionDetailPreview {
        walletConnectManager.killSession(sessionIdentifier)
        return previousPreview.copy(
            navBackEvent = Event(Unit),
            showSuccessMessageEvent = Event(appContext.getString(R.string.session_disconnected_successfully))
        )
    }

    suspend fun getExtendClickedPreview(
        sessionIdentifier: WalletConnectSessionIdentifier,
        previousPreview: WalletConnectSessionDetailPreview
    ): WalletConnectSessionDetailPreview {
        val extendedExpirationDate = getFormattedWCSessionExtendedExpirationDateUseCase(sessionIdentifier)
        val maxExtendableExpirationDate = getFormattedWCSessionMaxExpirationDateUseCase(sessionIdentifier)
        val expirationDate = sessionDetailPreviewMapper.mapToExpirationDate(
            formattedMaxExtendableExpirationDate = maxExtendableExpirationDate,
            formattedExtendedExpirationDate = extendedExpirationDate
        )

        return previousPreview.copy(
            navExtendSessionApproveBottomSheet = Event(expirationDate)
        )
    }

    suspend fun getExtendSessionApprovedPreview(
        sessionIdentifier: WalletConnectSessionIdentifier,
        previousPreview: WalletConnectSessionDetailPreview
    ): Flow<WalletConnectSessionDetailPreview> = flow {
        emit(previousPreview.copy(isLoadingVisible = true))
        val result = walletConnectManager.extendSessionExpirationDate(sessionIdentifier)
        val updatedPreview = if (result.isSuccess) {
            getExtendSessionSuccessPreview(sessionIdentifier, previousPreview)
        } else {
            previousPreview.copy(
                showErrorMessageEvent = Event(appContext.getString(R.string.an_error_occured))
            )
        }
        emit(updatedPreview)
    }

    suspend fun getCheckStatusClickedPreview(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): Flow<WalletConnectSessionDetailPreview.CheckSessionStatus?> = flow {
        emit(previewStateProvider.getLoadingStateForCheckSessionStatus(sessionIdentifier))
        val result = walletConnectManager.checkSessionStatus(sessionIdentifier)
        if (result.isSuccess) {
            emit(previewStateProvider.getSuccessStateForCheckSessionStatus(sessionIdentifier))
        } else {
            emit(previewStateProvider.getErrorStateForCheckSessionStatus(sessionIdentifier))
        }
        delay(CHECK_STATUS_INITIAL_STATE_DELAY_AS_MS)
        emit(previewStateProvider.getInitialCheckSessionStatus(sessionIdentifier))
    }

    private suspend fun getExtendSessionSuccessPreview(
        sessionIdentifier: WalletConnectSessionIdentifier,
        previousPreview: WalletConnectSessionDetailPreview
    ): WalletConnectSessionDetailPreview {
        val sessionDetail = walletConnectManager.getWalletConnectSession(sessionIdentifier)
        val isExtendExpirationDateButtonEnabled = previewStateProvider
            .isExtendExpirationDateButtonEnabled(sessionIdentifier)
        return if (sessionDetail == null) {
            previousPreview.copy(
                showErrorMessageEvent = Event(appContext.getString(R.string.an_error_occured)),
                isExtendExpirationDateButtonEnabled = isExtendExpirationDateButtonEnabled
            )
        } else {
            previousPreview.copy(
                sessionDate = getSessionDate(sessionDetail),
                isExtendExpirationDateButtonEnabled = isExtendExpirationDateButtonEnabled,
                showSuccessMessageEvent = Event(appContext.getString(R.string.session_extended_successfully))
            )
        }
    }

    private fun getConnectedAccountsList(
        sessionDetail: WalletConnect.SessionDetail
    ): List<WalletConnectSessionDetailConnectedAccountItem> {
        return sessionDetail.namespaces[WalletConnectBlockchain.ALGORAND]?.accounts?.groupBy {
            it.accountAddress
        }?.map { (address, connectedAccount) ->
            val accountIconDrawable = AccountIconDrawable.create(
                context = appContext,
                accountIconResource = accountDetailUseCase.getAccountIcon(address),
                size = appContext.resources.getDimensionPixelSize(R.dimen.account_icon_size_large)
            )
            val accountDisplayName = accountDisplayNameUseCase(address)
            val accountSecondaryText = accountDisplayName.getAccountSecondaryDisplayName(appContext.resources)
            sessionDetailPreviewMapper.mapToConnectedAccountItem(
                accountAddress = address,
                accountPrimaryText = accountDisplayName.getAccountPrimaryDisplayName(),
                accountSecondaryText = accountSecondaryText.orEmpty(),
                accountIconDrawable = accountIconDrawable,
                isAccountSecondaryTextVisible = !accountSecondaryText.isNullOrBlank(),
                connectedNodeItemList = connectedAccount.map {
                    sessionDetailPreviewMapper.mapToConnectedNodeItem(it.chainIdentifier)
                }
            )
        }.orEmpty()
    }

    fun getAdvancedPermissionsInfoClickUpdatedPreview(
        currentPreview: WalletConnectSessionDetailPreview
    ): WalletConnectSessionDetailPreview {
        return currentPreview.copy(
            navAdvancedPermissionsInfoBottomSheetEvent = Event(Unit)
        )
    }

    companion object {
        private const val CHECK_STATUS_INITIAL_STATE_DELAY_AS_MS = 3000L
        private const val NEW_LINE_ESCAPE_CHAR = "\n"
    }
}
