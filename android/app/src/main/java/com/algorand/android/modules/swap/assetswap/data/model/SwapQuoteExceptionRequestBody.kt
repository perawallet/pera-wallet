package com.algorand.android.modules.swap.assetswap.data.model

import com.google.gson.annotations.SerializedName

data class SwapQuoteExceptionRequestBody(
    @SerializedName("exception_text")
    val exceptionText: String?
)
