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

package com.algorand.android.modules.rekey.rekeytostandardaccount.instruction.ui

import android.content.Context
import android.view.View
import android.view.ViewGroup.MarginLayoutParams
import androidx.core.view.updateLayoutParams
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.customviews.NumberedListItemView
import com.algorand.android.databinding.LayoutRekeyIntroductionContentBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.modules.baseintroduction.ui.BaseIntroductionFragment
import com.algorand.android.modules.baseintroduction.ui.BaseIntroductionViewModel
import com.algorand.android.utils.browser.LEDGER_SUPPORT_URL
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class RekeyToStandardAccountIntroductionFragment : BaseIntroductionFragment() {

    override val fragmentConfiguration = FragmentConfiguration()

    override val baseIntroductionViewModel: BaseIntroductionViewModel
        get() = rekeyToStandardAccountIntroductionViewModel

    private val rekeyToStandardAccountIntroductionViewModel by viewModels<RekeyToStandardAccountIntroductionViewModel>()

    private val viewStubBinding by viewBinding {
        LayoutRekeyIntroductionContentBinding.bind(inflateContentViewStub())
    }

    private val expectationListItemsCollector: suspend (List<AnnotatedString>) -> Unit = { expectationList ->
        inflateExpectationContent(expectationList)
    }

    override fun onCloseButtonClick() {
        navBack()
    }

    override fun onActionButtonClick() {
        val accountAddress = rekeyToStandardAccountIntroductionViewModel.accountAddress
        nav(
            RekeyToStandardAccountIntroductionFragmentDirections
                .actionRekeyToStandardAccountInstructionFragmentToRekeyToStandardAccountSelectionFragment(
                    accountAddress = accountAddress
                )
        )
    }

    override fun onLearnMoreButtonClick() {
        context?.openUrl(LEDGER_SUPPORT_URL)
    }

    override fun initObservers() {
        super.initObservers()
        with(rekeyToStandardAccountIntroductionViewModel.introductionPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.expectationListItems },
                collection = expectationListItemsCollector
            )
        }
    }

    private fun inflateExpectationContent(expectationList: List<AnnotatedString>) {
        with(viewStubBinding.expectationItemsLinearLayout) {
            val itemsMargin = resources.getDimensionPixelSize(R.dimen.spacing_normal)
            removeAllViews()
            expectationList.forEachIndexed { index, annotatedString ->
                val numberedListItemView = createNumberedListItemView(
                    context = context,
                    index = index.inc().toString(),
                    annotatedString = annotatedString
                )
                addView(numberedListItemView)
                numberedListItemView.updateLayoutParams<MarginLayoutParams> { setMargins(0, itemsMargin, 0, 0) }
            }
        }
    }

    private fun createNumberedListItemView(
        context: Context,
        index: String,
        annotatedString: AnnotatedString
    ): NumberedListItemView {
        return NumberedListItemView(context).apply {
            setIconLabelTextView(index)
            setTitleText(context.getXmlStyledString(annotatedString))
        }
    }

    private fun inflateContentViewStub(): View {
        return with(contentViewStub) {
            layoutResource = R.layout.layout_rekey_introduction_content
            inflate()
        }
    }
}
