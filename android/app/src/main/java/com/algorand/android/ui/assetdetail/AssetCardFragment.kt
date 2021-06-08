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

package com.algorand.android.ui.assetdetail

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentAssetCardBinding
import com.algorand.android.models.AlgoBalanceInformation
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.CurrencyValue
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.utils.enableClickToCopy
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsAlgoRewardString
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigInteger
import kotlin.properties.Delegates
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AssetCardFragment : DaggerBaseFragment(R.layout.fragment_asset_card) {

    private val assetDetailViewModel: AssetCardViewModel by viewModels()

    private val binding by viewBinding(FragmentAssetCardBinding::bind)

    private lateinit var address: String
    private lateinit var assetInformation: AssetInformation
    private var listener: Listener? = null

    override val fragmentConfiguration = FragmentConfiguration()

    private val balanceInCurrencyObserver = Observer<String> { balanceInCurrency ->
        binding.balanceInCurrencyTextView.text = balanceInCurrency
    }

    private val balanceObserver = Observer<BigInteger?> { newBalance ->
        balance = newBalance
    }

    private var balance by Delegates.observable<BigInteger?>(null) { _, _, newValue ->
        if (newValue != null) {
            setBalanceTextView(newValue)
        }
    }

    private val algoBalanceInformationObserver = Observer<AlgoBalanceInformation> { algoBalanceInfo ->
        setAlgoBalanceInformation(algoBalanceInfo)
    }

    private var selectedCurrencyValue: CurrencyValue? by Delegates.observable(null) { _, oldValue, newValue ->
        if (newValue != null && newValue != oldValue) {
            with(binding) {
                analyticsButton.isEnabled = true
                algoCurrencyValueTextView.text = getString(
                    R.string.algo_exchange_price_format,
                    newValue.getFormattedSignedCurrencyValue()
                )
            }
        }
    }

    private val currencyValueObserver = Observer<CurrencyValue> { currencyValue ->
        selectedCurrencyValue = currencyValue
    }

    override fun onAttach(context: Context) {
        listener = parentFragment as? Listener
        super.onAttach(context)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        arguments?.run {
            address = getString(PARAM_ADDRESS, null) ?: return
            assetInformation = getParcelable(PARAM_ASSET_INFORMATION) ?: return
            assetDetailViewModel.start(address, assetInformation)
        } ?: return
        loadData()
        initObservers()
    }

    private val latestBlockNumberCollector: suspend (Long?) -> Unit = { blockNumber ->
        assetDetailViewModel.calculatePendingRewards(blockNumber)
    }

    private fun initObservers() {
        with(assetDetailViewModel) {
            if (assetInformation.isAlgorand()) {
                balanceInCurrencyValue?.observe(viewLifecycleOwner, balanceInCurrencyObserver)
                algoBalanceInformationLiveData.observe(viewLifecycleOwner, algoBalanceInformationObserver)
                currencyValueLiveData.observe(viewLifecycleOwner, currencyValueObserver)
                viewLifecycleOwner.lifecycleScope.launch {
                    (activity as MainActivity).mainViewModel
                        .lastBlockNumberSharedFlow.collectLatest(latestBlockNumberCollector)
                }
            } else {
                balanceLiveData?.observe(viewLifecycleOwner, balanceObserver)
            }
        }
    }

    private fun onRewardClick() {
        val reward = assetDetailViewModel.getPendingRewardsAsMicroAlgo()
        nav(AssetDetailFragmentDirections.actionAssetDetailFragmentToRewardsBottomSheet(reward))
    }

    private fun loadData() {
        binding.assetNameTextView.text = assetInformation.getAssetText(
            binding.assetNameTextView.context,
            showTickerWithFullName = false,
            verifiedIconRes = R.drawable.ic_verified_asset_white
        )
        if (assetInformation.isAlgorand()) {
            loadAlgoAssetData()
        } else {
            loadOtherAssetData()
        }
    }

    private fun loadAlgoAssetData() {
        binding.assetCardRootLayout.setBackgroundResource(R.drawable.bg_card_green)
        binding.analyticsButton.setOnClickListener { onAnalyticsClicked() }
        binding.rewardLabelTextView.setOnClickListener { onRewardClick() }
        setTotalBalanceTextViewAttrsBasedOnAsset(isAlgorand = true)
        setViewVisibilityBasedOnAsset(isAlgorand = true)
        initializeAlgoBalances()
    }

    private fun loadOtherAssetData() {
        binding.assetCardRootLayout.setBackgroundResource(R.drawable.bg_card_gray)
        binding.assetIdTextView.apply {
            text = getString(
                R.string.title_and_value_format,
                getString(R.string.title_id),
                assetInformation.assetId.toString()
            )
            enableClickToCopy()
        }
        setTotalBalanceTextViewAttrsBasedOnAsset(isAlgorand = false)
        setViewVisibilityBasedOnAsset(isAlgorand = false)
    }

    private fun onAnalyticsClicked() {
        with(assetInformation) {
            if (isAlgorand() && selectedCurrencyValue != null) {
                listener?.onAssetCardSelected(address, selectedCurrencyValue!!)
            }
        }
    }

    private fun setBalanceTextView(balance: BigInteger) {
        with(binding) {
            if (assetInformation.isAlgorand()) {
                algoBalanceTextView.text = balance.formatAsAlgoString()
            } else {
                totalBalanceTextView.text = balance.formatAmount(assetInformation.decimals)
            }
        }
    }

    private fun setTotalBalanceTextViewAttrsBasedOnAsset(isAlgorand: Boolean) {
        with(binding.totalBalanceTextView) {
            val constraintLayoutParams = layoutParams as ConstraintLayout.LayoutParams
            constraintLayoutParams.bottomToBottom = if (isAlgorand) {
                setCompoundDrawablesWithIntrinsicBounds(0, 0, R.drawable.ic_algo_sign_white, 0)
                -1
            } else {
                setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0)
                binding.assetIdTextView.id
            }
        }
    }

    private fun setViewVisibilityBasedOnAsset(isAlgorand: Boolean) {
        binding.algoRelatedViewsGroup.isVisible = isAlgorand
        binding.otherAssetRelatedViewsGroup.isVisible = !isAlgorand
    }

    private fun setAlgoBalanceInformation(algoBalanceInformation: AlgoBalanceInformation) {
        with(binding) {
            with(algoBalanceInformation) {
                totalBalanceTextView.text = totalBalance.formatAsAlgoString()
                algoBalanceTextView.text = balanceWithoutPendingRewards.formatAsAlgoString()
                rewardTextView.text = pendingRewards.formatAsAlgoRewardString()
            }
        }
    }

    private fun initializeAlgoBalances() {
        with(binding) {
            with(assetInformation) {
                totalBalanceTextView.text = amount.formatAsAlgoString()
                algoBalanceTextView.text = amountWithoutPendingRewards.formatAsAlgoString()
                rewardTextView.text = pendingRewards.formatAsAlgoRewardString()
            }
        }
    }

    interface Listener {
        fun onAssetCardSelected(algoAccountAddress: String, selectedCurrency: CurrencyValue)
    }

    companion object {
        private const val PARAM_ADDRESS = "ADDRESS"
        private const val PARAM_ASSET_INFORMATION = "ASSET_INFORMATION"
        fun newInstance(address: String, assetInformation: AssetInformation): AssetCardFragment {
            return AssetCardFragment().apply {
                arguments = Bundle().apply {
                    putString(PARAM_ADDRESS, address)
                    putParcelable(PARAM_ASSET_INFORMATION, assetInformation)
                }
            }
        }
    }
}
