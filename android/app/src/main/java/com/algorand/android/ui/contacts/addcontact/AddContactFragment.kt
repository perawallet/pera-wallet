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

package com.algorand.android.ui.contacts.addcontact

import android.content.Context
import android.widget.TextView
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.customviews.AccountIconImageView
import com.algorand.android.customviews.AlgorandInputLayout
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.OperationState
import com.algorand.android.models.QrScanner
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.User
import com.algorand.android.ui.contacts.BaseAddEditContactFragment
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.utils.Event
import com.algorand.android.utils.alertDialog
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.isValidAddress
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.google.android.material.button.MaterialButton
import com.google.firebase.crashlytics.internal.common.CommonUtils.hideKeyboard
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AddContactFragment : BaseAddEditContactFragment() {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::onBackPressed
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val addContactViewModel: AddContactViewModel by viewModels()

    private val args: AddContactFragmentArgs by navArgs()

    private val contractSearchingCollector: suspend (Event<OperationState<User?>>?) -> Unit = {
        it?.consume()?.let { operationState ->
            when (operationState) {
                is OperationState.Read -> {
                    if (operationState.data != null) {
                        showContactIsAlreadyExistDialog(operationState.data)
                    } else {
                        onContactSave()
                    }
                }
            }
        }
    }

    private val contactOperationCollector: suspend (Event<OperationState<User>>?) -> Unit = {
        it?.consume()?.let { operationState ->
            when (operationState) {
                is OperationState.Create -> {
                    if (args.returnContactToBackStack) {
                        navigateBackWithResult(operationState.data)
                    } else {
                        navBack()
                    }
                }
            }
        }
    }

    override fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            addContactViewModel.contactOperationFlow.collectLatest(contactOperationCollector)
        }
        viewLifecycleOwner.lifecycleScope.launch {
            addContactViewModel.contractSearchingFlow.collectLatest(contractSearchingCollector)
        }
    }

    override fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.addContactFragment) {
            useSavedStateValue<DecodedQrCode>(QrCodeScannerFragment.QR_SCAN_RESULT_KEY) { decodedQrCode ->
                if (!decodedQrCode.address.isNullOrBlank()) {
                    setContactAddressInputLayoutText(decodedQrCode.address)
                }
            }
        }
    }

    override fun setProfileImageView(accountIconImageView: AccountIconImageView) {
        accountIconImageView.loadAccountPlaceHolder(padding = R.dimen.spacing_normal)
    }

    override fun setEditProfilePhotoButton(materialButton: MaterialButton) {
        with(materialButton) {
            setIconResource(R.drawable.ic_plus)
            setOnClickListener { onImageAddClick() }
        }
    }

    override fun setAddPhotoTextView(textView: TextView) {
        textView.show()
    }

    override fun setContactNameInputLayout(algorandInputLayout: AlgorandInputLayout) {
        if (!args.contactName.isNullOrEmpty()) {
            algorandInputLayout.text = args.contactName!!
        }
    }

    override fun setContactAddressInputLayout(algorandInputLayout: AlgorandInputLayout) {
        if (!args.contactPublicKey.isNullOrEmpty()) {
            algorandInputLayout.text = args.contactPublicKey!!
        }
        algorandInputLayout.addTrailingIcon(R.drawable.ic_scan_qr, ::onScanQRClick)
    }

    override fun openQrScannerForAlgorandAddress(context: Context) {
        hideKeyboard(context, requireView())
        nav(
            AddContactFragmentDirections.actionAddContactFragmentToQrCodeScannerNavigation(
                QrScanner(scanTypes = arrayOf(QrCodeScannerFragment.ScanReturnType.ADDRESS_NAVIGATE_BACK))
            )
        )
    }

    override fun setAddContactButton(materialButton: MaterialButton) {
        materialButton.show()
        materialButton.setOnClickListener { checkContactNameAndAddress(materialButton.context) }
    }

    private fun onContactSave() {
        val contact = User(contactName, contactAddress, contactImageUri)
        addContactViewModel.insertContactToDatabase(contact)
    }

    private fun checkContactNameAndAddress(context: Context) {
        hideKeyboard(context, requireView())
        if (contactAddress.isValidAddress().not()) {
            showGlobalError(getString(R.string.entered_address_is_not_valid), getString(R.string.warning))
            return
        }
        contactName.ifBlank {
            showGlobalError(getString(R.string.contact_name_must), getString(R.string.warning))
            return
        }
        addContactViewModel.checkIsContactExist(contactAddress)
    }

    private fun showContactIsAlreadyExistDialog(contact: User) {
        context?.alertDialog {
            setMessage(getString(R.string.this_address_is_already_in_your_contract, contact.name))
            setPositiveButton(getString(R.string.overwrite_existing_contract)) { dialog, _ ->
                dialog.dismiss()
                onContactSave()
            }
            setNegativeButton(getString(R.string.cancel)) { dialog, _ ->
                dialog.dismiss()
            }
        }?.show()
    }
}
