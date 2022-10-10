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

package com.algorand.android.ui.wctransactionrequest

import android.content.Context
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import androidx.fragment.app.viewModels
import com.algorand.android.models.TransactionRequestAction
import com.algorand.android.modules.assets.profile.asaprofile.base.BaseAsaProfileFragment
import com.algorand.android.modules.assets.profile.asaprofile.ui.AsaProfileFragmentDirections
import com.algorand.android.utils.PERA_VERIFICATION_MAIL_ADDRESS
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.getCustomLongClickableSpan
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectBaseAsaProfileFragment : BaseAsaProfileFragment() {

    private var transactionRequestListener: TransactionRequestAction? = null

    override val asaProfileViewModel by viewModels<WalletConnectBaseAsaProfileViewModel>()

    override fun onAttach(context: Context) {
        super.onAttach(context)
        transactionRequestListener = parentFragment?.parentFragment as? TransactionRequestAction
    }

    override fun onReportActionFailed() {
        val longClickSpannable = getCustomLongClickableSpan(
            clickableColor = ContextCompat.getColor(binding.root.context, R.color.positive),
            onLongClick = { context?.copyToClipboard(PERA_VERIFICATION_MAIL_ADDRESS) }
        )
        val titleAnnotatedString = AnnotatedString(R.string.report_an_asa)
        val descriptionAnnotatedString = AnnotatedString(
            stringResId = R.string.you_can_send_us_an,
            customAnnotationList = listOf("verification_mail_click" to longClickSpannable),
            replacementList = listOf("verification_mail" to PERA_VERIFICATION_MAIL_ADDRESS)
        )
        nav(
            WalletConnectBaseAsaProfileFragmentDirections.actionAsaProfileFragmentToSingleButtonBottomSheetNavigation(
                titleAnnotatedString = titleAnnotatedString,
                descriptionAnnotatedString = descriptionAnnotatedString,
                buttonStringResId = R.string.got_it,
                drawableResId = R.drawable.ic_flag,
                drawableTintResId = R.color.negative,
                shouldDescriptionHasLinkMovementMethod = true
            )
        )
    }

    override fun onTotalSupplyClick() {
        nav(WalletConnectBaseAsaProfileFragmentDirections.actionAsaProfileFragmentToAssetTotalSupplyNavigation())
    }

    override fun onBackButtonClick() {
        transactionRequestListener?.onNavigateBack()
    }

    override fun onAccountSelected(selectedAccountAddress: String) {
        asaProfileViewModel.setSelectedAccountAddress(selectedAccountAddress)
    }

    override fun navToAccountSelection() {
        transactionRequestListener?.onNavigate(
            AsaProfileFragmentDirections.actionAsaProfileFragmentToAsaProfileAccountSelectionFragment(
                assetShortName = assetShortName.orEmpty()
            )
        )
    }

    override fun navToAssetAdditionFlow() {
        val assetAction = asaProfileViewModel.getAssetAction()
        transactionRequestListener?.onNavigate(
            AsaProfileFragmentDirections.actionAsaProfileFragmentToAssetAdditionActionNavigation(
                assetAction = assetAction
            )
        )
    }
}
