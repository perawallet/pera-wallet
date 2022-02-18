package com.algorand.android.ui.register.registerintro

import android.os.Bundle
import android.text.method.LinkMovementMethod
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.LoginNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentRegisterTypeSelectionBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.RegisterFlowType
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.openPrivacyPolicyUrl
import com.algorand.android.utils.openTermsAndServicesUrl
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RegisterIntroFragment : DaggerBaseFragment(R.layout.fragment_register_type_selection) {

    private val registerIntroViewModel: RegisterIntroViewModel by viewModels()

    private val binding by viewBinding(FragmentRegisterTypeSelectionBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiaryBackground)

    private val toolbarConfiguration = ToolbarConfiguration(
        backgroundColor = R.color.primaryBackground
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        statusBarConfiguration = statusBarConfiguration
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureToolbar()
        initUi()
    }

    private fun initUi() {
        with(binding) {
            addAccountSelectionItem.setOnClickListener { onRegisterTypeSelected(RegisterFlowType.ADD_ACCOUNT) }
            recoverSelectionItem.setOnClickListener { onRegisterTypeSelected(RegisterFlowType.RECOVER) }
        }
        setupPolicyText()
    }

    private fun onRegisterTypeSelected(registerFlowType: RegisterFlowType) {
        when (registerFlowType) {
            RegisterFlowType.ADD_ACCOUNT -> {
                nav(RegisterIntroFragmentDirections.actionRegisterIntroFragmentToAddAccountTypeSelectionFragment())
            }
            RegisterFlowType.RECOVER -> {
                nav(RegisterIntroFragmentDirections.actionRegisterIntroFragmentToRecoverAccountInfoFragment())
            }
        }
    }

    private fun configureToolbar() {
        getAppToolbar()?.let {
            with(registerIntroViewModel) {
                if (getIsShowingCloseButton()) {
                    it.configureStartButton(getStartIconResId(), ::navBack)
                } else {
                    it.addButtonToEnd(TextButton(R.string.skip, onClick = ::onSkipClick))
                }
            }
        }
    }

    private fun setupPolicyText() {
        binding.policyTextView.apply {
            val linkTextColor = ContextCompat.getColor(context, R.color.linkPrimary)
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
        registerIntroViewModel.setRegisterSkip()
        nav(LoginNavigationDirections.actionGlobalToHomeNavigation())
    }
}
