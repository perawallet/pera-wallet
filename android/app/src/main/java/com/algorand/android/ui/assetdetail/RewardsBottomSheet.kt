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

package com.algorand.android.ui.assetdetail

import android.os.Bundle
import android.text.style.ForegroundColorSpan
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetRewardsBinding
import com.algorand.android.models.PendingReward
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class RewardsBottomSheet : DaggerBaseBottomSheet(R.layout.bottom_sheet_rewards, false, null) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.rewards,
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close
    )

    private val binding by viewBinding(BottomSheetRewardsBinding::bind)

    private val rewardsViewModel: RewardsViewModel by viewModels()

    private val pendingRewardCollector: suspend (PendingReward) -> Unit = {
        // TODO: 10.02.2022 Implementing the loading state could be good cause calculating
        //  reward is taking a bit of time at the first time
        binding.rewardsAmountTextView.text = it.formattedPendingRewardAmount
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        binding.toolbar.configure(toolbarConfiguration)
        setupForMoreInformationText()
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            rewardsViewModel.pendingRewardFlow.collectLatest(pendingRewardCollector)
        }
    }

    private fun setupForMoreInformationText() {
        binding.moreInfoTextView.apply {
            val faqColor = ContextCompat.getColor(context, R.color.linkPrimary)
            text = context.getXmlStyledString(
                stringResId = R.string.for_more_information,
                customAnnotations = listOf("faq_color" to ForegroundColorSpan(faqColor))
            )
            setOnClickListener { context.openUrl(REWARDS_URL) }
        }
    }

    companion object {
        private const val REWARDS_URL = "https://algorand.foundation/faq#participation-rewards-"
    }
}
