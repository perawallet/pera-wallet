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

package com.algorand.android.ui.register

import android.content.SharedPreferences
import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.View
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentAddAccountBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.ui.register.AddAccountFragmentDirections.Companion.actionAddAccountFragmentToLoginNavigation
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getNavigationBackStackCount
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.openPrivacyPolicyUrl
import com.algorand.android.utils.openTermsAndServicesUrl
import com.algorand.android.utils.rotateContinuously
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class AddAccountFragment : DaggerBaseFragment(R.layout.fragment_add_account) {

    @Inject
    lateinit var accountManager: AccountManager

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val binding by viewBinding(FragmentAddAccountBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiaryBackground)

    override val fragmentConfiguration = FragmentConfiguration(
        statusBarConfiguration = statusBarConfiguration
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupCloseButton()
        setupTitleText()
        setupPolicyText()
        startAnimateBackground()
        binding.nextButton.setOnClickListener { onAddAccountClick() }
    }

    private fun setupCloseButton() {
        if (activity?.getNavigationBackStackCount() != 0) {
            binding.closeImageButton.apply {
                visibility = View.VISIBLE
                setOnClickListener { navBack() }
            }
        }
    }

    private fun setupTitleText() {
        binding.titleTextView.setText(
            if (accountManager.isThereAnyRegisteredAccount()) {
                R.string.add_new_account
            } else {
                R.string.manage_all_assets_two_line
            }
        )
    }

    private fun setupPolicyText() {
        binding.policyTextView.apply {
            val linkTextColor = ContextCompat.getColor(context, R.color.linkTextColor)
            val termAndConditionsString = AnnotatedString(
                stringResId = R.string.by_creating_account,
                customAnnotationList = listOf(
                    "terms_click" to getCustomClickableSpan(linkTextColor) { context?.openTermsAndServicesUrl() },
                    "privacy_click" to getCustomClickableSpan(linkTextColor) { context?.openPrivacyPolicyUrl() }
                )
            )
            highlightColor = ContextCompat.getColor(context, R.color.transparent)
            movementMethod = LinkMovementMethod.getInstance()
            text = context.getXmlStyledString(termAndConditionsString)
        }
    }

    private fun onAddAccountClick() {
        nav(actionAddAccountFragmentToLoginNavigation())
    }

    private fun startAnimateBackground() {
        binding.innerCircleImageView.rotateContinuously(true, INNER_CIRCLE_ANIM_DURATION)
        binding.middleCircleImageView.rotateContinuously(false, MIDDLE_CIRCLE_ANIM_DURATION)
        binding.outerCircleImageView.rotateContinuously(false, OUTER_CIRCLE_ANIM_DURATION)
    }

    companion object {
        private const val INNER_CIRCLE_ANIM_DURATION = 3_000L
        private const val MIDDLE_CIRCLE_ANIM_DURATION = 3_500L
        private const val OUTER_CIRCLE_ANIM_DURATION = 4_150L
    }
}
