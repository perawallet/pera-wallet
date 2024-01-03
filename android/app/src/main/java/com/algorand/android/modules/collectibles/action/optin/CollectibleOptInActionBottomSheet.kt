package com.algorand.android.modules.collectibles.action.optin

import android.widget.TextView
import androidx.fragment.app.viewModels
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.customviews.toolbar.CustomToolbar
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.action.base.BaseAssetActionBottomSheet
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.setFragmentNavigationResult
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class CollectibleOptInActionBottomSheet : BaseAssetActionBottomSheet() {

    private val toolbarConfiguration = ToolbarConfiguration(titleResId = R.string.opt_in_to_nft)

    override val assetActionViewModel: CollectibleOptInActionViewModel by viewModels()

    override fun initUi() {
        with(binding) {
            transactionFeeGroup.show()
            accountGroup.show()
        }
    }

    override fun setDescriptionTextView(textView: TextView) {
        textView.setText(R.string.opting_in_to_an_nft)
    }

    override fun setToolbar(customToolbar: CustomToolbar) {
        customToolbar.configure(toolbarConfiguration)
    }

    override fun setPositiveButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.approve)
            setOnClickListener {
                asset?.let { assetDescription ->
                    val assetActionResult = AssetActionResult(
                        asset = assetDescription,
                        publicKey = assetActionViewModel.accountAddress
                    )
                    (activity as? MainActivity)?.signAddAssetTransaction(assetActionResult)
                    setFragmentNavigationResult(OPT_IN_COLLECTIBLE_ACTION_RESULT_KEY, true)
                }
                navBack()
            }
        }
    }

    override fun setNegativeButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.close)
            setOnClickListener { navBack() }
        }
    }

    override fun setTransactionFeeTextView(textView: TextView) {
        textView.text = assetActionViewModel.getTransactionFee()
    }

    override fun setAccountNameTextView(textView: TextView) {
        textView.apply {
            with(assetActionViewModel.getAccountName()) {
                text = getDisplayAddress()
                setDrawable(
                    start = AccountIconDrawable.create(
                        context = context,
                        accountIconDrawablePreview = accountIconDrawablePreview,
                        sizeResId = R.dimen.spacing_xlarge
                    )
                )
                setOnLongClickListener { onAccountAddressCopied(publicKey); true }
            }
        }
    }

    companion object {
        const val OPT_IN_COLLECTIBLE_ACTION_RESULT_KEY = "opt_in_collectible_action_result_key"
    }
}
