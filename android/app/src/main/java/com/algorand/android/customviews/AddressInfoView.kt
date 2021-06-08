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

import android.content.Context
import android.text.InputType
import android.util.AttributeSet
import android.view.View
import android.view.inputmethod.EditorInfo
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.net.toUri
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomAddressInfoBinding
import com.algorand.android.models.User
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.loadContactProfileImage
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.viewbinding.viewBinding

class AddressInfoView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private var listener: Listener? = null

    private var contact: User? = null

    private val binding = viewBinding(CustomAddressInfoBinding::inflate)

    init {
        initView()
    }

    private fun initView() {
        binding.addressEditText.apply {
            imeOptions = EditorInfo.IME_ACTION_DONE
            setRawInputType(InputType.TYPE_CLASS_TEXT)
        }

        binding.addressLayout.setOnClickListener { startEditMode() }
        binding.accountsLayout.setOnClickListener { listener?.onMyAccountsClick() }
        binding.scanQrLayout.setOnClickListener { listener?.onScanQrCodeClick() }
        binding.contactsLayout.setOnClickListener { listener?.onContactsClick() }
        binding.cancelButton.setOnClickListener { onCancelClick() }
    }

    private fun onCancelClick() {
        showPreEditUI()

        binding.cancelButton.requestFocus()
        binding.addressEditText.text = null
        contact = null
        hideKeyboard()
        binding.editTextGroup.visibility = View.GONE
        binding.contactDetailGroup.visibility = View.GONE
        binding.fillingTypeGroup.visibility = View.VISIBLE
        binding.cancelButton.visibility = View.GONE
    }

    private fun startEditMode() {
        showEditUI()

        binding.editTextGroup.visibility = View.VISIBLE
        binding.addressEditText.requestFocus()
    }

    fun setSelectedContact(user: User?) {
        if (user == null) {
            return
        }

        showEditUI()

        binding.editTextGroup.visibility = View.GONE
        binding.addressEditText.text = null

        contact = user

        binding.contactImageView.loadContactProfileImage(user.imageUriAsString?.toUri())
        binding.contactNameTextView.text = user.name
        binding.adressTextView.text = user.publicKey.toShortenedAddress()

        binding.contactDetailGroup.visibility = View.VISIBLE
    }

    fun getSelectedContact(): User? {
        return contact
    }

    fun setAddress(contactPublicKey: String?) {
        if (contactPublicKey == null) {
            return
        }

        showEditUI()

        binding.contactDetailGroup.visibility = View.GONE

        contact = null
        with(binding.addressEditText) {
            setText(contactPublicKey)
            setSelection(text.length)
        }
        binding.editTextGroup.visibility = View.VISIBLE
    }

    fun getToAddress(): String {
        if (contact != null) {
            contact?.let {
                return it.publicKey
            }
        }
        return binding.addressEditText.text.toString().trim()
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    private fun showEditUI() {
        setBackgroundResource(R.drawable.bg_small_shadow)
        binding.fillingTypeGroup.visibility = View.GONE
        binding.cancelButton.visibility = View.VISIBLE
    }

    private fun showPreEditUI() {
        background = null
        setPadding(0)
    }

    open class Listener {
        open fun onMyAccountsClick() {}
        open fun onScanQrCodeClick() {}
        open fun onContactsClick() {}
    }
}
