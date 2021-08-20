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

package com.algorand.android.ui.contacts.addcontact

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import androidx.core.net.toUri
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.R
import com.algorand.android.R.string
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentAddEditContactBinding
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.User
import com.algorand.android.ui.common.warningconfirmation.WarningConfirmationBottomSheet.Companion.WARNING_CONFIRMATION_KEY
import com.algorand.android.ui.contacts.addcontact.AddEditContactFragmentDirections.Companion.actionAddContactFragmentToAddContactQrScannerFragment
import com.algorand.android.ui.contacts.addcontact.AddEditContactFragmentDirections.Companion.actionAddEditContactFragmentToWarningConfirmationBottomSheet
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.ui.qr.QrCodeScannerFragment.Companion.QR_SCAN_RESULT_KEY
import com.algorand.android.utils.IMAGE_READ_REQUEST
import com.algorand.android.utils.alertDialog
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.isPermissionGranted
import com.algorand.android.utils.isValidAddress
import com.algorand.android.utils.loadContactProfileImage
import com.algorand.android.utils.requestPermissionFromUser
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.startImagePickerIntent
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AddEditContactFragment : DaggerBaseFragment(R.layout.fragment_add_edit_contact) {

    // TODO use args here.
    private var contactName: String? = null
    private var contactPublicKey: String? = null
    private var contactProfileImageUri: String? = null
    private var contactDatabaseId: Int = NO_DATABASE_ID
    private var returnContactToBackStack: Boolean = false

    private val addEditContactViewModel: AddEditContactViewModel by viewModels()

    private val binding by viewBinding(FragmentAddEditContactBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::onBackPressed
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        arguments?.let {
            with(AddEditContactFragmentArgs.fromBundle(it)) {
                this@AddEditContactFragment.contactName = contactName
                this@AddEditContactFragment.contactPublicKey = contactPublicKey
                this@AddEditContactFragment.contactProfileImageUri = contactProfileImageUri
                this@AddEditContactFragment.contactDatabaseId = contactDatabaseId
                this@AddEditContactFragment.returnContactToBackStack = returnContactToBackStack
            }
        }
        val isInEditMode = contactDatabaseId != NO_DATABASE_ID
        initObservers()
        customizeUI(isInEditMode)
        restoreInputs()
        binding.scanQrButton.setOnClickListener { onScanQRClick() }
        binding.contactImageActionButton.apply {
            setIconResource(if (isInEditMode) R.drawable.ic_edit else R.drawable.ic_add)
            setOnClickListener { onImageAddClick() }
        }
        initDialogSavedStateListener()
    }

    private fun initObservers() {
        addEditContactViewModel.isContactOperationFinished.observe(viewLifecycleOwner, Observer { operatedContact ->
            if (operatedContact != null && returnContactToBackStack) {
                navigateBackWithResult(operatedContact)
            } else {
                navBack()
            }
        })

        addEditContactViewModel.isContractSearchingFinished.observe(viewLifecycleOwner, Observer { searchedContact ->
            if (searchedContact != null) {
                showContactIsAlreadyExistDialog(searchedContact)
            } else {
                insertContactToDatabase()
            }
        })
    }

    private fun showContactIsAlreadyExistDialog(contact: User) {
        context?.alertDialog {
            setMessage(getString(string.this_address_is_already_in_your_contract, contact.name))
            setPositiveButton(getString(string.overwrite_existing_contract)) { dialog, _ ->
                dialog.dismiss()
                insertContactToDatabase()
            }
            setNegativeButton(getString(string.cancel)) { dialog, _ ->
                dialog.dismiss()
            }
        }?.show()
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.addEditContactFragment) {
            useSavedStateValue<Boolean>(WARNING_CONFIRMATION_KEY) {
                addEditContactViewModel.removeContactInDatabase(contactDatabaseId)
            }
            useSavedStateValue<DecodedQrCode>(QR_SCAN_RESULT_KEY) { decodedQrCode ->
                if (!decodedQrCode.address.isNullOrBlank()) {
                    binding.addressEditText.setText(decodedQrCode.address)
                }
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            if (requestCode == IMAGE_PERMISSION_REQUEST_CODE) {
                saveInputs()
                startImagePickerIntent()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        super.onActivityResult(requestCode, resultCode, intent)
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                IMAGE_READ_REQUEST -> {
                    intent?.data?.let { uri ->
                        binding.contactImageView.loadContactProfileImage(uri, true)
                        contactProfileImageUri = uri.toString()
                    }
                }
            }
        }
    }

    private fun openQrScannerForAlgorandAddress() {
        saveInputs()
        binding.scanQrButton.hideKeyboard()
        nav(
            actionAddContactFragmentToAddContactQrScannerFragment(
                listOf(QrCodeScannerFragment.ScanReturnType.ADDRESS_NAVIGATE_BACK).toTypedArray()
            )
        )
    }

    private fun saveInputs() {
        contactName = binding.nameTextView.text.toString()
        contactPublicKey = binding.addressEditText.text.toString()
    }

    private fun restoreInputs() {
        if (contactName != null) {
            binding.nameTextView.setText(contactName)
        }
        if (contactPublicKey != null) {
            binding.addressEditText.setText(contactPublicKey)
        }
        binding.contactImageView.loadContactProfileImage(contactProfileImageUri?.toUri(), true)
    }

    private fun removeAllEditTextFocuses() {
        binding.nameTextView.clearFocus()
        binding.addressEditText.clearFocus()
    }

    private fun onScanQRClick() {
        removeAllEditTextFocuses()
        openQrScannerForAlgorandAddress()
    }

    private fun navigateBackWithResult(selectedContact: User) {
        setNavigationResult(CONTACT_ADDED_KEY, selectedContact)
        navBack()
    }

    private fun onContactSave() {
        binding.addButton.hideKeyboard()
        val address = binding.addressEditText.text.toString().trim()
        val name = binding.nameTextView.text.toString()
        if (address.isValidAddress().not()) {
            showGlobalError(getString(R.string.entered_address_is_not_valid), getString(R.string.warning))
            return
        }
        if (name.isBlank()) {
            showGlobalError(getString(R.string.contact_name_must), getString(R.string.warning))
            return
        }
        val operatedContact = User(name, address, contactProfileImageUri)

        if (contactDatabaseId == NO_DATABASE_ID) {
            addEditContactViewModel.checkIsContactExist(operatedContact.publicKey)
        } else {
            operatedContact.contactDatabaseId = contactDatabaseId
            addEditContactViewModel.updateContactInDatabase(operatedContact)
        }
    }

    private fun insertContactToDatabase() {
        val address = binding.addressEditText.text.toString().trim()
        val name = binding.nameTextView.text.toString()
        val contact = User(name, address, contactProfileImageUri)
        addEditContactViewModel.insertContactToDatabase(contact)
    }

    private fun onImageAddClick() {
        saveInputs()
        if (context?.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) == true) {
            startImagePickerIntent()
        } else {
            requestPermissionFromUser(Manifest.permission.READ_EXTERNAL_STORAGE, IMAGE_PERMISSION_REQUEST_CODE, true)
        }
    }

    private fun customizeUI(isInEditMode: Boolean) {
        if (isInEditMode) {
            binding.removeButton.apply {
                visibility = View.VISIBLE
                setOnClickListener { onRemoveContactClick() }
            }

            getAppToolbar()?.apply {
                changeTitle(getString(R.string.edit_contact))

                val doneButton = LayoutInflater
                    .from(context)
                    .inflate(R.layout.custom_text_tab_button, this, false) as MaterialButton

                doneButton.apply {
                    setText(R.string.done)
                    setOnClickListener { onContactSave() }
                    addViewToEndSide(this)
                }
            }
        } else {
            binding.addButton.apply {
                visibility = View.VISIBLE
                setOnClickListener { onContactSave() }
            }

            getAppToolbar()?.changeTitle(getString(R.string.add_contact))
        }
    }

    private fun onRemoveContactClick() {
        nav(
            actionAddEditContactFragmentToWarningConfirmationBottomSheet(
                titleTextResId = R.string.remove_contact,
                descriptionTextResId = R.string.are_you_sure_you_want_to_delete,
                drawableResId = R.drawable.ic_trash,
                positiveButtonTextResId = R.string.remove_contact,
                negativeButtonTextResId = R.string.keep
            )
        )
    }

    private fun onBackPressed() {
        view?.hideKeyboard()
        navBack()
    }

    companion object {
        const val CONTACT_ADDED_KEY = "contact_added_key"

        private const val IMAGE_PERMISSION_REQUEST_CODE = 1013
        private const val NO_DATABASE_ID = -1
    }
}
