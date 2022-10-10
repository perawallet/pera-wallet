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

package com.algorand.android.ui.send.transferamount

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetBalanceWarningBinding
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.AlgoDrawableProvider
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class BalanceWarningBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_balance_warning) {

    private val binding by viewBinding(BottomSheetBalanceWarningBinding::bind)
    private val balanceWarningViewModel: BalanceWarningViewModel by viewModels()

    private val balanceWarningPreviewCollector: suspend (BalanceWarningPreview) -> Unit = {
        updateUiWithPreview(it)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        binding.assetItemView.setPrimaryValueTextColor(R.color.negative)
        binding.confirmationButton.setOnClickListener { navBack() }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            flow = balanceWarningViewModel.balanceWarningPreviewFlow,
            collection = balanceWarningPreviewCollector
        )
    }

    private fun updateUiWithPreview(preview: BalanceWarningPreview) {
        with(preview) {
            binding.descriptionTextView.text = getString(
                R.string.this_account_doesn_t_have_the,
                formattedMinBalanceToKeepPerOptedInAsset
            )
            binding.assetItemView.apply {
                formattedAlgoAmount?.let { setPrimaryValueText(it) }
                formattedAlgoPrimaryCurrencyValue?.let { setSecondaryValueText(it) }
            }
            with(binding.assetItemView) {
                setTitleText(preview.algoFullName)
                setDescriptionText(preview.algoShortName)
                AlgoDrawableProvider().provideAssetDrawable(
                    context = context,
                    assetName = AssetName.create(preview.algoShortName),
                    logoUri = null,
                    width = resources.getDimensionPixelSize(R.dimen.asset_avatar_image_size),
                    onResourceReady = ::setStartIconDrawable
                )
            }
        }
    }
}
