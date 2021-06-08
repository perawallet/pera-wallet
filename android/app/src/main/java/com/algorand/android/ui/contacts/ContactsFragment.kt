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

package com.algorand.android.ui.contacts

import android.os.Bundle
import android.os.Handler
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.databinding.FragmentContactsBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.User
import com.algorand.android.ui.common.user.UserAdapter
import com.algorand.android.ui.contacts.ContactsFragmentDirections.Companion.actionContactsFragmentToAddEditContactFragment
import com.algorand.android.ui.contacts.ContactsFragmentDirections.Companion.actionContactsFragmentToContactInfoFragment
import com.algorand.android.ui.contacts.ContactsFragmentDirections.Companion.actionContactsFragmentToShowQrBottomSheet
import com.algorand.android.utils.KeyboardToggleListener
import com.algorand.android.utils.addKeyboardToggleListener
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.removeKeyboardToggleListener
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ContactsFragment : DaggerBaseFragment(R.layout.fragment_contacts) {

    private val contactsViewModel: ContactsViewModel by viewModels()

    private val binding by viewBinding(FragmentContactsBinding::bind)

    private var userAdapter: UserAdapter? = null
    private var openBottomBarHandler: Handler? = null
    private var keyboardToggleListener: KeyboardToggleListener? = null

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val contactListObserver = Observer<List<User>> { contactList ->
        userAdapter?.submitList(contactList)
        if (contactList.isEmpty()) {
            if (binding.searchEditText.text.isEmpty()) {
                binding.emptyLayout.visibility = View.VISIBLE
            } else {
                binding.notFoundLayout.visibility = View.VISIBLE
            }
        } else {
            binding.emptyLayout.visibility = View.INVISIBLE
            binding.notFoundLayout.visibility = View.INVISIBLE
        }
    }

    // </editor-fold>

    val toolbarConfiguration =
        ToolbarConfiguration(titleResId = R.string.contacts, type = CustomToolbar.Type.TAB_TOOLBAR)

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = true,
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        setupSearchQueryEditTextWatcher()
        initObservers()
        setupToolbar()
        binding.addContactButton.setOnClickListener { addContactClick() }
    }

    private fun setupToolbar() {
        getAppToolbar()?.apply {
            val marginEnd = resources.getDimensionPixelSize(R.dimen.page_horizontal_spacing)

            val addContactButton = LayoutInflater
                .from(context)
                .inflate(R.layout.custom_circle_tab_button, this, false) as MaterialButton

            addContactButton.apply {
                setIconResource(R.drawable.ic_add)
                backgroundTintList = ContextCompat.getColorStateList(context, R.color.colorPrimary)
                setOnClickListener { addContactClick() }
                addViewToEndSide(this, marginEnd)
            }
        }
    }

    private fun initObservers() {
        contactsViewModel.contactsListLiveData.observe(viewLifecycleOwner, contactListObserver)
    }

    private val onKeyboardToggleAction: (shown: Boolean) -> Unit = { keyboardShown ->
        if (keyboardShown) {
            (activity as? MainActivity)?.isBottomBarNavigationVisible = false
        } else {
            openBottomBarHandler = Handler()
            openBottomBarHandler?.postDelayed({
                (activity as? MainActivity)?.isBottomBarNavigationVisible = true
            }, BOTTOM_NAV_OPEN_DELAY_DURATION)
        }
    }

    override fun onResume() {
        super.onResume()
        keyboardToggleListener = addKeyboardToggleListener(binding.root, onKeyboardToggleAction)
    }

    override fun onPause() {
        super.onPause()
        openBottomBarHandler?.removeCallbacksAndMessages(null)
        keyboardToggleListener?.removeKeyboardToggleListener(binding.root)
    }

    private val onContactClick: (contact: User) -> Unit = { contact ->
        view?.hideKeyboard()
        nav(actionContactsFragmentToContactInfoFragment(contact))
    }

    private val onContactQrClick: (contact: User) -> Unit = { contact ->
        nav(actionContactsFragmentToShowQrBottomSheet(contact.name, contact.publicKey))
    }

    // TODO remove this after implementing ContactSelectorBottomSheet

    private fun setupRecyclerView() {
        userAdapter = UserAdapter(onContactClick, onContactQrClick)
        binding.contactsRecyclerView.adapter = userAdapter
    }

    private fun setupSearchQueryEditTextWatcher() {
        binding.searchEditText.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                // nothing to do
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
                // nothing to do
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                contactsViewModel.updateContactsListLiveDataWithSearchQuery(s.toString())
            }
        })
    }

    private fun addContactClick() {
        nav(actionContactsFragmentToAddEditContactFragment())
    }

    companion object {
        private const val BOTTOM_NAV_OPEN_DELAY_DURATION = 300L
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_contacts"
    }
}
