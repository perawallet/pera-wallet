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

package com.algorand.android.ui.contacts

import android.os.Bundle
import android.os.Handler
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.core.BaseBottomBarFragment
import com.algorand.android.databinding.FragmentContactsBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ScreenState
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.User
import com.algorand.android.ui.common.user.UserAdapter
import com.algorand.android.utils.KeyboardToggleListener
import com.algorand.android.utils.addKeyboardToggleListener
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.removeKeyboardToggleListener
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ContactsFragment : BaseBottomBarFragment(R.layout.fragment_contacts) {

    private val toolbarConfiguration = ToolbarConfiguration(backgroundColor = R.color.primaryBackground)

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = true,
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    private val contactsViewModel: ContactsViewModel by viewModels()

    private val binding by viewBinding(FragmentContactsBinding::bind)

    private var userAdapter: UserAdapter? = null
    private var openBottomBarHandler: Handler? = null
    private var keyboardToggleListener: KeyboardToggleListener? = null

    private val contactListObserver = Observer<List<User>> { contactList ->
        userAdapter?.submitList(contactList)
        with(binding) {
            searchBar.isVisible = contactList.isNotEmpty() || searchBar.text.isNotEmpty()
            contactsRecyclerView.isVisible = contactList.isNotEmpty() || searchBar.text.isNotEmpty()
            updateScreenState(contactList.isEmpty(), searchBar.text.isNotEmpty())
        }
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

    private val onContactClick: (contact: User) -> Unit = { contact ->
        view?.hideKeyboard()
        nav(ContactsFragmentDirections.actionContactsFragmentToContactInfoFragment(contact))
    }

    private val onContactQrClick: (contact: User) -> Unit = { contact ->
        nav(ContactsFragmentDirections.actionContactsFragmentToShowQrBottomSheet(contact.name, contact.publicKey))
    }

    private val emptyScreenState by lazy {
        ScreenState.CustomState(
            icon = R.drawable.ic_menu_contacts,
            title = R.string.you_havent,
            description = R.string.you_can_make_the,
            buttonText = R.string.add_contact
        )
    }
    private val notFoundScreenState by lazy {
        ScreenState.CustomState(
            title = R.string.no_contact_found,
            description = R.string.try_different_contact_name
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        setupSearchQueryEditTextWatcher()
        initObservers()
        setupToolbar()
        binding.titleTextView.requestFocus()
    }

    private fun setupToolbar() {
        getAppToolbar()?.addButtonToEnd(IconButton(R.drawable.ic_plus, onClick = ::addContactClick))
    }

    private fun initObservers() {
        contactsViewModel.contactsListLiveData.observe(viewLifecycleOwner, contactListObserver)
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

    private fun setupRecyclerView() {
        userAdapter = UserAdapter(onContactClick, onContactQrClick)
        binding.contactsRecyclerView.adapter = userAdapter
    }

    private fun setupSearchQueryEditTextWatcher() {
        binding.searchBar.setOnTextChanged { query ->
            contactsViewModel.updateContactsListLiveDataWithSearchQuery(query)
        }
    }

    private fun addContactClick() {
        nav(ContactsFragmentDirections.actionContactsFragmentToAddContactFragment())
    }

    private fun updateScreenState(shouldShown: Boolean, isQueryStated: Boolean) {
        with(binding.screenStateView) {
            isVisible = shouldShown
            if (shouldShown) {
                if (isQueryStated) {
                    setupUi(notFoundScreenState)
                    clearNeutralButtonClickListener()
                } else {
                    setupUi(emptyScreenState)
                    setOnNeutralButtonClickListener(::addContactClick)
                }
            }
        }
    }

    companion object {
        private const val BOTTOM_NAV_OPEN_DELAY_DURATION = 300L
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_contacts"
    }
}
