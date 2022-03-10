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

//
//  algorand_tests.swift

import XCTest
import CoreData

@testable import pera_staging

class DBDecodeTests: XCTestCase {

    func testApplicationConfiguration() {
        let user = setupUserData(isUserUpdated: false)
        XCTAssertNotNil(user)
    }

    func testModifiedUser() {
        let user = setupUserData(isUserUpdated: true)
        XCTAssertNotNil(user)
    }
}

extension DBDecodeTests {
    var userBase64: String {
        """
            eyJhY2NvdW50cyI6W3sicmVjZWl2ZXNOb3RpZmljYXRpb24iOnRydWUsIm5hbWUiOiJDaGFzZSIsInR5cGUiOiJzdGFuZGFyZCIsImFkZHJlc3MiOiJUNEVXQkRXUEV
            YTkxFSUxLTEQ3NFJCTE80SEZFR1k1MjJFTEhXNkpJR0NOUlg1VElTVUhDVVU2UVJNIn0seyJyZWNlaXZlc05vdGlmaWNhdGlvbiI6ZmFsc2UsIm5hbWUiOiJDbG9zZ
            SIsInR5cGUiOiJzdGFuZGFyZCIsImFkZHJlc3MiOiJGUENDWUxNMlBCTEZTM1RKRk9OM1lGMlJHVlBGNVlYSUZJUldJQ0Y2QVJSV1FCSTdHWEtIUDI1NzJJIn0seyJy
            ZWNlaXZlc05vdGlmaWNhdGlvbiI6dHJ1ZSwibmFtZSI6IlZlbnVlIiwidHlwZSI6InN0YW5kYXJkIiwiYWRkcmVzcyI6IlgyWUhRVTdXNk9KRzY2VE1MTDNQWjdKUVM
            yRDQyWUVHQVRCQk5EWEgyMlE2SlNOT0ZSNkxWWllYWE0ifV0sImRldmljZUlkIjoiMzM2ODk5OTc3MTQxMzI0MTM2MiIsImRlZmF1bHROb2RlIjoidGVzdG5ldCJ9
        """
    }

    var latestUserBase64: String {
        """
            ewogICJhY2NvdW50cyI6IFsKICAgIHsKICAgICAgImFkZHJlc3MiOiAiVDRFV0JEV1BFWE5MRUlMS0xENzRSQkxPNEhGRUdZNTIyRUxIVzZKSUdDTlJYNVRJU1VIQ1V
            VNlFSTSIsCiAgICAgICJyZWNlaXZlc05vdGlmaWNhdGlvbiI6IHRydWUsCiAgICAgICJuYW1lIjogIkNoYXNlIiwKICAgICAgInR5cGUiOiAic3RhbmRhcmQiCiAgIC
            B9LAogICAgewogICAgICAiYWRkcmVzcyI6ICJGUENDWUxNMlBCTEZTM1RKRk9OM1lGMlJHVlBGNVlYSUZJUldJQ0Y2QVJSV1FCSTdHWEtIUDI1NzJJIiwKICAgICAgI
            nJlY2VpdmVzTm90aWZpY2F0aW9uIjogZmFsc2UsCiAgICAgICJuYW1lIjogIkNsb3NlIiwKICAgICAgInR5cGUiOiAic3RhbmRhcmQiCiAgICB9LAogICAgewogICAg
            ICAiYWRkcmVzcyI6ICJYMllIUVU3VzZPSkc2NlRNTEwzUFo3SlFTMkQ0MllFR0FUQkJORFhIMjJRNkpTTk9GUjZMVlpZWFhNIiwKICAgICAgInJlY2VpdmVzTm90aWZ
            pY2F0aW9uIjogdHJ1ZSwKICAgICAgIm5hbWUiOiAiVmVudWUiLAogICAgICAidHlwZSI6ICJzdGFuZGFyZCIKICAgIH0sCiAgICB7CiAgICAgICJhZGRyZXNzIjogIj
            Y0RzRGU0hWWEozTk5VRFpIWE9MTU5VUTIyWU1VSE80N0wzVVRJTVhBRFhEQ05LTkZUTDUyMjJJNEEiLAogICAgICAicmVjZWl2ZXNOb3RpZmljYXRpb24iOiB0cnVl
            LAogICAgICAibmFtZSI6ICJSZWtleWVkIE5hbWUiLAogICAgICAidHlwZSI6ICJyZWtleWVkIiwKICAgICAgInJla2V5RGV0YWlsIiA6IHsKICAgICAgICAiT0E1VzN
            SWjRGTUJKM0dEQ1pQRTNDV09QU1hXRlVQNEpET0lNU09PSlpKWjdBSURXV1ZKWjJZNzdCNCIgOiB7CiAgICAgICAgICAiaWQiIDogIjI4Njc3MTRFLUZGRDYtMjI4NS
            00OTBDLTdFN0I3MTJCMDU2NSIsCiAgICAgICAgICAibmFtZSIgOiAiXGJOYW5vIFggODY5NiIsCiAgICAgICAgICAiaW5kZXgiIDogMAogICAgICAgIH0KICAgICAgf
            QogICAgfQogIF0sCiAgImRlZmF1bHROb2RlIjogInRlc3RuZXQiLAogICJkZXZpY2VJZCI6ICIzMzY4OTk5NzcxNDEzMjQxMzYyIgp9Cg==
        """
    }

    private func setupUserData(isUserUpdated: Bool) -> User? {
        guard let userData = Data(base64Encoded: isUserUpdated ? latestUserBase64 : userBase64, options: .ignoreUnknownCharacters) else {
            return nil
        }

        return try? JSONDecoder().decode(User.self, from: userData)
    }
}
