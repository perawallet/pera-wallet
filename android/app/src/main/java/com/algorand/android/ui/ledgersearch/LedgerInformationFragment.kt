/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.ledgersearch

import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.TextView
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.core.view.updateLayoutParams
import androidx.core.view.updateMarginsRelative
import androidx.core.view.updatePaddingRelative
import androidx.core.widget.TextViewCompat
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetLedgerInformationBinding
import com.algorand.android.models.Account
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.dp
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.viewbinding.viewBinding

class LedgerInformationFragment :
    BaseBottomSheet(R.layout.bottom_sheet_ledger_information, fullPageNeeded = true) {

    // TODO get shape directly from material shape for bottom sheet
    override fun getTheme() = R.style.BottomSheetDialogTheme_Tertiary

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    private val args: LedgerInformationFragmentArgs by navArgs()

    private val binding by viewBinding(BottomSheetLedgerInformationBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.toolbar.configure(toolbarConfiguration)
        setupToolbarTitle()
        setupAccountView()
        setupAuthAccount()
        setupRekeyedAccounts()
    }

    private fun setupAccountView() {
        with(args.selectedLedgerAccountSelectionListItem) {
            binding.collapsibleAccountView.setAccountBalanceInformation(
                name = account.name,
                accountIconResId = accountImageResource,
                assetsInformation = assetInformationList
            )
        }
    }

    private fun setupToolbarTitle() {
        when (val detail = args.selectedLedgerAccountSelectionListItem.account.detail) {
            is Account.Detail.Ledger -> {
                binding.toolbar.changeTitle(
                    context?.getXmlStyledString(
                        stringResId = R.string.ledger_position,
                        replacementList = listOf("account_index" to (detail.positionInLedger + 1).toString())
                    ).toString()
                )
            }
            is Account.Detail.RekeyedAuth -> {
                binding.toolbar.changeTitle(
                    args.selectedLedgerAccountSelectionListItem.account.address.toShortenedAddress()
                )
            }
        }
    }

    private fun addLabel(@StringRes labelResId: Int) {
        TextView(context).apply {
            setText(labelResId)
            TextViewCompat.setTextAppearance(this, R.style.TextAppearance_BodyMedium)
            setTextColor(ContextCompat.getColor(context, R.color.tertiaryTextColor))
            binding.rootLayout.addView(this)
            updateLayoutParams<ViewGroup.MarginLayoutParams> {
                updateMarginsRelative(
                    start = resources.getDimensionPixelOffset(R.dimen.page_horizontal_spacing),
                    bottom = context.dp(LABEL_BOTTOM_MARGIN),
                    top = context.dp(LABEL_TOP_MARGIN)
                )
            }
        }
    }

    private fun addAccountHeader(@DrawableRes accountResId: Int, accountPublicKey: String) {
        TextView(context).apply {
            text = accountPublicKey.toShortenedAddress()
            setBackgroundResource(R.drawable.bg_small_shadow)
            compoundDrawablePadding = context.dp(ACCOUNT_DRAWABLE_PADDING)
            setDrawable(start = AppCompatResources.getDrawable(context, accountResId))
            TextViewCompat.setTextAppearance(this, R.style.TextAppearance_AccountHeader)
            binding.rootLayout.addView(this)
            updateLayoutParams<ViewGroup.MarginLayoutParams> {
                width = MATCH_PARENT
                height = WRAP_CONTENT
                updatePaddingRelative(
                    start = resources.getDimensionPixelOffset(R.dimen.smallshadow_start_padding_16dp),
                    end = resources.getDimensionPixelOffset(R.dimen.smallshadow_end_padding_16dp),
                    top = resources.getDimensionPixelOffset(R.dimen.smallshadow_top_padding_14dp),
                    bottom = resources.getDimensionPixelOffset(R.dimen.smallshadow_bottom_padding_14dp)
                )
                updateMarginsRelative(
                    top = resources.getDimensionPixelOffset(R.dimen.smallshadow_top_margin_2dp),
                    start = resources.getDimensionPixelOffset(R.dimen.smallshadow_start_20dp_margin),
                    end = resources.getDimensionPixelOffset(R.dimen.smallshadow_end_20dp_margin),
                    bottom = resources.getDimensionPixelOffset(R.dimen.smallshadow_bottom_margin_10dp)
                )
            }
        }
    }

    private fun setupAuthAccount() {
        args.authLedgerAccountSelectionListItem?.run {
            addLabel(R.string.can_be_signed_by)
            addAccountHeader(accountImageResource, account.address)
        }
    }

    private fun setupRekeyedAccounts() {
        if (args.selectedLedgerAccountSelectionListItem.account.type != Account.Type.REKEYED_AUTH) {
            args.rekeyedAccountSelectionListItem?.takeIf { it.isNotEmpty() }?.run {
                addLabel(R.string.can_sign_for_these)
                forEach { rekeyedAccountListItems ->
                    addAccountHeader(
                        accountResId = rekeyedAccountListItems.accountImageResource,
                        accountPublicKey = rekeyedAccountListItems.account.address
                    )
                }
            }
        }
    }

    companion object {
        private const val ACCOUNT_DRAWABLE_PADDING = 12
        private const val LABEL_BOTTOM_MARGIN = 10
        private const val LABEL_TOP_MARGIN = 40
    }
}
