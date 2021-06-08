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

package com.algorand.android.customviews

import android.os.Bundle
import android.view.View
import androidx.fragment.app.FragmentManager
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.DialogQrTypeWarningBinding
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.utils.showWithStateCheck
import com.algorand.android.utils.viewbinding.viewBinding

// non-used-for-now
class QrScanTypeWarningDialog : BaseBottomSheet(R.layout.dialog_qr_type_warning) {

    private var listener: Listener? = null

    private val binding by viewBinding(DialogQrTypeWarningBinding::bind)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        listener = parentFragment as? Listener
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.approveButton.setOnClickListener { onApproveClick() }
        binding.cancelButton.setOnClickListener { dismissAllowingStateLoss() }
    }

    private fun onApproveClick() {
        arguments?.getParcelable<DecodedQrCode>(ARG_DECODED_QR_CODE)?.let { decodedQrCode ->
            listener?.onRequestQrAccepted(decodedQrCode)
        }
        dismissAllowingStateLoss()
    }

    interface Listener {
        fun onRequestQrAccepted(decodedQrCode: DecodedQrCode)
    }

    companion object {
        private val TAG = QrScanTypeWarningDialog::class.java.simpleName
        private const val ARG_DECODED_QR_CODE = "decoded_qr_code"

        fun show(childFragmentManager: FragmentManager, decodedQrCode: DecodedQrCode) {
            QrScanTypeWarningDialog().apply {
                arguments = Bundle().apply {
                    putParcelable(ARG_DECODED_QR_CODE, decodedQrCode)
                }
            }.showWithStateCheck(childFragmentManager)
        }
    }
}
