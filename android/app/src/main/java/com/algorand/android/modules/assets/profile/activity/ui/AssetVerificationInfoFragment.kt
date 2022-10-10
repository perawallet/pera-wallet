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

package com.algorand.android.modules.assets.profile.activity.ui

import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAssetVerificationInfoBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.utils.browser.openASAVerificationUrl
import com.algorand.android.utils.setXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding

class AssetVerificationInfoFragment : BaseFragment(R.layout.fragment_asset_verification_info) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentAssetVerificationInfoBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        with(binding) {
            closeButton.setOnClickListener { navBack() }
            firstDescriptionTextView.setXmlStyledString(R.string.pera_wallet_s_algorand)
            secondDescriptionTextView.setXmlStyledString(R.string.the_main_purpose)
            thirdDescriptionTextView.setXmlStyledString(R.string.asa_verification_is)
            learnMoreButton.setOnClickListener { context?.openASAVerificationUrl() }
        }
    }
}
