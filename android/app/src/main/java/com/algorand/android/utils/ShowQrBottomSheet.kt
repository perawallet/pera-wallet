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

package com.algorand.android.utils

import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetShowQrBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.analytics.logTapShowQrCopy
import com.algorand.android.utils.analytics.logTapShowQrShare
import com.algorand.android.utils.analytics.logTapShowQrShareComplete
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.io.File

@AndroidEntryPoint
class ShowQrBottomSheet : DaggerBaseBottomSheet(
    R.layout.bottom_sheet_show_qr,
    fullPageNeeded = true,
    firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    private var qrCodeFile: File? = null

    private val qrCodeBitmap by lazy {
        getQrCodeBitmap(resources.getDimensionPixelSize(R.dimen.show_qr_size), args.qrText)
    }

    private val binding by viewBinding(BottomSheetShowQrBinding::bind)

    private val args: ShowQrBottomSheetArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        with(binding) {
            toolbar.configure(toolbarConfiguration)
            toolbar.changeTitle(args.title)
            accountAddressLabelTextView.text = args.qrText.toShortenedAddress()
            accountAddressTextView.text = args.qrText
            accountAddressTextView.enableClickToCopy()
            qrImageView.setImageBitmap(qrCodeBitmap)
            copyButton.setOnClickListener { onCopyClick() }
            shareButton.setOnClickListener { onShareButtonClick() }
        }
    }

    private fun onCopyClick() {
        firebaseAnalytics.logTapShowQrCopy(args.qrText)
        context?.copyToClipboard(args.qrText, ADDRESS_COPY_LABEL)
    }

    private val sharingActivityResultLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
            qrCodeFile?.delete()
            firebaseAnalytics.logTapShowQrShareComplete(args.qrText)
        }

    private fun onShareButtonClick() {
        firebaseAnalytics.logTapShowQrShare(args.qrText)
        qrCodeBitmap?.let { bitmap ->
            qrCodeFile = openImageShareBottomMenu(bitmap, sharingActivityResultLauncher)
        }
    }

    companion object {
        private const val ADDRESS_COPY_LABEL = "address"
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_show_qr"
    }
}
