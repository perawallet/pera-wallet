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

import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.customviews.AlgorandInputLayout
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.OperationState
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.User
import com.algorand.android.ui.contacts.BaseAddEditContactFragment
import com.algorand.android.ui.contacts.addcontact.AddContactQrScannerFragment.Companion.ACCOUNT_ADDRESS_QR_SCAN_RESULT_KEY
import com.algorand.android.utils.Event
import com.algorand.android.utils.alertDialog
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.setContactIconDrawable
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.isValidAddress
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

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
                else -> {
                    sendErrorLog("Unhandled else case in contractSearchingCollector")
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
                else -> {
                    sendErrorLog("Unhandled else case in contactOperationCollector")
                }
            }
        }
    }

    override fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            addContactViewModel.contactOperationFlow,
            contactOperationCollector
        )
        viewLifecycleOwner.collectLatestOnLifecycle(
            addContactViewModel.contractSearchingFlow,
            contractSearchingCollector
        )
    }

    override fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.addContactFragment) {
            useSavedStateValue<String>(ACCOUNT_ADDRESS_QR_SCAN_RESULT_KEY) { accountAddress ->
                setContactAddressInputLayoutText(accountAddress)
            }
        }
    }

    override fun setProfileImageView(imageView: ImageView) {
        imageView.setContactIconDrawable(null, R.dimen.account_icon_size_xlarge)
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
        algorandInputLayout.addTrailingIcon(R.drawable.ic_qr_scan, ::onScanQRClick)
    }

    override fun openQrScannerForAlgorandAddress() {
        view?.hideKeyboard()
        nav(AddContactFragmentDirections.actionAddContactFragmentToAddContactQrScannerFragment())
    }

    override fun setAddContactButton(materialButton: MaterialButton) {
        materialButton.show()
        materialButton.setOnClickListener { checkContactNameAndAddress() }
    }

    private fun onContactSave() {
        val contact = User(contactName, contactAddress, contactImageUri)
        addContactViewModel.insertContactToDatabase(contact)
    }

    private fun checkContactNameAndAddress() {
        view?.hideKeyboard()
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
