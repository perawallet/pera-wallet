// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwapQuote.swift

import Foundation

final class SwapQuote: ALGEntityModel {
    static let feePadding: UInt64 = 665000 /// 0.665 Algo

    let id: Int64
    let provider: SwapProvider?
    let type: SwapType?
    let swapperAddress: PublicKey?
    let deviceID: Int64?
    let assetIn: AssetDecoration?
    let assetOut: AssetDecoration?
    let amountIn: UInt64?
    let amountInWithSlippage: UInt64?
    let amountInUSDValue: Decimal?
    let amountOut: UInt64?
    let amountOutWithSlippage: UInt64?
    let amountOutUSDValue: Decimal?
    let slippage: Decimal?
    let price: Decimal?
    let priceImpact: Decimal?
    let peraFee: UInt64?
    let exchangeFee: UInt64?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.id
        self.provider = apiModel.provider
        self.type = apiModel.swapType
        self.swapperAddress = apiModel.swapperAddress
        self.deviceID = apiModel.device
        self.assetIn = apiModel.assetIn.unwrap(AssetDecoration.init)
        self.assetOut = apiModel.assetOut.unwrap(AssetDecoration.init)
        self.amountIn = apiModel.amountIn.unwrap { UInt64($0) }
        self.amountInWithSlippage = apiModel.amountInWithSlippage.unwrap { UInt64($0) }
        self.amountInUSDValue = apiModel.amountInUSDValue.unwrap { Decimal(string: $0) }
        self.amountOut = apiModel.amountOut.unwrap { UInt64($0)  }
        self.amountOutWithSlippage = apiModel.amountOutWithSlippage.unwrap { UInt64($0) }
        self.amountOutUSDValue = apiModel.amountOutUSDValue.unwrap { Decimal(string: $0) }
        self.slippage = apiModel.slippage.unwrap { Decimal(string: $0) }
        self.price = apiModel.price.unwrap { Decimal(string: $0) }
        self.priceImpact = apiModel.priceImpact.unwrap { Decimal(string: $0) }
        self.peraFee = UInt64(apiModel.peraFee.unwrap(or: "0"))
        self.exchangeFee = UInt64(apiModel.exchangeFee.unwrap(or: "0"))
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.id = id
        apiModel.provider = provider
        apiModel.swapType = type
        apiModel.swapperAddress = swapperAddress
        apiModel.device = deviceID
        apiModel.assetIn = assetIn?.encode()
        apiModel.assetOut = assetOut?.encode()
        apiModel.amountIn = amountIn.unwrap { String(describing: $0) }
        apiModel.amountInWithSlippage = amountInWithSlippage.unwrap { String(describing: $0) }
        apiModel.amountInUSDValue = amountInUSDValue.unwrap { String(describing: $0) }
        apiModel.amountOut = amountOut.unwrap { String(describing: $0) }
        apiModel.amountOutWithSlippage = amountOutWithSlippage.unwrap { String(describing: $0) }
        apiModel.amountOutUSDValue = amountOutUSDValue.unwrap { String(describing: $0) }
        apiModel.slippage = slippage.unwrap { String(describing: $0) }
        apiModel.price = price.unwrap { String(describing: $0) }
        apiModel.priceImpact = priceImpact.unwrap { String(describing: $0) }
        apiModel.peraFee = peraFee.unwrap { String(describing: $0) }
        apiModel.exchangeFee = exchangeFee.unwrap { String(describing: $0) }
        return apiModel
    }
}

extension SwapQuote {
    struct APIModel: ALGAPIModel {
        var id: Int64
        var provider: SwapProvider?
        var swapType: SwapType?
        var swapperAddress: PublicKey?
        var device: Int64?
        var assetIn: AssetDecoration.APIModel?
        var assetOut: AssetDecoration.APIModel?
        var amountIn: String?
        var amountInWithSlippage: String?
        var amountInUSDValue: String?
        var amountOut: String?
        var amountOutWithSlippage: String?
        var amountOutUSDValue: String?
        var slippage: String?
        var price: String?
        var priceImpact: String?
        var peraFee: String?
        var exchangeFee: String?

        init() {
            self.id = 0
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case id
            case provider
            case swapType = "swap_type"
            case swapperAddress = "swapper_address"
            case device
            case assetIn = "asset_in"
            case assetOut = "asset_out"
            case amountIn = "amount_in"
            case amountInWithSlippage = "amount_in_with_slippage"
            case amountInUSDValue = "amount_in_usd_value"
            case amountOut = "amount_out"
            case amountOutWithSlippage = "amount_out_with_slippage"
            case amountOutUSDValue = "amount_out_usd_value"
            case slippage
            case price
            case priceImpact = "price_impact"
            case peraFee = "pera_fee_amount"
            case exchangeFee = "exchange_fee_amount"
        }
    }
}
