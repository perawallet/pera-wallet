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

package com.algorand.android.ui.notificationfilter

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentNotificationFilterBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.Resource
import com.algorand.android.utils.addCustomDivider
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class NotificationFilterFragment : DaggerBaseFragment(R.layout.fragment_notification_filter) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.notifications,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val notificationFilterViewModel: NotificationFilterViewModel by viewModels()

    private val binding by viewBinding(FragmentNotificationFilterBinding::bind)

    private val args: NotificationFilterFragmentArgs by navArgs()

    private var accountNotificationFilterAdapter: AccountNotificationFilterAdapter? = null

    private val notificationObserverCollector: suspend (Resource<Unit>?) -> Unit = {
        it?.use(
            onFailed = { errorMessage -> showGlobalError(errorMessage.parse(requireContext())) },
            onLoading = {
                binding.blockerLoadingBar.root.visibility = View.VISIBLE
            },
            onLoadingFinished = {
                binding.blockerLoadingBar.root.visibility = View.GONE
            }
        )
    }

    private val listCollector: suspend (List<AccountNotificationOption>) -> Unit = {
        accountNotificationFilterAdapter?.submitList(it)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleBackPress()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupToolbar()
        setupShowNotifications()
        setupRecyclerView()
        initObservers()
    }

    private fun handleBackPress() {
        requireActivity().onBackPressedDispatcher.addCallback(object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                navBack()
            }
        })
    }

    private fun setupToolbar() {
        if (args.showDoneButton) {
            getAppToolbar()?.apply {
                val doneButton = LayoutInflater
                    .from(context)
                    .inflate(R.layout.custom_text_tab_button, this, false) as MaterialButton

                doneButton.apply {
                    setTextColor(ContextCompat.getColor(context, R.color.colorPrimary))
                    setText(R.string.done)
                    setOnClickListener { navBack() }
                    addViewToEndSide(this)
                }
            }
        }
    }

    private fun setupRecyclerView() {
        if (accountNotificationFilterAdapter == null) {
            accountNotificationFilterAdapter = AccountNotificationFilterAdapter(::accountOptionChanged)
        }
        binding.filtersRecyclerView.apply {
            this.adapter = accountNotificationFilterAdapter
            addCustomDivider(R.drawable.horizontal_divider, showLastDivider = false)
        }
    }

    private fun setupShowNotifications() {
        binding.pushNotificationsSwitch.isChecked = notificationFilterViewModel.isPushNotificationsEnabled()
        binding.pushNotificationsSwitch.setOnCheckedChangeListener { _, isChecked ->
            notificationFilterViewModel.setPushNotificationPreference(isChecked)
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            notificationFilterViewModel.notificationFilterListStateFlow.collectLatest(listCollector)
        }

        viewLifecycleOwner.lifecycleScope.launch {
            notificationFilterViewModel.notificationFilterOperation.collectLatest(notificationObserverCollector)
        }
    }

    private fun accountOptionChanged(publicKey: String, newFilterOption: Boolean) {
        notificationFilterViewModel.startFilterOperation(publicKey, newFilterOption)
    }
}
