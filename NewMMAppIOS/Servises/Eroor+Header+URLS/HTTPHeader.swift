//
//  HTTPHeader.swift
//  MMApp
//
//  Created by artem on 24.01.2025.
//

import Foundation

public enum HTTPHeader {
    static let authorization = "Authorization"
    static let contentType = "Content-Type"
    static let accept = "Accept"
    static let cookie = "Cookie"
    static let nuum = "X-Nuum-Access"
    static let wudid = "wudid"
    static let userAent = "User-Agent"

    /// Captcha
    static let captchaToken = "x-captcha-passed-token"
    public static let captchaVersion = "g-recaptcha-version"
    static let googleCaptchaToken = "g-recaptcha-response"

    /// Yandex Captcha
    static let yandexCaptchaToken = "ya-captcha-token"
}

public enum HTTPHeaderValue {
    static let appJson = "application/json"
    static let appJsonTextPlain = "application/json, text/plain"
    static let multipartFormData = "multipart/form-data; boundary="

    static let auth = "SMART_CAPTCHA"
}
