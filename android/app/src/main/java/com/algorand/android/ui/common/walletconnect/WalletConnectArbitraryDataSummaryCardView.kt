/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.common.walletconnect

import android.content.Context
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectArbitraryDataSummaryViewBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.ui.wcarbitrarydatarequest.WalletConnectArbitraryDataListItem
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.extensions.changeTextAppearance
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding

class WalletConnectArbitraryDataSummaryCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectArbitraryDataSummaryViewBinding::inflate)

    init {
        initRootLayout()
    }

    fun initArbitraryData(
        singleArbitraryData: WalletConnectArbitraryDataListItem.ArbitraryDataItem,
        listener: OnShowDetailClickListener
    ) {
        with(singleArbitraryData.arbitraryDataSummary) {
            setAccountInformationText(
                accountName,
                accountIconDrawablePreview
            )
            setTitleText(summaryTitle)
            with(binding.showArbitraryDataDetailButton) {
                setText(showMoreButtonText)
                setOnClickListener { listener.onShowDetailClick(singleArbitraryData.arbitraryData) }
            }
        }
    }

    fun setTitleText(
        summaryTitle: AnnotatedString?
    ) {
        if (summaryTitle != null) setSummaryTitleGroup(summaryTitle)
    }

    private fun setSummaryTitleGroup(summaryTitle: AnnotatedString) {
        with(binding.arbitraryDatasAmountTextView) {
            text = context?.getXmlStyledString(summaryTitle)
            changeTextAppearance(R.style.TextAppearance_Body_Large_Sans)
        }
    }

    private fun setAccountInformationText(
        accountName: String?,
        accountIconDrawablePreview: AccountIconDrawablePreview?
    ) {
        with(binding) {
            if (accountIconDrawablePreview != null) {
                arbitraryDataAccountTypeImageView.apply {
                    val accountIconDrawable = AccountIconDrawable.create(
                        context = context,
                        accountIconDrawablePreview = accountIconDrawablePreview,
                        sizeResId = R.dimen.spacing_large
                    )
                    setImageDrawable(accountIconDrawable)
                    show()
                }
            }
            arbitraryDataAccountNameTextView.setTextAndVisibility(accountName)
        }
    }

    private fun initRootLayout() {
        setBackgroundResource(R.drawable.bg_passphrase_group_background)
        setPadding(resources.getDimensionPixelSize(R.dimen.spacing_large))
    }

    fun interface OnShowDetailClickListener {
        fun onShowDetailClick(arbitraryData: WalletConnectArbitraryData)
    }
}
