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

package com.algorand.android.utils

import android.content.Intent
import android.graphics.Bitmap
import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.FragmentShowQrBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.analytics.logTapShowQrCopy
import com.algorand.android.utils.analytics.logTapShowQrShare
import com.algorand.android.utils.analytics.logTapShowQrShareComplete
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.io.File

@AndroidEntryPoint
class ShowQrBottomSheet : DaggerBaseBottomSheet(
    R.layout.fragment_show_qr,
    fullPageNeeded = true,
    firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
) {

    private var qrCodeBitmap: Bitmap? = null
    private var qrCodeFile: File? = null
    private var address: String? = null

    private val binding by viewBinding(FragmentShowQrBinding::bind)

    private val args: ShowQrBottomSheetArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val toolbarConfiguration = ToolbarConfiguration(
            startIconResId = R.drawable.ic_close,
            startIconClick = ::dismissAllowingStateLoss
        )
        binding.toolbar.configure(toolbarConfiguration)

        when (args.state) {
            State.MNEMONIC_QR -> {
                qrCodeBitmap = getQrCodeBitmap(resources, getMnemonicQrContent(args.qrText))
                binding.toolbar.changeTitle(getString(R.string.passphrase_qr))
            }
            State.ADDRESS_QR -> {
                address = args.qrText
                binding.copiedTextView.text = args.qrText
                binding.copyButton.setOnClickListener { onCopyClick() }
                binding.copiedTextView.setOnClickListener { onCopyClick() }
                binding.addressCardView.visibility = View.VISIBLE
                qrCodeBitmap = getQrCodeBitmap(resources, args.qrText)
                binding.toolbar.changeTitle(args.title.orEmpty())
            }
        }
        binding.qrImageView.setImageBitmap(qrCodeBitmap)

        binding.shareButton.setOnClickListener { onShareButtonClick() }
    }

    private fun onCopyClick() {
        address?.let {
            firebaseAnalytics.logTapShowQrCopy(it)
        }
        context?.copyToClipboard(binding.copiedTextView.text, ADDRESS_COPY_LABEL)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == IMAGE_SHARE_REQUEST) {
            qrCodeFile?.delete()
            address?.let {
                firebaseAnalytics.logTapShowQrShareComplete(it)
            }
        }
    }

    private fun onShareButtonClick() {
        address?.let {
            firebaseAnalytics.logTapShowQrShare(it)
        }
        qrCodeBitmap?.let {
            qrCodeFile = openImageShareBottomMenu(it)
        }
    }

    enum class State {
        MNEMONIC_QR,
        ADDRESS_QR
    }

    companion object {
        private const val ADDRESS_COPY_LABEL = "address"
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_show_qr"
    }
}
