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

package com.algorand.android.ui.analyticsdetail

import android.os.Bundle
import android.view.View
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.BaseBottomBarFragment
import com.algorand.android.customviews.algorandchart.CompactChartView
import com.algorand.android.databinding.FragmentAlgoPriceBinding
import com.algorand.android.models.CandleHistory
import com.algorand.android.models.ChartEntryData
import com.algorand.android.models.ChartTimeFrame
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.PERCENT_FORMAT
import com.algorand.android.utils.Resource
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.formatAsDollar
import com.algorand.android.utils.getFormatter
import com.algorand.android.utils.isGreaterThan
import com.algorand.android.utils.isLesserThan
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.highlight.Highlight
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigDecimal.ZERO
import kotlin.properties.Delegates
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

// TODO Refactor AlgoPriceFragment line by line and rename is as AnalyticsDetailFragment
@AndroidEntryPoint
class AlgoPriceFragment : BaseBottomBarFragment(R.layout.fragment_algo_price) {

    private val toolbarConfiguration = ToolbarConfiguration()

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = true
    )

    private val analyticsDetailViewModel: AnalyticsDetailViewModel by viewModels()
    private val binding by viewBinding(FragmentAlgoPriceBinding::bind)

    private var chartEntryData: ChartEntryData? by Delegates.observable(null) { _, _, newValue ->
        if (newValue != null) updateChartUi(newValue)
    }

    private val compactChartViewListener = object : CompactChartView.Listener {
        override fun onTimeFrameSelected(selectedTimeFrame: ChartTimeFrame) {
            analyticsDetailViewModel.updateSelectedTimeFrame(selectedTimeFrame)
        }

        override fun onLineChartTouch(hasFocus: Boolean) {
            binding.rootScrollView.isScrollEnable = !hasFocus
            if (!hasFocus) setLatestPriceAndPriceChangePercentage(chartEntryData)
        }

        override fun onChartValueSelected(entry: Entry?, highlight: Highlight?) {
            (entry?.data as? CandleHistory)?.let { candleHistory ->
                setSelectedValueBalanceAndTimestamp(candleHistory)
            }
        }
    }

    private val algoPriceHistoryCollector: suspend (Resource<ChartEntryData>) -> Unit = {
        it.use(
            onSuccess = ::onGetAlgoPriceHistorySuccess,
            onFailed = { onGetAlgoPriceHistoryFailed() },
            onLoading = { binding.assetPriceChartView.showProgress() },
            onLoadingFinished = { binding.assetPriceChartView.hideProgress() }
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObserver()
    }

    private fun initUi() {
        with(binding) {
            assetPriceChartView.setListener(compactChartViewListener)
        }
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
        analyticsDetailViewModel.refreshCachedAlgoPrice()
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.algoPriceFragment) {
            useSavedStateValue<ChartTimeFrame>(SELECTED_TIME_FRAME_KEY) {
                analyticsDetailViewModel.updateSelectedTimeFrame(it)
            }
        }
    }

    private fun initObserver() {
        viewLifecycleOwner.lifecycleScope.launch {
            analyticsDetailViewModel.algoPriceHistoryFlow.collectLatest(algoPriceHistoryCollector)
        }
    }

    private fun onGetAlgoPriceHistorySuccess(chartEntryData: ChartEntryData) {
        this.chartEntryData = chartEntryData
    }

    private fun onGetAlgoPriceHistoryFailed() {
        binding.assetPriceChartView.showError()
        setPriceText(ZERO.formatAsDollar())
        clearPriceChangePercentageText()
    }

    private fun updateChartUi(chartEntryData: ChartEntryData) {
        with(chartEntryData) {
            with(binding) {
                assetPriceChartView.setChartData(entryList, lineChartTheme)
                setLatestPriceAndPriceChangePercentage(chartEntryData)
            }
        }
    }

    private fun setLatestPriceAndPriceChangePercentage(chartEntryData: ChartEntryData?) {
        if (chartEntryData == null || binding.assetPriceChartView.getChartData() == null) return
        setPriceText(chartEntryData.latestFormattedPrice)
        setPriceChangePercentageText(chartEntryData)
        clearSelectedTimeFrameText()
    }

    private fun setPriceChangePercentageText(chartEntryData: ChartEntryData) {
        val priceChangePercentage = chartEntryData.priceChangePercentage
        if (priceChangePercentage isGreaterThan ZERO || priceChangePercentage isLesserThan ZERO) {
            setNonNeutralPriceChangePercentageText(chartEntryData)
        } else {
            clearPriceChangePercentageText()
        }
    }

    private fun clearPriceChangePercentageText() {
        binding.changeTextView.apply {
            hide()
        }
    }

    private fun clearSelectedTimeFrameText() {
        binding.selectedTimeFrameTextView.text = ""
    }

    private fun setNonNeutralPriceChangePercentageText(chartEntryData: ChartEntryData) {
        with(chartEntryData) {
            val formattedPercentageText = getFormatter(PERCENT_FORMAT).format(priceChangePercentage)
            binding.changeTextView.apply {
                setTextAndVisibility(formattedPercentageText)
                setTextColor(ContextCompat.getColor(context, percentageChangeTextColorResId))
                setDrawable(start = AppCompatResources.getDrawable(context, percentageChangeArrowResId))
            }
        }
    }

    private fun setSelectedValueBalanceAndTimestamp(candleHistory: CandleHistory) {
        with(candleHistory) {
            setPriceText(formattedDisplayPrice)
            clearPriceChangePercentageText()
            binding.selectedTimeFrameTextView.text = formattedTimestamp
        }
    }

    private fun setPriceText(price: String) {
        binding.assetPriceTextView.text = analyticsDetailViewModel.getCurrencyFormattedPrice(price)
    }

    companion object {
        const val SELECTED_TIME_FRAME_KEY = "selected_time_frame_key"
    }
}
