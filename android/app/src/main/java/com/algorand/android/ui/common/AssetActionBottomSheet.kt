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

package com.algorand.android.ui.common

import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.text.HtmlCompat
import androidx.core.text.buildSpannedString
import androidx.core.view.isInvisible
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetAssetActionBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Resource
import com.algorand.android.utils.addUnnamedAssetName
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.showWithStateCheck
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlin.properties.Delegates

@AndroidEntryPoint
class AssetActionBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_asset_action,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {

    @Inject
    lateinit var accountManager: AccountManager

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    private lateinit var popupType: Type

    private val assetActionViewModel: AssetActionViewModel by viewModels()

    private val binding by viewBinding(BottomSheetAssetActionBinding::bind)

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val assetDescriptionObserver = Observer<Resource<AssetInformation>> { resource ->
        resource.use(
            onSuccess = { assetDescription -> asset = assetDescription },
            onLoading = { binding.loadingProgressBar.visibility = View.VISIBLE },
            onLoadingFinished = { binding.loadingProgressBar.visibility = View.GONE }
        )
    }

    // </editor-fold>

    private var assetId: Long = 0
    private var asset: AssetInformation? by Delegates.observable<AssetInformation?>(null, { _, _, newValue ->
        if (newValue != null) {
            setAssetDetails(newValue)
        } else {
            assetActionViewModel.getAssetDescription(assetId)
        }
    })

    private var accountName: String? = null
    private var accountPublicKey: String? = null
    private var listener: AddAssetConfirmationPopupListener? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        listener =
            parentFragment as? AddAssetConfirmationPopupListener ?: activity as? AddAssetConfirmationPopupListener
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()

        requireArguments().run {
            popupType = getSerializable(POPUP_TYPE) as Type
            accountPublicKey = getString(ACCOUNT_KEY)
            accountPublicKey?.let { safeAccountPublicKey ->
                accountName = accountManager.getAccount(safeAccountPublicKey)?.name
            }
            assetId = getLong(ASSET_ID_KEY)
            asset = getParcelable(ASSET_INFORMATION_KEY)
                ?: accountCacheManager.getAssetDescription(assetId)?.convertToAssetInformation(assetId)
        }

        binding.idTextView.text = assetId.toString()
        setViewAccordingToType()
        setButtonFunctionalities()
        binding.copyButton.setOnClickListener { onCopyClick() }
    }

    private fun initObservers() {
        assetActionViewModel.assetInformationLiveData.observe(viewLifecycleOwner, assetDescriptionObserver)
    }

    private fun onCopyClick() {
        context?.copyToClipboard(assetId.toString(), ASSET_ID_COPY_LABEL)
    }

    private fun setAssetDetails(asset: AssetInformation) {
        binding.nameTextView.text = asset.fullName
        binding.AbbrTextView.text = if (asset.shortName.isNullOrBlank()) {
            buildSpannedString { context?.let { addUnnamedAssetName(it) } }
        } else {
            asset.shortName
        }
        binding.verifiedImageView.isInvisible = asset.isVerified.not()
    }

    private fun setViewAccordingToType() {
        val title: String
        val description: String

        when (popupType) {
            Type.ADD_ASSET -> {
                title = getString(R.string.adding_asset)
                description = getString(R.string.adding_an_asset)
            }
            Type.REMOVE_ASSET -> {
                title = getString(R.string.removing_asset)
                description = getString(R.string.you_are_about_to, asset?.shortName, accountName)
            }
            Type.TRANSFER_BALANCE -> {
                title = getString(R.string.removing_asset)
                description = getString(R.string.to_remove_the_balance, asset?.shortName)
            }
            Type.UNSUPPORTED_INFO -> {
                title = getString(R.string.account_does_not_accept)
                description = getString(R.string.unfortunately_this_account)
            }
            Type.UNSUPPORTED_NOTIFICATION_REQUEST -> {
                title = getString(R.string.you_are_about_to_receive)
                description = getString(R.string.you_are_about_to_receive_description, accountName)
            }
            Type.UNSUPPORTED_ACCOUNT_NOT_ADDED -> {
                title = getString(R.string.this_account_does_not)
                description = getString(R.string.this_account_has_not)
            }
            Type.UNSUPPORTED_ADD_TRY_LATER -> {
                title = getString(R.string.your_accounts_do_not)
                description = getString(R.string.please_add_this)
            }
        }
        binding.titleTextView.text = title
        binding.descriptionTextView.text = HtmlCompat.fromHtml(description, HtmlCompat.FROM_HTML_MODE_LEGACY)
    }

    private fun setButtonFunctionalities() {
        val positiveButtonText: String
        var positiveButtonBackgroundColorId: Int? = null

        when (popupType) {
            Type.ADD_ASSET -> {
                positiveButtonText = getString(R.string.approve)
            }
            Type.REMOVE_ASSET -> {
                positiveButtonText = getString(R.string.proceed)
            }
            Type.TRANSFER_BALANCE -> {
                positiveButtonText = getString(R.string.transfer_balance)
            }
            Type.UNSUPPORTED_INFO -> {
                positiveButtonText = getString(R.string.ok)
                positiveButtonBackgroundColorId = R.color.gray_71
                binding.negativeButton.visibility = View.GONE
            }
            Type.UNSUPPORTED_ADD_TRY_LATER -> {
                positiveButtonText = getString(R.string.ok)
                positiveButtonBackgroundColorId = R.color.gray_71
                binding.negativeButton.visibility = View.GONE
            }
            Type.UNSUPPORTED_NOTIFICATION_REQUEST, Type.UNSUPPORTED_ACCOUNT_NOT_ADDED -> {
                positiveButtonText = getString(R.string.ok)
            }
        }

        binding.positiveButton.apply {
            if (positiveButtonBackgroundColorId != null) {
                setBackgroundColor(ContextCompat.getColor(context, positiveButtonBackgroundColorId))
            }
            text = positiveButtonText
            setOnClickListener {
                dismissAllowingStateLoss()
                asset?.let { assetDescription ->
                    listener?.onPopupConfirmation(popupType, assetDescription, accountPublicKey)
                }
            }
        }
        binding.negativeButton.setOnClickListener {
            dismissAllowingStateLoss()
        }
    }

    interface AddAssetConfirmationPopupListener {
        fun onPopupConfirmation(type: Type, popupAsset: AssetInformation, publicKey: String? = null)
    }

    enum class Type {
        ADD_ASSET,
        REMOVE_ASSET,
        TRANSFER_BALANCE,
        UNSUPPORTED_INFO,
        UNSUPPORTED_NOTIFICATION_REQUEST,
        UNSUPPORTED_ADD_TRY_LATER,
        UNSUPPORTED_ACCOUNT_NOT_ADDED
    }

    companion object {
        private val TAG = AssetActionBottomSheet::class.java.simpleName
        private const val ASSET_ID_COPY_LABEL = "asset_id_label"
        private const val POPUP_TYPE = "popup_type"
        private const val ACCOUNT_KEY = "account_key"
        private const val ASSET_ID_KEY = "asset_id_key"
        private const val ASSET_INFORMATION_KEY = "asset_description_key"

        fun show(
            fragmentManager: FragmentManager?,
            assetId: Long,
            type: Type,
            accountPublicKey: String? = null,
            asset: AssetInformation? = null
        ) {
            AssetActionBottomSheet().apply {
                this.arguments = Bundle().apply {
                    putSerializable(POPUP_TYPE, type)
                    putString(ACCOUNT_KEY, accountPublicKey)
                    putLong(ASSET_ID_KEY, assetId)
                    putParcelable(ASSET_INFORMATION_KEY, asset)
                }
            }.showWithStateCheck(fragmentManager, TAG)
        }
    }
}
