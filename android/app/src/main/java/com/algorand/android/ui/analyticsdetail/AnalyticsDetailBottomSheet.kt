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

package com.algorand.android.ui.analyticsdetail

import android.os.Bundle
import android.view.View
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.customviews.algorandchart.ChartTimeFrameView.Companion.DEFAULT_TIME_FRAME
import com.algorand.android.customviews.algorandchart.CompactChartView
import com.algorand.android.databinding.BottomSheetAnalyticsDetailBinding
import com.algorand.android.models.CandleHistory
import com.algorand.android.models.ChartEntryData
import com.algorand.android.models.ChartTimeFrame
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.PERCENT_FORMAT
import com.algorand.android.utils.Resource
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsDollar
import com.algorand.android.utils.getFormatter
import com.algorand.android.utils.isBiggerThan
import com.algorand.android.utils.isLessThan
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.highlight.Highlight
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigDecimal.ZERO
import java.math.BigInteger
import kotlin.properties.Delegates

@AndroidEntryPoint
class AnalyticsDetailBottomSheet : DaggerBaseBottomSheet(
    R.layout.bottom_sheet_analytics_detail,
    fullPageNeeded = true,
    firebaseEventScreenId = null
) {

    private val analyticsDetailViewModel: AnalyticsDetailViewModel by viewModels()
    private val binding by viewBinding(BottomSheetAnalyticsDetailBinding::bind)
    private val args: AnalyticsDetailBottomSheetArgs by navArgs()

    private var chartEntryData: ChartEntryData? by Delegates.observable(null) { _, _, newValue ->
        if (newValue != null) updateChartUi(newValue)
    }

    private var selectedTimeFrame: ChartTimeFrame? by Delegates.observable(null) { _, _, newValue ->
        if (newValue != null) {
            val selectedCurrencyValueOfPerAlgo = args.selectedCurrency.getAlgorandCurrencyValue() ?: ZERO
            analyticsDetailViewModel.getAlgoPriceHistory(selectedCurrencyValueOfPerAlgo, newValue.interval)
        }
    }

    private val compactChartViewListener = object : CompactChartView.Listener {
        override fun onTimeFrameSelected(selectedTimeFrame: ChartTimeFrame) {
            this@AnalyticsDetailBottomSheet.selectedTimeFrame = selectedTimeFrame
        }

        override fun onLineChartTouch(hasFocus: Boolean) {
            setDraggableEnabled(!hasFocus)
            binding.rootScrollView.isScrollEnable = !hasFocus
            if (!hasFocus) setLatestPriceAndPriceChangePercentage(chartEntryData)
        }

        override fun onChartValueSelected(entry: Entry?, highlight: Highlight?) {
            (entry?.data as? CandleHistory)?.let { candleHistory ->
                setSelectedValueBalanceAndTimestamp(candleHistory)
            }
        }
    }

    private val algoPriceHistoryObserver = Observer<Resource<ChartEntryData>> {
        it.use(
            onSuccess = ::onGetAlgoPriceHistorySuccess,
            onFailed = { onGetAlgoPriceHistoryFailed() },
            onLoading = { binding.compactChartView.showProgress() },
            onLoadingFinished = { binding.compactChartView.hideProgress() }
        )
    }

    private val balanceObserver = Observer<BigInteger?> { balance ->
        binding.balanceTextView.text = balance.formatAmount(ALGO_DECIMALS)
    }

    private val balanceInSelectedCurrency = Observer<String> { balanceInSelectedCurrency ->
        binding.valueTextView.text = getCurrencyFormattedPrice(balanceInSelectedCurrency)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        analyticsDetailViewModel.setupBalanceAndDollarValue(args.selectedCurrency, args.algoAccountAddress)
        selectedTimeFrame = DEFAULT_TIME_FRAME
        initObserver()
    }

    private fun initUi() {
        with(binding) {
            compactChartView.apply {
                setListener(compactChartViewListener)
                setSelectedCurrencyId(args.selectedCurrency.id)
            }
        }
    }

    private fun initObserver() {
        with(analyticsDetailViewModel) {
            algoPriceHistoryLiveData.observe(viewLifecycleOwner, algoPriceHistoryObserver)
            balanceLiveData?.observe(viewLifecycleOwner, balanceObserver)
            balanceInSelectedCurrencyValueLiveData?.observe(viewLifecycleOwner, balanceInSelectedCurrency)
        }
    }

    private fun onGetAlgoPriceHistorySuccess(chartEntryData: ChartEntryData) {
        this.chartEntryData = chartEntryData
    }

    private fun onGetAlgoPriceHistoryFailed() {
        binding.compactChartView.showError()
        setPriceText(ZERO.formatAsDollar())
        clearPriceChangePercentageText()
        binding.descriptionTextView.text = ""
    }

    private fun updateChartUi(chartEntryData: ChartEntryData) {
        with(chartEntryData) {
            with(binding) {
                compactChartView.setChartData(entryList, lineChartTheme)
                setLatestPriceAndPriceChangePercentage(chartEntryData)
            }
        }
    }

    private fun setLatestPriceAndPriceChangePercentage(chartEntryData: ChartEntryData?) {
        if (chartEntryData == null || binding.compactChartView.getChartData() == null) return
        setPriceText(chartEntryData.latestFormattedPrice)
        setPriceChangePercentageText(chartEntryData)
        setSelectedTimeFrameDescriptionText()
    }

    private fun setPriceChangePercentageText(chartEntryData: ChartEntryData) {
        val priceChangePercentage = chartEntryData.priceChangePercentage
        if (priceChangePercentage isBiggerThan ZERO || priceChangePercentage isLessThan ZERO) {
            setNonNeutralPriceChangePercentageText(chartEntryData)
        } else {
            clearPriceChangePercentageText()
        }
    }

    private fun clearPriceChangePercentageText() {
        binding.percentageChangeTextView.apply {
            text = ""
            setDrawable(start = null)
        }
    }

    private fun setNonNeutralPriceChangePercentageText(chartEntryData: ChartEntryData) {
        with(chartEntryData) {
            val formattedPercentageText = getFormatter(PERCENT_FORMAT).format(priceChangePercentage)
            binding.percentageChangeTextView.apply {
                text = formattedPercentageText
                setTextColor(ContextCompat.getColor(context, percentageChangeTextColorResId))
                setDrawable(start = AppCompatResources.getDrawable(context, percentageChangeArrowResId))
            }
        }
    }

    private fun setSelectedTimeFrameDescriptionText() {
        val description = selectedTimeFrame?.percentageChangeDescriptionResId?.let { descriptionResId ->
            getString(descriptionResId)
        }.orEmpty()
        binding.descriptionTextView.text = description
    }

    private fun setSelectedValueBalanceAndTimestamp(candleHistory: CandleHistory) {
        with(candleHistory) {
            setPriceText(formattedDisplayPrice)
            clearPriceChangePercentageText()
            binding.descriptionTextView.text = formattedTimestamp
        }
    }

    private fun setPriceText(price: String) {
        binding.assetPriceTextView.text = getCurrencyFormattedPrice(price)
    }

    private fun getCurrencyFormattedPrice(price: String): String {
        return "$price ${args.selectedCurrency.id}"
    }
}
