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

package com.algorand.android.ui.contacts

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.net.toUri
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.AccountIconImageView
import com.algorand.android.customviews.AlgorandInputLayout
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.databinding.FragmentBaseAddEditContactBinding
import com.algorand.android.models.User
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.isPermissionGranted
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton
import kotlin.properties.Delegates

abstract class BaseAddEditContactFragment : DaggerBaseFragment(R.layout.fragment_base_add_edit_contact) {

    private val binding by viewBinding(FragmentBaseAddEditContactBinding::bind)

    private val startForContactImageResult =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (result.resultCode == Activity.RESULT_OK) {
                contactImageUri = result.data?.data.toString()
                with(binding.editProfilePhotoButton) {
                    setIconResource(R.drawable.ic_pen)
                    setIconTintResource(R.color.primaryBackground)
                }
            }
        }

    private val requestForImagePickerPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted ->
            if (isGranted) {
                startImagePicker()
            }
        }

    protected val contactName: String
        get() = binding.contactNameCustomInputLayout.text

    protected val contactAddress: String
        get() = binding.addressCustomInputLayout.text.trim()

    open var contactImageUri: String? by Delegates.observable(null) { _, _, newValue ->
        binding.contactImageView.loadAccountImage(
            uri = newValue?.toUri(),
            padding = R.dimen.spacing_normal
        )
    }

    abstract fun setProfileImageView(accountIconImageView: AccountIconImageView)
    abstract fun setEditProfilePhotoButton(materialButton: MaterialButton)
    abstract fun setContactNameInputLayout(algorandInputLayout: AlgorandInputLayout)
    abstract fun setContactAddressInputLayout(algorandInputLayout: AlgorandInputLayout)
    abstract fun initObservers()
    abstract fun initDialogSavedStateListener()

    open fun setToolbar(customToolbar: CustomToolbar?) {}
    open fun setAddContactButton(materialButton: MaterialButton) {}
    open fun setAddPhotoTextView(textView: TextView) {}
    open fun setDeleteContactButton(materialButton: MaterialButton) {}

    abstract fun openQrScannerForAlgorandAddress(context: Context)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        with(binding) {
            setToolbar(getAppToolbar())
            setProfileImageView(contactImageView)
            setEditProfilePhotoButton(editProfilePhotoButton)
            setContactNameInputLayout(contactNameCustomInputLayout)
            setContactAddressInputLayout(addressCustomInputLayout)
            setDeleteContactButton(deleteContactButton)
            setAddContactButton(addContactButton)
            setAddPhotoTextView(addPhotoTextView)
        }
        initObservers()
    }

    open fun initUi() {
        with(binding) {
            addressCustomInputLayout.setOnTextChangeListener(::onAddressChangedListener)
            contactNameCustomInputLayout.setOnTextChangeListener(::onNameChangedListener)
        }
    }

    override fun onResume() {
        super.onResume()
        initDialogSavedStateListener()
    }

    protected fun onBackPressed() {
        view?.hideKeyboard()
        navBack()
    }

    protected fun onImageAddClick() {
        if (context?.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE) == true) {
            startImagePicker()
        } else {
            requestForImagePickerPermissionLauncher.launch(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
    }

    protected fun navigateBackWithResult(selectedContact: User) {
        setNavigationResult(CONTACT_ADDED_KEY, selectedContact)
        navBack()
    }

    protected fun setContactAddressInputLayoutText(text: String) {
        binding.addressCustomInputLayout.text = text
    }

    private fun removeAllInputLayoutFocuses() {
        binding.contactNameCustomInputLayout.clearFocus()
        binding.addressCustomInputLayout.clearFocus()
    }

    protected fun onScanQRClick() {
        removeAllInputLayoutFocuses()
        openQrScannerForAlgorandAddress(binding.root.context)
    }

    private fun startImagePicker() {
        val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
        startForContactImageResult.launch(intent)
    }

    private fun onNameChangedListener(name: String) {
        with(binding) {
            addContactButton.isEnabled = name.isNotEmpty() && addressCustomInputLayout.text.isNotEmpty()
        }
    }

    private fun onAddressChangedListener(address: String) {
        with(binding) {
            addContactButton.isEnabled = address.isNotEmpty() && contactNameCustomInputLayout.text.isNotEmpty()
        }
    }

    companion object {
        private const val CONTACT_ADDED_KEY = "contact_added_key"
    }
}
