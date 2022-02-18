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

package com.algorand.android.ui.contacts.editcontact

import android.content.Context
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.customviews.AccountIconImageView
import com.algorand.android.customviews.AlgorandInputLayout
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.OperationState
import com.algorand.android.models.QrScanner
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.User
import com.algorand.android.models.WarningConfirmation
import com.algorand.android.ui.common.warningconfirmation.WarningConfirmationBottomSheet
import com.algorand.android.ui.contacts.BaseAddEditContactFragment
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.utils.Event
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
class EditContactFragment : BaseAddEditContactFragment() {

    private val toolbarConfiguration: ToolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::onBackPressed,
        titleResId = R.string.edit_contact
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val contactDatabaseId: Int by lazy { args.contactDatabaseId }

    private val contactOperationCollector: suspend (Event<OperationState<User>>?) -> Unit = {
        it?.consume()?.let { operationState ->
            when (operationState) {
                is OperationState.Update -> navigateBackWithResult(operationState.data)
                OperationState.Delete -> navBack()
            }
        }
    }

    private val editContactViewModel: EditContactViewModel by viewModels()

    private val args: EditContactFragmentArgs by navArgs()

    override fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.editContactFragment) {
            useSavedStateValue<Boolean>(WarningConfirmationBottomSheet.WARNING_CONFIRMATION_KEY) {
                editContactViewModel.removeContactInDatabase(contactDatabaseId)
            }
            useSavedStateValue<DecodedQrCode>(QrCodeScannerFragment.QR_SCAN_RESULT_KEY) { decodedQrCode ->
                if (!decodedQrCode.address.isNullOrBlank()) {
                    setContactAddressInputLayoutText(decodedQrCode.address)
                }
            }
        }
    }

    override fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            editContactViewModel.contactOperationFlow.collectLatest(contactOperationCollector)
        }
    }

    override fun openQrScannerForAlgorandAddress(context: Context) {
        hideKeyboard(context, requireView())
        nav(
            EditContactFragmentDirections.actionEditContactFragmentToQrCodeScannerNavigation(
                QrScanner(arrayOf(QrCodeScannerFragment.ScanReturnType.ADDRESS_NAVIGATE_BACK))
            )
        )
    }

    override fun setToolbar(customToolbar: CustomToolbar?) {
        customToolbar?.addButtonToEnd(TextButton(R.string.done) {
            onContactEdit(customToolbar.context)
        })
    }

    override fun setProfileImageView(accountIconImageView: AccountIconImageView) {
        contactImageUri = args.contactProfileImageUri
    }

    override fun setEditProfilePhotoButton(materialButton: MaterialButton) {
        with(materialButton) {
            setIconResource(R.drawable.ic_edit)
            setOnClickListener { onImageAddClick() }
        }
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
        algorandInputLayout.setOnEndIconClickListener { onScanQRClick() }
    }

    override fun setDeleteContactButton(materialButton: MaterialButton) {
        super.setDeleteContactButton(materialButton)
        materialButton.show()
        materialButton.setOnClickListener { onRemoveContactClick() }
    }

    private fun onRemoveContactClick() {
        val warningConfirmation = WarningConfirmation(
            titleRes = R.string.delete_contact,
            descriptionRes = R.string.are_you_sure_you_want_to_delete,
            drawableRes = R.drawable.ic_trash,
            positiveButtonTextRes = R.string.yes_delete_contact,
            negativeButtonTextRes = R.string.keep_it
        )
        nav(EditContactFragmentDirections.actionEditContactFragmentToWarningConfirmationNavigation(warningConfirmation))
    }

    private fun onContactEdit(context: Context) {
        hideKeyboard(context, requireView())
        if (contactAddress.isValidAddress().not()) {
            showGlobalError(getString(R.string.entered_address_is_not_valid), getString(R.string.warning))
            return
        }
        contactName.ifBlank {
            showGlobalError(getString(R.string.contact_name_must), getString(R.string.warning))
            return
        }
        val operatedContact = User(contactName, contactAddress, contactImageUri, contactDatabaseId)
        editContactViewModel.updateContactInDatabase(operatedContact)
    }
}
