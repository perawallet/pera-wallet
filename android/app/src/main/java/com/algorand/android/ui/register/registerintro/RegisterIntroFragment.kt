package com.algorand.android.ui.register.registerintro

import android.content.SharedPreferences
import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.LayoutInflater
import android.view.View
import androidx.core.content.ContextCompat
import com.algorand.android.LoginNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentRegisterTypeSelectionBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.RegisterFlowType
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.register.registerintro.RegisterIntroFragmentDirections.Companion.actionRegisterIntroFragmentToAddAccountTypeSelectionFragment
import com.algorand.android.ui.register.registerintro.RegisterIntroFragmentDirections.Companion.actionRegisterIntroFragmentToRegisterInfoFragment
import com.algorand.android.ui.registerinfo.RegisterInfoFragment
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.openPrivacyPolicyUrl
import com.algorand.android.utils.openTermsAndServicesUrl
import com.algorand.android.utils.preference.setRegisterSkip
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class RegisterIntroFragment : DaggerBaseFragment(R.layout.fragment_register_type_selection) {

    @Inject
    lateinit var accountManager: AccountManager

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val binding by viewBinding(FragmentRegisterTypeSelectionBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiaryBackground)

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack,
        backgroundColor = R.color.tertiaryBackground
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        statusBarConfiguration = statusBarConfiguration
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureToolbar()
        binding.addAccountSelectionItem.setOnClickListener { onRegisterTypeSelected(RegisterFlowType.ADD_ACCOUNT) }
        binding.recoverSelectionItem.setOnClickListener { onRegisterTypeSelected(RegisterFlowType.RECOVER) }
        setupPolicyText()
    }

    private fun onRegisterTypeSelected(registerFlowType: RegisterFlowType) {
        when (registerFlowType) {
            RegisterFlowType.ADD_ACCOUNT -> {
                nav(actionRegisterIntroFragmentToAddAccountTypeSelectionFragment())
            }
            RegisterFlowType.RECOVER -> {
                nav(actionRegisterIntroFragmentToRegisterInfoFragment(RegisterInfoFragment.Type.RECOVERY))
            }
        }
    }

    private fun configureToolbar() {
        if (accountManager.accounts.value.isEmpty()) {
            getAppToolbar()?.apply {
                val skipButton = LayoutInflater
                    .from(context)
                    .inflate(R.layout.custom_text_tab_button, this, false) as MaterialButton

                skipButton.apply {
                    setTextColor(ContextCompat.getColor(context, R.color.colorPrimary))
                    setText(R.string.skip)
                    setOnClickListener { onSkipClick() }
                    addViewToEndSide(this)
                }
            }
        }
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

    private fun onSkipClick() {
        sharedPref.setRegisterSkip()
        nav(LoginNavigationDirections.actionGlobalToHomeNavigation())
    }
}
