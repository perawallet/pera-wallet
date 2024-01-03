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

package com.algorand.android.modules.walletconnect.launchback.base.ui

import android.os.Bundle
import android.view.Gravity
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.view.isInvisible
import androidx.core.view.isVisible
import androidx.core.widget.addTextChangedListener
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetWalletConnectLaunchBackBrowserSelectionBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.walletconnect.launchback.base.ui.model.LaunchBackBrowserListItem
import com.algorand.android.modules.walletconnect.launchback.multiplebrowser.base.ui.adapter.LaunchBackBrowserSelectionAdapter
import com.algorand.android.utils.ExcludedViewTypesDividerItemDecoration
import com.algorand.android.utils.addCustomDivider
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.hasMultipleParagraph
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.startActivityWithPackageName
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
abstract class WcLaunchBackBrowserBottomSheet : BaseBottomSheet(
    R.layout.bottom_sheet_wallet_connect_launch_back_browser_selection
) {

    abstract val wcLaunchBackBrowserViewModel: WcLaunchBackBrowserViewModel

    protected val binding by viewBinding(BottomSheetWalletConnectLaunchBackBrowserSelectionBinding::bind)

    private val launchBackBrowserSelectionAdapterListener = LaunchBackBrowserSelectionAdapter.Listener { packageName ->
        openActivityWithPackageName(packageName)
    }

    private val launchBackBrowserSelectionAdapter = LaunchBackBrowserSelectionAdapter(
        listener = launchBackBrowserSelectionAdapterListener
    )

    private val launchBackBrowserListCollector: suspend (List<LaunchBackBrowserListItem>?) -> Unit = { itemList ->
        launchBackBrowserSelectionAdapter.submitList(itemList)
    }

    private val secondaryActionButtonTextResIdCollector: suspend (Int?) -> Unit = { textResId ->
        binding.secondaryButton.apply {
            if (textResId == null) {
                hide()
            } else {
                setText(textResId)
                show()
            }
        }
    }

    private val primaryActionButtonAnnotatedStringCollector: suspend (AnnotatedString?) -> Unit = { annotatedString ->
        binding.primaryButton.apply {
            if (annotatedString == null) {
                hide()
            } else {
                text = context.getXmlStyledString(annotatedString)
                show()
            }
        }
    }

    private val descriptionAnnotatedStringCollector: suspend (AnnotatedString?) -> Unit = { annotatedString ->
        binding.descriptionTextView.apply {
            if (annotatedString != null) {
                show()
                text = context.getXmlStyledString(annotatedString)
            } else {
                hide()
            }
        }
    }

    private val titleAnnotatedStringCollector: suspend (AnnotatedString?) -> Unit = { annotatedString ->
        binding.titleTextView.apply {
            if (annotatedString != null) {
                show()
                text = context.getXmlStyledString(annotatedString)
            } else {
                hide()
            }
        }
    }

    private val iconTintResIdCollector: suspend (Int?) -> Unit = { tintResId ->
        binding.iconImageView.apply {
            if (tintResId != null) {
                show()
                imageTintList = ContextCompat.getColorStateList(binding.root.context, tintResId)
            } else {
                hide()
            }
        }
    }

    private val iconResIdCollector: suspend (Int?) -> Unit = { iconResId ->
        binding.iconImageView.apply {
            if (iconResId != null) {
                show()
                setImageResource(iconResId)
            } else {
                hide()
            }
        }
    }

    private val launchBackBrowserListVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.browserRecyclerView.isVisible = isVisible == true
    }

    private val modalityLineVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.toolbar.isInvisible = isVisible != false
        setDraggableEnabled(isVisible != false)
    }

    private val toolbarVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.modalityLineView.isInvisible = isVisible == true
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            toolbar.configureStartButton(
                resId = R.drawable.ic_close,
                clickAction = ::navBack
            )
            browserRecyclerView.apply {
                adapter = launchBackBrowserSelectionAdapter
                addCustomDivider(
                    drawableResId = R.drawable.horizontal_divider_80_24dp,
                    showLast = false,
                    divider = ExcludedViewTypesDividerItemDecoration(emptyList())
                )
            }
            descriptionTextView.apply {
                addTextChangedListener { gravity = if (it.hasMultipleParagraph()) Gravity.START else Gravity.CENTER }
            }
            primaryButton.setOnClickListener {
                openActivityWithPackageName(wcLaunchBackBrowserViewModel.firstLaunchBackOptionPackageName)
            }
            secondaryButton.setOnClickListener {
                navBack()
            }
        }
    }

    protected open fun initObservers() {
        with(wcLaunchBackBrowserViewModel.wcLaunchBackBrowserFieldsFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.iconResId },
                collection = iconResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.iconTintResId },
                collection = iconTintResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.titleAnnotatedString },
                collection = titleAnnotatedStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.descriptionAnnotatedString },
                collection = descriptionAnnotatedStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.primaryActionButtonAnnotatedString },
                collection = primaryActionButtonAnnotatedStringCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.secondaryActionButtonTextResId },
                collection = secondaryActionButtonTextResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.launchBackBrowserList },
                collection = launchBackBrowserListCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isLaunchBackBrowserListVisible },
                collection = launchBackBrowserListVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isToolbarVisible },
                collection = toolbarVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isModalityLineVisible },
                collection = modalityLineVisibilityCollector
            )
        }
    }

    private fun openActivityWithPackageName(packageName: String) {
        context?.startActivityWithPackageName(
            packageName = packageName,
            onActivityStartFailed = {
                // TODO: show error message here in case of failure
            }
        )
        navBack()
    }
}
