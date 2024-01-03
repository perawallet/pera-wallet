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

package com.algorand.android.modules.walletconnect.sessiondetail.ui

import android.content.res.ColorStateList
import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.View
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.core.widget.TextViewCompat
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentWalletConnectSessionDetailBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailConnectedAccountItem
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview.AdvancedPermissions
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview.CheckSessionStatus
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview.ExpirationDate
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview.InformationBadge
import com.algorand.android.modules.walletconnect.validityextend.ui.WCSessionValidityExtensionBottomSheet
import com.algorand.android.utils.Event
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.loadPeerMetaIcon
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class WalletConnectSessionDetailFragment : BaseFragment(R.layout.fragment_wallet_connect_session_detail) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentWalletConnectSessionDetailBinding::bind)

    private val sessionDetailViewModel by viewModels<WalletConnectSessionDetailViewModel>()

    private val accountViewHolderLongClickListener = WalletConnectSessionDetailConnectedAccountsAdapter
        .AccountItemLongClickListener { address ->
            onAccountAddressCopied(address)
        }

    private val connectedAccountsAdapter = WalletConnectSessionDetailConnectedAccountsAdapter(
        accountViewHolderLongClickListener
    )

    private val dappMetaDataCollector: suspend (WalletConnectSessionDetailPreview.DappMetaData?) -> Unit = { dappMeta ->
        if (dappMeta != null) initDappMetaData(dappMeta)
    }

    private val sessionDateCollector: suspend (
        WalletConnectSessionDetailPreview.SessionDate?
    ) -> Unit = { sessionDate ->
        if (sessionDate != null) initSessionDate(sessionDate)
    }

    private val connectedAccountsCollector: suspend (List<WalletConnectSessionDetailConnectedAccountItem>?) -> Unit = {
        connectedAccountsAdapter.submitList(it.orEmpty())
    }

    private val advancedPermissionsCollector: suspend (AdvancedPermissions?) -> Unit = { permissions ->
        if (permissions != null) initAdvancedPermissions(permissions)
    }

    private val informationBadgeGroupVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.informationBadgeGroup.isVisible = isVisible == true
    }

    private val informationBadgeCollector: suspend (InformationBadge?) -> Unit = { informationBadge ->
        if (informationBadge != null) {
            binding.informationBadgeTextView.setText(informationBadge.badgeTextResId)
            binding.informationBadgeDescriptionTextView.setText(informationBadge.informationTextResId)
        }
    }

    private val loadingVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.progressBarContainer.loadingProgressBar.isVisible = isVisible == true
    }

    private val expandAdvancedPermissionsCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { binding.advancedPermissionsView.expandContainer() }
    }

    private val collapseAdvancedPermissionsCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { binding.advancedPermissionsView.collapseContainer() }
    }

    private val showErrorMessageEventCollector: suspend (Event<String>?) -> Unit = { event ->
        event?.consume()?.let { errorMessage ->
            showGlobalError(errorMessage, tag = baseActivityTag)
        }
    }

    private val showSuccessMessageEventCollector: suspend (Event<String>?) -> Unit = { event ->
        event?.consume()?.let { message ->
            showAlertSuccess(title = message, tag = baseActivityTag)
        }
    }

    private val navBackEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navBack() }
    }

    private val navEventExtendApproveBottomSheetCollector: suspend (Event<ExpirationDate>?) -> Unit = { event ->
        event?.consume()?.run {
            nav(
                WalletConnectSessionDetailFragmentDirections
                    .actionWalletConnectSessionDetailFragmentToWCSessionValidityExtensionBottomSheet(
                        formattedMaxExtendableExpirationDate = formattedMaxExtendableExpirationDate,
                        formattedExtendedSessionValidityDate = formattedExtendedExpirationDate
                    )
            )
        }
    }

    private val navAdvancedPermissionsInfoBottomSheetEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run {
            nav(
                WalletConnectSessionDetailFragmentDirections
                    .actionWalletConnectSessionDetailFragmentToWalletConnectAdvancedPermissionsInfoBottomSheet()
            )
        }
    }

//    private val isExtendExpirationDateButtonEnabledCollector: suspend (Boolean?) -> Unit = { isEnabled ->
//        binding.extendSessionValidityButton.isEnabled = isEnabled == true
//    }
//
//    private val isExtendExpirationDateButtonVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
//        binding.extendSessionValidityButton.isVisible = isVisible == true
//    }

    private val sessionStatusVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.checkStatusGroup.isVisible = isVisible == true
    }

    private val checkSessionStatusCollector: suspend (CheckSessionStatus?) -> Unit = { checkSessionStatus ->
        if (checkSessionStatus != null) initCheckSessionStatus(checkSessionStatus)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            disconnectButton.setOnClickListener { sessionDetailViewModel.onDisconnectFromSessionClick() }
//            extendSessionValidityButton.setOnClickListener { sessionDetailViewModel.onExtendSessionClick() }
            dAppUrlTextView.movementMethod = LinkMovementMethod()
            advancedPermissionsView.apply {
                setOnTitleClickListener { sessionDetailViewModel.onAdvancedPermissionsClick() }
                setOnInfoTextClickListener { sessionDetailViewModel.onAdvancedPermissionsInfoClick() }
            }
            checkStatusTextView.setOnClickListener { sessionDetailViewModel.onCheckStatusClick() }
            connectedAccountsRecyclerView.apply {
                adapter = connectedAccountsAdapter
                itemAnimator = null
                overScrollMode = View.OVER_SCROLL_NEVER
            }
        }
    }

    override fun onResume() {
        super.onResume()
        useFragmentResultListenerValue<Boolean>(
            key = WCSessionValidityExtensionBottomSheet.WC_SESSION_VALIDITY_EXTENSION_RESULT_KEY,
            result = { isConfirmed -> if (isConfirmed) sessionDetailViewModel.onExtendSessionApproved() }
        )
    }

    @Suppress("LongMethod")
    private fun initObservers() {
        with(sessionDetailViewModel.sessionDetailPreview) {
            collectLatestOnLifecycle(
                flow = map { it?.dappMetaData }.distinctUntilChanged(),
                collection = dappMetaDataCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.sessionDate }.distinctUntilChanged(),
                collection = sessionDateCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.advancedPermissions }.distinctUntilChanged(),
                collection = advancedPermissionsCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.connectedAccountList }.distinctUntilChanged(),
                collection = connectedAccountsCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isInformationBadgeVisible }.distinctUntilChanged(),
                collection = informationBadgeGroupVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isLoadingVisible }.distinctUntilChanged(),
                collection = loadingVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.expandAdvancedPermissionsEvent }.distinctUntilChanged(),
                collection = expandAdvancedPermissionsCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.collapseAdvancedPermissionsEvent }.distinctUntilChanged(),
                collection = collapseAdvancedPermissionsCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.showErrorMessageEvent }.distinctUntilChanged(),
                collection = showErrorMessageEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.showSuccessMessageEvent }.distinctUntilChanged(),
                collection = showSuccessMessageEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.navBackEvent }.distinctUntilChanged(),
                collection = navBackEventCollector
            )
//            collectLatestOnLifecycle(
//                flow = map { it?.isExtendExpirationDateButtonVisible }.distinctUntilChanged(),
//                collection = isExtendExpirationDateButtonVisibilityCollector
//            )
//            collectLatestOnLifecycle(
//                flow = map { it?.isExtendExpirationDateButtonEnabled }.distinctUntilChanged(),
//                collection = isExtendExpirationDateButtonEnabledCollector
//            )
            collectLatestOnLifecycle(
                flow = map { it?.checkSessionStatus }.distinctUntilChanged(),
                collection = checkSessionStatusCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isSessionStatusVisible }.distinctUntilChanged(),
                collection = sessionStatusVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.informationBadge }.distinctUntilChanged(),
                collection = informationBadgeCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.navExtendSessionApproveBottomSheet }.distinctUntilChanged(),
                collection = navEventExtendApproveBottomSheetCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.navAdvancedPermissionsInfoBottomSheetEvent }.distinctUntilChanged(),
                collection = navAdvancedPermissionsInfoBottomSheetEventCollector
            )
        }
    }

    private fun initDappMetaData(dappMetaData: WalletConnectSessionDetailPreview.DappMetaData) {
        with(binding) {
            dAppIconImageView.loadPeerMetaIcon(dappMetaData.imageUrl)
            dAppNameTextView.text = dappMetaData.name
            dAppUrlTextView.apply {
                text = dappMetaData.url
                setOnClickListener { context?.openUrl(dappMetaData.url) }
            }
            dAppDescriptionTextView.apply {
                text = dappMetaData.description
                isVisible = dappMetaData.isDescriptionVisible
            }
        }
    }

    private fun initSessionDate(sessionDate: WalletConnectSessionDetailPreview.SessionDate) {
        with(binding) {
            connectionDateTextView.text = root.context.getXmlStyledString(sessionDate.formattedConnectionDate)
            expirationDateGroup.isVisible = sessionDate.isFormattedExpirationDateVisible
            if (sessionDate.formattedExpirationDate != null) {
                expirationDateTextView.text = root.context.getXmlStyledString(sessionDate.formattedExpirationDate)
            }
        }
    }

    private fun initAdvancedPermissions(advancedPermissions: AdvancedPermissions) {
        with(binding.advancedPermissionsView) {
            with(advancedPermissions) {
                isVisible = isAdvancedPermissionsVisible
                setSupportedMethods(supportedMethods.orEmpty(), isSupportedMethodsVisible)
                setSupportedEvents(supportedEvents.orEmpty(), isSupportedEventsVisible)
                isDividerVisible(isDividerVisible)
            }
        }
    }

    private fun initCheckSessionStatus(checkSessionStatus: CheckSessionStatus) {
        with(binding.checkStatusTextView) {
            with(checkSessionStatus) {
                setText(buttonTextResId)
                val textColor = ContextCompat.getColor(context, buttonTextColorResId)
                setTextColor(textColor)
                val startDrawable = if (buttonStartIconResId != null) {
                    AppCompatResources.getDrawable(context, buttonStartIconResId)
                } else {
                    null
                }
                setDrawable(start = startDrawable)
                TextViewCompat.setCompoundDrawableTintList(
                    binding.checkStatusTextView,
                    ColorStateList.valueOf(textColor)
                )
                isClickable = isButtonEnabled
            }
        }
    }
}
