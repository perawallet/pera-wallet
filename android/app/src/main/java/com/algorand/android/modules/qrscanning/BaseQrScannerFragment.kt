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

package com.algorand.android.modules.qrscanning

import android.os.Bundle
import android.view.View
import android.view.ViewTreeObserver
import androidx.annotation.StringRes
import androidx.core.view.isVisible
import androidx.fragment.app.activityViewModels
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentQrCodeScannerBinding
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.modules.deeplink.domain.model.BaseDeepLink
import com.algorand.android.modules.deeplink.ui.DeeplinkHandler
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.utils.CAMERA_PERMISSION
import com.algorand.android.utils.CAMERA_PERMISSION_REQUEST_CODE
import com.algorand.android.utils.SingleButtonBottomSheet
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.isPermissionGranted
import com.algorand.android.utils.requestPermissionFromUser
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.algorand.android.utils.walletconnect.WalletConnectViewModel
import com.google.zxing.BarcodeFormat
import com.google.zxing.ResultPoint
import com.journeyapps.barcodescanner.BarcodeCallback
import com.journeyapps.barcodescanner.BarcodeResult
import com.journeyapps.barcodescanner.DefaultDecoderFactory

/**
 * Base class for qr scanning
 * Each fragment that needs qr scanning should have its own qr scanning fragment with the following name format;
 *      XFragment -> XQrScannerFragment
 *
 * Child fragments should override necessary functions in DeepLinkHandler.Listener and behave accordingly.
 * If scanned qr is related to NOT overridden function, then onDeepLinkNotHandled function will be called.
 *      Example; If we only need account address, we should override onAccountAddressDeeplink function.
 *               In that case, if user scans WC qr, since onWalletConnectConnectionDeeplink is not overridden in child
 *               fragment, then onDeepLinkNotHandled will be called. This function can be used to show error.
 */
abstract class BaseQrScannerFragment(
    private val fragmentId: Int
) : BaseFragment(R.layout.fragment_qr_code_scanner), DeeplinkHandler.Listener {

    private val isCameraPermissionGranted: Boolean
        get() = view?.context?.isPermissionGranted(CAMERA_PERMISSION) ?: false

    private val walletConnectViewModel: WalletConnectViewModel by activityViewModels()
    private val qrScannerViewModel: QrScannerViewModel by activityViewModels()

    private val binding by viewBinding(FragmentQrCodeScannerBinding::bind)

    @StringRes
    open val titleTextResId: Int = R.string.find_a_code_to_scan
    open val shouldShowWcSessionsButton: Boolean = false

    private val statusBarConfiguration = StatusBarConfiguration(
        backgroundColor = R.color.transparent,
        showNodeStatus = false
    )

    override val fragmentConfiguration = FragmentConfiguration(statusBarConfiguration = statusBarConfiguration)

    private val onWindowFocusChangeListener = ViewTreeObserver.OnWindowFocusChangeListener {
        resumeCameraIfPossibleOrPause()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObserver()
        qrScannerViewModel.setDeeplinkHandlerListener(this)
        if (isCameraPermissionGranted) {
            setupBarcodeView()
        } else {
            requestPermissionFromUser(CAMERA_PERMISSION, CAMERA_PERMISSION_REQUEST_CODE, shouldShowAlways = true)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        qrScannerViewModel.removeDeeplinkHandlerListener()
    }

    private fun initUi() {
        with(binding) {
            titleTextView.text = getString(titleTextResId)
            leftArrowButton.setOnClickListener { onLeftArrowButtonClicked() }
            appConnectedButton.setOnClickListener { onAppConnectedButtonClicked() }
        }
    }

    private fun initObserver() {
        if (shouldShowWcSessionsButton) {
            viewLifecycleOwner.collectOnLifecycle(
                walletConnectViewModel.localSessionsFlow,
                ::onGetLocalSessionsSuccess
            )
        }
        viewLifecycleOwner.collectLatestOnLifecycle(
            qrScannerViewModel.isQrCodeInProgressFlow,
            ::onQrCodeProgressChanged
        )
    }

    private fun onLeftArrowButtonClicked() {
        navBack()
    }

    private fun onAppConnectedButtonClicked() {
        nav(HomeNavigationDirections.actionGlobalWalletConnectSessionsBottomSheet())
    }

    private fun setupBarcodeView() {
        with(binding.cameraPreview) {
            view?.let {
                decoderFactory = DefaultDecoderFactory(mutableListOf(BarcodeFormat.QR_CODE))
                decodeContinuous(barcodeCallback)
            }
        }
    }

    private val barcodeCallback: BarcodeCallback = object : BarcodeCallback {
        override fun barcodeResult(barcodeResult: BarcodeResult?) {
            view?.let {
                binding.cameraPreview.pause()
                if (barcodeResult != null) qrScannerViewModel.handleDeeplink(barcodeResult.text)
                resumeCameraIfPossibleOrPause()
            }
        }

        override fun possibleResultPoints(resultPoints: MutableList<ResultPoint>?) {
            // nothing to do
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            setupBarcodeView()
            resumeCameraIfPossibleOrPause()
        }
    }

    override fun onResume() {
        super.onResume()
        startSavedStateListener(fragmentId) {
            useSavedStateValue<Boolean>(SingleButtonBottomSheet.CLOSE_KEY) { isSuccessBottomSheetClosed ->
                if (isSuccessBottomSheetClosed) {
                    navBack()
                }
            }
        }
        resumeCameraIfPossibleOrPause()
        view?.viewTreeObserver?.addOnWindowFocusChangeListener(onWindowFocusChangeListener)
    }

    override fun onPause() {
        super.onPause()
        binding.cameraPreview.pause()
        view?.viewTreeObserver?.removeOnWindowFocusChangeListener(onWindowFocusChangeListener)
    }

    private fun onGetLocalSessionsSuccess(wcSessions: List<WalletConnect.SessionDetail>) {
        val numberOfSessions = wcSessions.count()
        binding.appConnectedButton.apply {
            isVisible = numberOfSessions > 0
            text = resources.getQuantityString(
                R.plurals.app_connected,
                numberOfSessions,
                numberOfSessions
            )
        }
    }

    private fun onQrCodeProgressChanged(isQrCodeInProgress: Boolean) {
        if (isQrCodeInProgress) {
            binding.cameraPreview.pause()
        } else {
            resumeCameraIfPossibleOrPause()
        }
    }

    private fun resumeCameraIfPossibleOrPause() {
        with(binding.cameraPreview) {
            view?.let {
                if (isCameraPermissionGranted && it.hasWindowFocus()) {
                    // TODO: 1/25/22 find a better solution to non-functional scanner bug which occurs when pause() is
                    //  called just after resume(). Calling pause() before each resume() solves the problem for now.
                    pause()
                    resume()
                    return
                }
            }
            pause()
        }
    }

    override fun onUndefinedDeepLink(undefinedDeeplink: BaseDeepLink.UndefinedDeepLink) {
        showGlobalError(getString(R.string.scanned_qr_is_not_valid))
    }

    override fun onDeepLinkNotHandled(deepLink: BaseDeepLink) {
        showGlobalError(getString(R.string.scanned_qr_is_not_valid))
    }

    override fun onAssetTransferDeepLink(assetTransaction: AssetTransaction): Boolean {
        return false
    }

    override fun onAssetOptInDeepLink(assetAction: AssetAction): Boolean {
        return false
    }

    override fun onImportAccountDeepLink(mnemonic: String): Boolean {
        return false
    }

    override fun onAccountAddressDeeplink(accountAddress: String, label: String?): Boolean {
        return false
    }

    override fun onWalletConnectConnectionDeeplink(wcUrl: String): Boolean {
        return false
    }

    override fun onAssetTransferWithNotOptInDeepLink(assetId: Long): Boolean {
        return false
    }
}
