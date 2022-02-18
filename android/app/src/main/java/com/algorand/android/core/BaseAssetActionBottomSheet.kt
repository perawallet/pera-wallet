/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.core

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.core.text.buildSpannedString
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.R
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.databinding.BottomSheetAssetActionBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.ui.common.AssetActionViewModel
import com.algorand.android.utils.Resource
import com.algorand.android.utils.addUnnamedAssetName
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton
import kotlin.properties.Delegates

abstract class BaseAssetActionBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_asset_action) {

    abstract val accountName: String
    abstract val assetId: Long

    private val binding by viewBinding(BottomSheetAssetActionBinding::bind)
    protected val assetActionViewModel: AssetActionViewModel by viewModels()

    protected var asset: AssetInformation? by Delegates.observable(null) { _, _, newValue ->
        if (newValue != null) {
            setAssetDetails(newValue)
        } else {
            assetActionViewModel.fetchAssetDescription(assetId)
        }
    }

    // region Observers

    private val assetDescriptionObserver = Observer<Resource<AssetInformation>> { resource ->
        resource.use(
            onSuccess = { assetDescription -> asset = assetDescription },
            onLoading = { binding.loadingProgressBar.visibility = View.VISIBLE },
            onLoadingFinished = { binding.loadingProgressBar.visibility = View.GONE }
        )
    }

    //endregion

    abstract fun setDescriptionTextView(textView: TextView)
    abstract fun setToolbar(customToolbar: CustomToolbar)
    abstract fun setPositiveButton(materialButton: MaterialButton)
    abstract fun setNegativeButton(materialButton: MaterialButton)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initArgs()
        initObservers()
        with(binding) {
            setDescriptionTextView(descriptionTextView)
            setToolbar(customToolbar)
            setPositiveButton(positiveButton)
            setNegativeButton(negativeButton)
        }
    }

    open fun initArgs() {}

    open fun initObservers() {
        assetActionViewModel.assetInformationLiveData.observe(viewLifecycleOwner, assetDescriptionObserver)
    }

    private fun setAssetDetails(asset: AssetInformation) {
        with(binding) {
            with(asset) {
                assetFullNameTextView.text = fullName
                assetShortNameTextView.text = if (shortName.isNullOrBlank()) {
                    buildSpannedString { context?.let { addUnnamedAssetName(it) } }
                } else {
                    shortName
                }
                verifiedImageView.isVisible = isVerified
                assetIdTextView.text = assetId.toString()
                copyIDButton.setOnClickListener { onCopyClick() }
            }
        }
    }

    private fun onCopyClick() {
        context?.copyToClipboard(assetId.toString(), ASSET_ID_COPY_LABEL)
    }

    companion object {
        private const val ASSET_ID_COPY_LABEL = "asset_id_label"
    }
}
