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

package com.algorand.android.ui.qr

import android.os.Bundle
import android.os.Parcelable
import android.view.View
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentQrCodeScannerBinding
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.CAMERA_PERMISSION
import com.algorand.android.utils.CAMERA_PERMISSION_REQUEST_CODE
import com.algorand.android.utils.getContentOfQR
import com.algorand.android.utils.handleDeeplink
import com.algorand.android.utils.isPermissionGranted
import com.algorand.android.utils.requestPermissionFromUser
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.zxing.BarcodeFormat
import com.google.zxing.ResultPoint
import com.journeyapps.barcodescanner.BarcodeCallback
import com.journeyapps.barcodescanner.BarcodeResult
import com.journeyapps.barcodescanner.DefaultDecoderFactory
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlinx.parcelize.Parcelize

@AndroidEntryPoint
class QrCodeScannerFragment : DaggerBaseFragment(R.layout.fragment_qr_code_scanner) {

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    private var isCameraPermissionGranted = false

    private val args: QrCodeScannerFragmentArgs by navArgs()

    private val binding by viewBinding(FragmentQrCodeScannerBinding::bind)

    private val statusBarConfiguration =
        StatusBarConfiguration(backgroundColor = R.color.transparent, showNodeStatus = false)

    override val fragmentConfiguration = FragmentConfiguration(statusBarConfiguration = statusBarConfiguration)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        isCameraPermissionGranted = view.context.isPermissionGranted(CAMERA_PERMISSION)

        if (isCameraPermissionGranted) {
            setupBarcodeView()
        } else {
            requestPermissionFromUser(
                CAMERA_PERMISSION,
                CAMERA_PERMISSION_REQUEST_CODE,
                true
            )
        }

        binding.closeButton.setOnClickListener { activity?.onBackPressed() }
    }

    private fun setupBarcodeView() {
        binding.cameraPreview.apply {
            decoderFactory = DefaultDecoderFactory(mutableListOf(BarcodeFormat.QR_CODE))
            decodeContinuous(barcodeCallback)
        }
    }

    private val barcodeCallback: BarcodeCallback = object : BarcodeCallback {
        override fun barcodeResult(barcodeResult: BarcodeResult?) {
            binding.cameraPreview.pause()
            if (barcodeResult != null) {
                val (scanResult, decodedQRCode) = getContentOfQR(barcodeResult.text, args.scanReturnType)
                if (decodedQRCode != null) {
                    if (scanResult == ScanReturnType.NAVIGATE_FORWARD) {
                        if (findNavController().handleDeeplink(
                                decodedQRCode,
                                accountCacheManager,
                                childFragmentManager
                            )
                        ) {
                            return
                        }
                    } else {
                        navigateBackWithResult(decodedQRCode)
                        return
                    }
                } else {
                    context?.showAlertDialog(getString(R.string.warning), getString(R.string.scanned_qr_is_not_valid))
                }
            }
            binding.cameraPreview.resume()
        }

        override fun possibleResultPoints(resultPoints: MutableList<ResultPoint>?) {
            // nothing to do
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            isCameraPermissionGranted = true
            setupBarcodeView()
            binding.cameraPreview.resume()
        }
    }

    override fun onResume() {
        super.onResume()
        if (isCameraPermissionGranted) {
            binding.cameraPreview.resume()
        }
    }

    override fun onPause() {
        super.onPause()
        binding.cameraPreview.pause()
    }

    fun navigateBackWithResult(decodedQrCode: DecodedQrCode) {
        setNavigationResult(QR_SCAN_RESULT_KEY, decodedQrCode)
        navBack()
    }

    @Parcelize
    enum class ScanReturnType : Parcelable {
        MNEMONIC_NAVIGATE_BACK,
        ADDRESS_NAVIGATE_BACK,
        NAVIGATE_FORWARD,
        WALLET_CONNECT_NAVIGATE_BACK
    }

    companion object {
        const val QR_SCAN_RESULT_KEY = "qr_scan_result_key"
    }
}
