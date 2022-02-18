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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import android.widget.FrameLayout
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomAssetAvatarViewBinding
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.extensions.formatAsAvatarTextOrThrow
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.setImageResAndVisibility
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.properties.Delegates

class AlgorandAssetAvatarView @JvmOverloads constructor(
    context: Context,
    private val attrs: AttributeSet? = null,
) : FrameLayout(context, attrs) {

    private val binding = viewBinding(CustomAssetAvatarViewBinding::inflate)

    var assetName: String? by Delegates.observable(null) { _, _, newValue ->
        if (newValue != null) {
            setOtherAssetAvatar(newValue)
        }
    }

    init {
        loadAttrs()
    }

    private fun loadAttrs() {
        context.obtainStyledAttributes(attrs, R.styleable.AlgorandAssetAvatarView).use { attr ->
            assetName = attr.getString(R.styleable.AlgorandAssetAvatarView_assetName).orEmpty()
        }
    }

    fun setAlgorandAvatar() {
        binding.assetAvatarImageView.setImageResAndVisibility(R.drawable.ic_algo_green_round)
        hideProgressBar()
    }

    fun setOtherAssetAvatar(assetName: String?) {
        val avatarText = getSafeAssetAvatarName(assetName)
        with(binding) {
            assetAvatarImageView.setImageDrawable(null)
            assetNameTextView.setTextAndVisibility(avatarText)
        }
        hideProgressBar()
    }

    fun setAssetAvatar(isAlgorand: Boolean, assetFullName: String) {
        if (isAlgorand) {
            setAlgorandAvatar()
        } else {
            setOtherAssetAvatar(assetFullName)
        }
    }

    fun showProgressBar() {
        with(binding) {
            assetAvatarProgressBar.show()
            assetNameTextView.text = ""
        }
    }

    fun hideProgressBar() {
        binding.assetAvatarProgressBar.hide()
    }

    // TODO Move this logic into domain level
    private fun getSafeAssetAvatarName(assetName: String?): String {
        val unnamedAssetName = resources.getString(AssetName.DEFAULT_ASSET_NAME_RES_ID)
        return try {
            val safeName = assetName ?: unnamedAssetName
            safeName.formatAsAvatarTextOrThrow(ASSET_AVATAR_MAX_LETTER_COUNT)
        } catch (exception: Exception) {
            sendErrorLog("$logTag - Crash reason asset name = $assetName")
            unnamedAssetName.formatAsAvatarTextOrThrow(ASSET_AVATAR_MAX_LETTER_COUNT)
        }
    }

    companion object {
        private val logTag = AlgorandAssetAvatarView::class.java.simpleName
        private const val ASSET_AVATAR_MAX_LETTER_COUNT = 3
    }
}
