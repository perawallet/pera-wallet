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

package com.algorand.android

import com.algorand.android.discover.utils.regexPatternPeraURL
import org.junit.Test

class PeraUrlRegexTest {
    /**
     *
     * """^https://([\da-z-]+\.)*(?<!web\.)perawallet\.app((?:/.*)?|(?:\?.*)?|(?:#.*)?)"""
     *
     * ^ - String start
     *
     * https:// - https:// is mandatory
     *
     * [\da-z.-]+\. - a group of one or more characters that are either \d (a number), a letter a-z, or a -,
     * followed by a .
     *
     * (...)* - the above repeated zero or more times
     *
     * (?<!web\.) - at this point, this is a look-before. if the last set of the above pattern is "web."
     * then we do not accept the string. This prevents any url in the form of *.web.perawallet.app but
     * won't block things like *.web.discover.perawallet.app
     *
     * perawallet\.app - our base url
     * ((?:/.*)?|(?:\?.*)?|(?:#.*)?) - at this point we accept any url that continues with a /, a ? or a # character
     * after our domain. This is to prevent things like perawallet.app.attacker.com but still allow any subdirectory
     * or query param. Once we've reached an URL that matches this pattern, after one of the above 3 characters,
     * we don't care much about what comes as we are certain we're in our own domain. An url can end with the
     * perawallet.app part, with or without trailing slash.
     **/
    @Test
    fun `Check if pera url regex works for valid URLs`() {
        val validPeraUrls = listOf(
            "https://perawallet.app/",
            "https://perawallet.app",
            "https://perawallet.app/?a=1&b=2",
            "https://perawallet.app/test/a/",
            "https://perawallet.app/test/?a=1&b=2",
            "https://governance.perawallet.app",
            "https://staging.governance.perawallet.app",
            "https://discover-mobile.perawallet.app",
            "https://discover-mobile.test.perawallet.app",
            "https://web.discover.perawallet.app",
            "https://discover-mobile.-test.perawallet.app",
            "https://discover-mobile-.test.perawallet.app",
            "https://test.perawallet.app?a=5",
            "https://test.perawallet.app#test"
        )
        assert(validPeraUrls.all { it.matches(regexPatternPeraURL) })
    }

    @Test
    fun `Check if pera url regex works for invalid URLs`() {
        val invalidPeraUrls = listOf(
            "https://randomdomain.com",
            "https://perawallet.app.attacker.com/foo/bar/",
            "https://randomdomain.com/perawallet.app/",
            "https://randomdomain.com",
            "http://randomdomain.com",
            "http://perawallet.app",
            "https://staging.....perawallet.app",
            "https://web.perawallet.app",
            "https://test.perawallet.appa=5",
            "https://test.perawallet.apptest",
            "https://discover.web.perawallet.app",
            "randomdomain.com",
            "discover-mobile.perawallet.app",
        )
        assert(invalidPeraUrls.none { it.matches(regexPatternPeraURL) })
    }
}
