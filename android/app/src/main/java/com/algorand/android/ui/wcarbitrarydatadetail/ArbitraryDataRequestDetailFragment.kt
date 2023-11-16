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

package com.algorand.android.ui.wcarbitrarydatadetail

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentArbitraryDataRequestDetailBinding
import com.algorand.android.models.ArbitraryDataRequestAction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ArbitraryDataRequestDetailFragment : DaggerBaseFragment(
    R.layout.fragment_arbitrary_data_request_detail
) {
    override val fragmentConfiguration = FragmentConfiguration()

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = { arbitraryDataRequestListener?.onNavigateBack() },
        titleResId = R.string.arbitrary_data_details
    )

    private val args: ArbitraryDataRequestDetailFragmentArgs by navArgs()
    private val binding by viewBinding(FragmentArbitraryDataRequestDetailBinding::bind)
    private val arbitraryDataDetailViewModel: ArbitraryDataRequestDetailViewModel by viewModels()

    private var arbitraryDataRequestListener: ArbitraryDataRequestAction? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        arbitraryDataRequestListener = parentFragment?.parentFragment as? ArbitraryDataRequestAction
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        arbitraryDataRequestListener?.hideButtons()
        binding.customToolbar.configure(toolbarConfiguration)
        initArbitraryDataInfoViews()
        initAmountInfoViews()
        initDataView()
    }

    private fun initArbitraryDataInfoViews() {
        with(binding) {
            val arbitraryDataInfo = arbitraryDataDetailViewModel.buildArbitraryDataRequestInfo(args.arbitraryData)
            arbitraryDataInfoCardView.initArbitraryDataInfo(arbitraryDataInfo)
        }
    }

    private fun initAmountInfoViews() {
        val amountInfo = arbitraryDataDetailViewModel.buildArbitraryDataRequestAmountInfo(args.arbitraryData)
        binding.amountInfoCardView.initAmountInfo(amountInfo)
    }

    private fun initDataView() {
        val dataInfo = arbitraryDataDetailViewModel.buildArbitraryDataRequestDataInfo(args.arbitraryData)
        with(binding) {
            dataCardView.initData(dataInfo)
        }
    }
}
