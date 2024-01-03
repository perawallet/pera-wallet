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

package com.algorand.android.modules.baseintroduction.ui

import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.View
import android.view.ViewStub
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentBaseIntroductionBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.baseintroduction.ui.model.FeatureTag
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.coroutines.flow.map

abstract class BaseIntroductionFragment : BaseFragment(R.layout.fragment_base_introduction) {

    protected val contentViewStub: ViewStub
        get() = binding.introductionContentViewStub

    private val binding by viewBinding(FragmentBaseIntroductionBinding::bind)

    abstract val baseIntroductionViewModel: BaseIntroductionViewModel

    private val featureTagCollector: suspend (FeatureTag?) -> Unit = { featureTag ->
        binding.featureTagTextView.apply {
            isVisible = featureTag != null
            if (featureTag == null) return@apply
            setText(featureTag.textResId)
            setTextColor(ContextCompat.getColor(context, featureTag.textColorResId))
            setBackgroundResource(featureTag.backgroundResId)
            backgroundTintList = ContextCompat.getColorStateList(context, featureTag.backgroundTintResId)
        }
    }

    private val actionButtonAnnotatedStringCollector: suspend (AnnotatedString) -> Unit = { annotatedString ->
        binding.actionButton.text = context?.getXmlStyledString(annotatedString)
    }

    private val descriptionAnnotatedStringCollector: suspend (AnnotatedString?) -> Unit = { annotatedString ->
        if (annotatedString != null) {
            binding.introductionDescriptionTextView.apply {
                val linkTextColor = ContextCompat.getColor(context, R.color.positive)
                val clickSpannable = getCustomClickableSpan(
                    clickableColor = linkTextColor,
                    onClick = { onLearnMoreButtonClick() }
                )
                val modifiedAnnotatedString = annotatedString.copy(
                    customAnnotationList = listOf("learn_more" to clickSpannable)
                )
                highlightColor = ContextCompat.getColor(context, R.color.transparent)
                movementMethod = LinkMovementMethod.getInstance()
                text = context.getXmlStyledString(modifiedAnnotatedString)
            }
        }
    }

    private val titleAnnotatedStringCollector: suspend (AnnotatedString) -> Unit = { annotatedString ->
        binding.introductionTitleTextView.text = context?.getXmlStyledString(annotatedString)
    }

    private val bannerDrawableResIdCollector: suspend (Int) -> Unit = { bannerDrawableResId ->
        binding.introductionImageView.setImageResource(bannerDrawableResId)
    }

    abstract fun onCloseButtonClick()
    abstract fun onActionButtonClick()
    abstract fun onLearnMoreButtonClick()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            closeButton.setOnClickListener { onCloseButtonClick() }
            actionButton.setOnClickListener { onActionButtonClick() }
        }
    }

    open fun initObservers() {
        with(baseIntroductionViewModel.introductionPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.bannerDrawableResId },
                collection = bannerDrawableResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.titleAnnotatedString },
                collection = titleAnnotatedStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.descriptionAnnotatedString },
                collection = descriptionAnnotatedStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.actionButtonAnnotatedString },
                collection = actionButtonAnnotatedStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.featureTag },
                collection = featureTagCollector
            )
        }
    }
}
