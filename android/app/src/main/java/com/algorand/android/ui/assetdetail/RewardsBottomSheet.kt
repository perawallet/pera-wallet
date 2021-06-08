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

import android.os.Bundle
import android.text.style.ForegroundColorSpan
import android.view.View
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetRewardsBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.viewbinding.viewBinding

class RewardsBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_rewards) {

    private val toolbarConfiguration = ToolbarConfiguration(titleResId = R.string.rewards)

    private val binding by viewBinding(BottomSheetRewardsBinding::bind)

    private val args: RewardsBottomSheetArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.valueTextView.setAmount(args.pendingRewards.toBigInteger(), ALGO_DECIMALS, true)
        setupForMoreInformationText()
        binding.toolbar.configure(toolbarConfiguration)
        binding.confirmationButton.setOnClickListener { dismissAllowingStateLoss() }
    }

    private fun setupForMoreInformationText() {
        binding.moreInfoTextView.apply {
            val faqColor = ContextCompat.getColor(context, R.color.green_0D)
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
