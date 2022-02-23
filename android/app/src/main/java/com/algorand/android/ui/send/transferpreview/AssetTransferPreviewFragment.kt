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

package com.algorand.android.ui.send.transferpreview

import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentTransferAssetPreviewBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetTransferPreview
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SendTransactionResponse
import com.algorand.android.models.TargetUser
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.ALGOS_SHORT_NAME
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.extensions.changeTextAppearance
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.toAlgoDisplayValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigDecimal
import java.math.BigInteger
import java.util.Locale
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AssetTransferPreviewFragment : BaseFragment(R.layout.fragment_transfer_asset_preview) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        titleResId = R.string.confirm_transaction,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val assetTransferPreviewViewModel: AssetTransferPreviewViewModel by viewModels()

    private val binding by viewBinding(FragmentTransferAssetPreviewBinding::bind)

    private val assetTransferPreviewCollector: suspend (AssetTransferPreview?) -> Unit = {
        it?.let { updateUi(it) }
    }

    private val sendAlgoResponseCollector: suspend (Event<Resource<SendTransactionResponse>>?) -> Unit = {
        it?.consume()?.use(
            onSuccess = {
                nav(
                    AssetTransferPreviewFragmentDirections
                        .actionAssetTransferPreviewFragmentToTransactionConfirmationFragment()
                )
            },
            onFailed = { showGlobalError(it.parse(requireContext())) },
            onLoading = ::showProgress,
            onLoadingFinished = ::hideProgress
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            assetTransferPreviewViewModel.assetTransferPreviewFlow.collectLatest(assetTransferPreviewCollector)
        }
        viewLifecycleOwner.lifecycleScope.launch {
            assetTransferPreviewViewModel.sendAlgoResponseFlow.collectLatest(sendAlgoResponseCollector)
        }
    }

    private fun onNextButtonClick() {
        assetTransferPreviewViewModel.sendSignedTransaction()
    }

    private fun updateUi(assetTransferPreview: AssetTransferPreview) {
        with(assetTransferPreview) {
            setNextButton(assetInformation.isAlgo())
            setCurrencyViews(assetInformation, exchangePrice, currencySymbol, amount)
            setAssetViews(assetInformation, amount)
            setAccountViews(targetUser, accountCacheData)
            setFee(fee)
            setNote(note)
        }
    }

    private fun setNextButton(isAlgorand: Boolean) {
        with(binding.nextButton) {
            text = if (isAlgorand) {
                // TODO get formatted shortname from AlgoInfoProvider
                getString(
                    R.string.send_format,
                    ALGOS_SHORT_NAME.toLowerCase(Locale.getDefault()).capitalize(Locale.getDefault())
                )
            } else {
                getString(R.string.next)
            }
            setOnClickListener { onNextButtonClick() }
        }
    }

    private fun setCurrencyViews(
        assetInformation: AssetInformation,
        exchangePrice: BigDecimal,
        currencySymbol: String,
        amount: BigInteger
    ) {
        with(binding) {
            if (assetInformation.isAlgo()) {
                algoCurrencyValueTextView.setTextAndVisibility(
                    amount.toAlgoDisplayValue().multiply(exchangePrice).formatAsCurrency(currencySymbol)
                )
                balanceCurrencyValueTextView.setTextAndVisibility(
                    assetInformation.amount?.toAlgoDisplayValue()
                        ?.multiply(exchangePrice)
                        ?.formatAsCurrency(currencySymbol)
                )
            }
        }
    }

    private fun setAssetViews(assetInformation: AssetInformation, amount: BigInteger) {
        with(binding) {
            assetBalanceTextView.setAmount(amount = assetInformation.amount, assetInformation = assetInformation)
            assetAmountTextView.setAmount(amount = amount, assetInformation = assetInformation)
            if (assetInformation.isAlgo()) {
                assetBalanceTextView.setTextColor(ContextCompat.getColor(root.context, R.color.tertiaryTextColor))
            } else {
                assetBalanceTextView.changeTextAppearance(R.style.TextAppearance_Body_Mono)
            }
        }
    }

    private fun setAccountViews(targetUser: TargetUser, fromAccountCacheData: AccountCacheData) {
        with(binding) {
            accountUserView.setAccount(fromAccountCacheData)
            toUserView.setOnAddButtonClickListener(::onAddButtonClicked)
            when {
                targetUser.contact != null -> toUserView.setContact(targetUser.contact)
                targetUser.account != null -> toUserView.setAccount(targetUser.account)
                else -> toUserView.setAddress(targetUser.publicKey)
            }
        }
    }

    private fun setFee(fee: Long) {
        binding.feeAmountView.setAmountAsFee(fee)
    }

    private fun setNote(note: String?) {
        with(binding) {
            if (!note.isNullOrBlank()) {
                noteTextView.text = note
                noteGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun onAddButtonClicked(address: String) {
        nav(HomeNavigationDirections.actionGlobalAddContactFragment(contactPublicKey = address))
    }

    private fun showProgress() {
        binding.progressBar.root.show()
    }

    private fun hideProgress() {
        binding.progressBar.root.hide()
    }
}
