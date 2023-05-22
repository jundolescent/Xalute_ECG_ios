/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */


/*
 * Key definition - Do not modify without notice.
 * 1. serverAddress : 서버 주소
 * 2. userName      : 사용자 이름
 * 3. birthDate     : 생년월일
 */

import Foundation

class UserDefaultsProvider {
    private static let defaults = UserDefaults(suiteName: "os.korea.xalute")!

    public static func setValueInUserDefaults(key: String, value: String) {
        self.defaults.set(value as String, forKey: key)
    }

    public static func getValueFromUserDefaults(key: String) -> String? {
        let value = defaults.string(forKey: key)
        return value
    }
}
