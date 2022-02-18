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
package com.algorand.android.ui.notificationfilter

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentNotificationFilterBinding
import com.algorand.android.utils.Resource
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

abstract class BaseNotificationFilterFragment : DaggerBaseFragment(R.layout.fragment_notification_filter) {

    private val notificationFilterViewModel: NotificationFilterViewModel by viewModels()

    private val binding by viewBinding(FragmentNotificationFilterBinding::bind)

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

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupShowNotifications()
        setupRecyclerView()
        initObservers()
    }

    private fun setupRecyclerView() {
        if (accountNotificationFilterAdapter == null) {
            accountNotificationFilterAdapter = AccountNotificationFilterAdapter(::accountOptionChanged)
        }
        binding.filtersRecyclerView.apply {
            this.adapter = accountNotificationFilterAdapter
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
