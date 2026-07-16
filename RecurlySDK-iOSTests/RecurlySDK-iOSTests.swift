//
//  RecurlySDK-iOSTests.swift
//  RecurlySDK-iOSTests
//
//  Created by George Andrew Shoemaker on 8/20/22.
//

import XCTest
import Combine
@testable import RecurlySDK_iOS

class RecurlySDK_iOSTests: XCTestCase {
    
    // If you are running these tests in Xcode
    // you should set your public key here.
    // Otherwise PUBLIC_KEY should be set from the command line
    let publicKey = getEnviornmentVar("PUBLIC_KEY") ?? ""
    
    let paymentHandler = REApplePaymentHandler()

    override func tearDown() {
        // Prevent state from a stubbed MockURLProtocol.requestHandler leaking into
        // the next test (XCTest execution order is not guaranteed).
        MockURLProtocol.requestHandler = nil
        // Prevent REConfiguration.shared.apiPublicKey (global static) from leaking
        // between tests — e.g. EU-routing tests set a "fra-" key that must not
        // bleed into other TokenizationAPI assertions (XCTest order is not guaranteed).
        REConfiguration.shared.apiPublicKey = ""
        super.tearDown()
    }
    
    // This utility function will setup the TokenizationManager
    // with valid billingInfo and cardData
    private func setupTokenizationManager() {
        RETokenizationManager.shared.setBillingInfo(
            billingInfo: REBillingInfo(
                firstName: "David",
                lastName: "Figueroa",
                address1: "123 Main St",
                address2: "",
                company: "CH2",
                country: "USA",
                city: "Miami",
                state: "Florida",
                postalCode: "33101",
                phone: "555-555-5555",
                vatNumber: ""
            )
        )
        RETokenizationManager.shared.cardData.number = "4111111111111111"
        RETokenizationManager.shared.cardData.month = "12"
        RETokenizationManager.shared.cardData.year = "2030"
        RETokenizationManager.shared.cardData.cvv = "123"
    }
    
    func testPublicKeyIsValid() throws {
        
        try XCTSkipIf(publicKey.isEmpty, "PUBLIC_KEY not set")
        
        REConfiguration.shared.initialize(publicKey: publicKey)
        setupTokenizationManager()

        let tokenResponseExpectation = expectation(description: "TokenResponse")
        RETokenizationManager.shared.getTokenId { tokenId, errorResponse in
            if
                let errorMessage = errorResponse?.error.message,
                errorMessage == "Public key not found"
            {
                XCTFail(errorMessage + " : Is your public key valid?")
                return
            }

            if let errorResponse = errorResponse {
                XCTFail(errorResponse.error.message ?? "Something went wrong. No error message arrived with error.")
                return
            }

            XCTAssertFalse(tokenId?.isEmpty ?? true, "tokenID was unexpectedly empty.")
            tokenResponseExpectation.fulfill()
        }
        wait(for: [tokenResponseExpectation], timeout: 5.0)
    }

    func testTokenization() throws {
        try XCTSkipIf(publicKey.isEmpty, "PUBLIC_KEY not set")
        
        //Initialize the SDK
        REConfiguration.shared.initialize(publicKey: publicKey)
        setupTokenizationManager()

        let tokenResponseExpectation = expectation(description: "TokenResponse")
        RETokenizationManager.shared.getTokenId { tokenId, error in
            if let errorResponse = error {
                XCTFail(errorResponse.error.message ?? "")
                return
            }
            XCTAssertNotNil(tokenId)
            XCTAssertGreaterThan((tokenId?.count ?? 0), 5)
            tokenResponseExpectation.fulfill()
        }
        wait(for: [tokenResponseExpectation], timeout: 5.0)
    }

    func testApplePayIsSupported() {
        XCTAssertTrue(paymentHandler.applePaySupported(), "Apple Pay is not supported")
    }

    func testApplePayTokenization() throws {
        throw XCTSkip("Apple Pay not supported on CI account")

        paymentHandler.isTesting = true

        let items = [
            REApplePayItem(amountLabel: "Foo", amount: 3.80),
            REApplePayItem(amountLabel: "Bar", amount: 0.99),
            REApplePayItem(amountLabel: "Tax", amount: 1.53)
        ]
        var applePayInfo = REApplePayInfo(purchaseItems: items)
        applePayInfo.requiredContactFields = []
        applePayInfo.merchantIdentifier = "merchant.com.recurly.recurlySDK-iOS"
        applePayInfo.countryCode = "US"
        applePayInfo.currencyCode = "USD"

        let tokenResponseExpectation = expectation(description: "ApplePayTokenResponse")
        paymentHandler.startApplePayment(with: applePayInfo) { (success, token, nil) in
            XCTAssertTrue(success, "Apple Pay is not ready")
            tokenResponseExpectation.fulfill()
        }
        wait(for: [tokenResponseExpectation], timeout: 3.0)
    }

    func testCardBrandValidator() throws {

        //Test VISA
        var ccValidator = CreditCardValidator("4111111111111111")
        XCTAssertTrue(ccValidator.type == .visa)

        //Test American Express
        ccValidator = CreditCardValidator("377813011144444")
        XCTAssertTrue(ccValidator.type == .amex)

        //Test Mastercard
        ccValidator = CreditCardValidator("5555555555554444")
        XCTAssertTrue(ccValidator.type == .masterCard)

        //Test Diners Club
        ccValidator = CreditCardValidator("36227206271667")
        XCTAssertTrue(ccValidator.type == .dinersClub)
    }

    func testValidCreditCard() throws {

        //Test Valid AE
        let ccValidator = CreditCardValidator("374245455400126")
        XCTAssertTrue(ccValidator.isValid)

        //Test Fake Card
        XCTAssertFalse(CreditCardValidator("3778111111111").isValid)
    }

    func testRecurlyErrorResponse() throws {
        try XCTSkipIf(publicKey.isEmpty, "PUBLIC_KEY not set")
        
        //Initialize the SDK
        REConfiguration.shared.initialize(publicKey: publicKey)
        setupTokenizationManager()

        // Purposefully set this to empty as if it were missing
        RETokenizationManager.shared.cardData.month = ""

        let tokenResponseExpectation = expectation(description: "TokenErrorResponse")
        RETokenizationManager.shared.getTokenId { tokenId, error in
            if let errorResponse = error {
                XCTAssertTrue(errorResponse.error.code == "invalid-parameter")
                tokenResponseExpectation.fulfill()
            }
        }
        wait(for: [tokenResponseExpectation], timeout: 5.0)
    }


    // MARK: - Offline coverage (Phase 1)
    //
    // These tests run without PUBLIC_KEY / network access, exercising the real
    // NetworkEngine -> REAPIClient -> RETokenizationManager chain against a
    // MockURLProtocol-stubbed URLSession. They run on every PR, including forks.
    //
    // NOTE: two branches are intentionally NOT covered here:
    // - NetworkEngine.sendRequest's "nil data" guard: URLSession's documented
    //   contract only surfaces nil data paired with a non-nil error, so this
    //   branch is not reliably reachable via URLProtocol stubbing.
    // - NetworkEngine.createPOSTRequest(requestBodyObject:) returning nil on
    //   JSONSerialization failure: forcing JSONSerialization.data(withJSONObject:)
    //   to fail (e.g. via NaN) can raise an uncatchable Objective-C exception
    //   instead of a Swift error, which would crash the whole CI test run.
    //   Not worth the risk without local Xcode to verify first.

    // MARK: NetworkEngine

    func testNetworkEngine_sendRequest_success() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let responseJSON = "{\"id\":\"tok-123\",\"type\":\"credit_card\"}".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 200, httpVersion: nil, headerFields: nil), responseJSON, nil)
        }

        let engine = NetworkEngine(session: MockURLProtocol.makeSession())
        let expectation = expectation(description: "success")
        engine.sendRequest(responseModel: RETokenResponse.self, request: URLRequest(url: url)) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.id, "tok-123")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("unexpected failure: \(String(describing: error.error.message))")
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testNetworkEngine_sendRequest_recurlyErrorBody() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let errorJSON = "{\"error\":{\"code\":\"invalid-parameter\",\"message\":\"boom\",\"details\":[]}}".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 200, httpVersion: nil, headerFields: nil), errorJSON, nil)
        }

        let engine = NetworkEngine(session: MockURLProtocol.makeSession())
        let expectation = expectation(description: "recurlyErrorBody")
        engine.sendRequest(responseModel: RETokenResponse.self, request: URLRequest(url: url)) { result in
            switch result {
            case .success:
                XCTFail("expected failure")
            case .failure(let error):
                XCTAssertEqual(error.error.code, "invalid-parameter")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testNetworkEngine_sendRequest_transportError() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        MockURLProtocol.requestHandler = { _ in
            (nil, nil, URLError(.notConnectedToInternet))
        }

        let engine = NetworkEngine(session: MockURLProtocol.makeSession())
        let expectation = expectation(description: "transportError")
        engine.sendRequest(responseModel: RETokenResponse.self, request: URLRequest(url: url)) { result in
            switch result {
            case .success:
                XCTFail("expected failure")
            case .failure(let error):
                XCTAssertEqual(error.error.code, "network-error")
                expectation.fulfill()
            }
        }
        // NOTE: bumped from 1.0s -> 10.0s as a diagnostic experiment. URLProtocol's
        // didFailWithError delivery timed out at 1s in CI on two prior attempts (with
        // both a custom Error type and a URLError), despite the mock matching the
        // documented contract and WeTransfer's Mocker reference implementation exactly.
        // This determines whether delivery is merely slow in the CI simulator or
        // never happens at all.
        wait(for: [expectation], timeout: 10.0)
    }

    func testNetworkEngine_sendRequest_nonSuccessStatusCode() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let body = "{}".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 500, httpVersion: nil, headerFields: nil), body, nil)
        }

        let engine = NetworkEngine(session: MockURLProtocol.makeSession())
        let expectation = expectation(description: "nonSuccessStatusCode")
        engine.sendRequest(responseModel: RETokenResponse.self, request: URLRequest(url: url)) { result in
            switch result {
            case .success:
                XCTFail("expected failure")
            case .failure(let error):
                XCTAssertEqual(error.error.code, "http-500")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testNetworkEngine_sendRequest_undecodableSuccessBody_returnsSdkInternal() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let garbage = "not json".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 200, httpVersion: nil, headerFields: nil), garbage, nil)
        }

        let engine = NetworkEngine(session: MockURLProtocol.makeSession())
        let expectation = expectation(description: "undecodableSuccessBody")
        engine.sendRequest(responseModel: RETokenResponse.self, request: URLRequest(url: url)) { result in
            switch result {
            case .success:
                XCTFail("expected failure")
            case .failure(let error):
                XCTAssertEqual(error.error.code, "sdk-internal")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testNetworkEngine_createPOSTRequest_setsTimeoutIntervalTo30() {
        let engine = NetworkEngine()
        let request = engine.createPOSTRequest(requestType: .getTokenID, requestBodyObject: ["key": "value"])
        XCTAssertEqual(request?.timeoutInterval, 30)
    }

    // MARK: REAPIClient

    func testREAPIClient_getTokenID_buildFailure_returnsFailPublisher() {
        struct UnencodableFixture: Codable {
            let value: Double
        }

        let apiClient = REAPIClient(networkEngine: NetworkEngine(session: MockURLProtocol.makeSession()))
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "buildFailure")

        apiClient.getTokenID(with: UnencodableFixture(value: .infinity), requestType: .getTokenID)
            .sink(receiveCompletion: { completion in
                if case .failure(let error as REBaseErrorResponse) = completion {
                    XCTAssertEqual(error.error.code, "sdk-internal")
                    expectation.fulfill()
                } else {
                    XCTFail("expected sdk-internal failure")
                }
            }, receiveValue: { _ in
                XCTFail("expected no value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testREAPIClient_getTokenID_missingId_returnsSdkInternal() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let responseJSON = "{\"type\":\"credit_card\"}".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 200, httpVersion: nil, headerFields: nil), responseJSON, nil)
        }

        let apiClient = REAPIClient(networkEngine: NetworkEngine(session: MockURLProtocol.makeSession()))
        let request = RETokenRequest(
            cardData: RECardData(),
            billingInfo: REBillingInfo(),
            version: "1.0",
            key: "key",
            deviceId: "device",
            sessionId: "session"
        )

        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "missingId")

        apiClient.getTokenID(with: request, requestType: .getTokenID)
            .sink(receiveCompletion: { completion in
                if case .failure(let error as REBaseErrorResponse) = completion {
                    XCTAssertEqual(error.error.code, "sdk-internal")
                    expectation.fulfill()
                } else {
                    XCTFail("expected sdk-internal failure")
                }
            }, receiveValue: { _ in
                XCTFail("expected no value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: RETokenizationManager

    func testRETokenizationManager_emptyCVV_doesNotHitNetwork() {
        MockURLProtocol.requestHandler = { _ in
            XCTFail("network should not be called when cvv is empty")
            return (nil, nil, nil)
        }

        var manager = RETokenizationManager(apiClient: REAPIClient(networkEngine: NetworkEngine(session: MockURLProtocol.makeSession())))
        manager.cardData.cvv = ""

        let expectation = expectation(description: "emptyCvv")
        manager.getTokenId { tokenId, error in
            XCTAssertNil(tokenId)
            XCTAssertEqual(error?.error.code, "validation")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getTokenId_success() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let responseJSON = "{\"id\":\"tok-abc\",\"type\":\"credit_card\"}".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 200, httpVersion: nil, headerFields: nil), responseJSON, nil)
        }

        var manager = RETokenizationManager(apiClient: REAPIClient(networkEngine: NetworkEngine(session: MockURLProtocol.makeSession())))
        manager.cardData.number = "4111111111111111"
        manager.cardData.month = "12"
        manager.cardData.year = "2030"
        manager.cardData.cvv = "123"

        let expectation = expectation(description: "tokenSuccess")
        manager.getTokenId { tokenId, error in
            XCTAssertNil(error)
            XCTAssertEqual(tokenId, "tok-abc")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getTokenId_failureMapped() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let errorJSON = "{\"error\":{\"code\":\"invalid-parameter\",\"message\":\"bad card\",\"details\":[]}}".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 200, httpVersion: nil, headerFields: nil), errorJSON, nil)
        }

        var manager = RETokenizationManager(apiClient: REAPIClient(networkEngine: NetworkEngine(session: MockURLProtocol.makeSession())))
        manager.cardData.cvv = "123"

        let expectation = expectation(description: "tokenFailure")
        manager.getTokenId { tokenId, error in
            XCTAssertNil(tokenId)
            XCTAssertEqual(error?.error.code, "invalid-parameter")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }


    func testRETokenizationManager_getApplePayTokenId_success() {
        let url = URL(string: "https://api.recurly.com/js/v1/apple_pay/token")!
        let responseJSON = "{\"id\":\"tok-apple-abc\",\"type\":\"credit_card\"}".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 200, httpVersion: nil, headerFields: nil), responseJSON, nil)
        }

        var manager = RETokenizationManager(apiClient: REAPIClient(networkEngine: NetworkEngine(session: MockURLProtocol.makeSession())))

        let expectation = expectation(description: "applePayTokenSuccess")
        manager.getApplePayTokenId { tokenId, error in
            XCTAssertNil(error)
            XCTAssertEqual(tokenId, "tok-apple-abc")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getApplePayTokenId_failureMapped() {
        let url = URL(string: "https://api.recurly.com/js/v1/apple_pay/token")!
        let errorJSON = "{\"error\":{\"code\":\"invalid-parameter\",\"message\":\"bad apple pay token\",\"details\":[]}}".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 200, httpVersion: nil, headerFields: nil), errorJSON, nil)
        }

        var manager = RETokenizationManager(apiClient: REAPIClient(networkEngine: NetworkEngine(session: MockURLProtocol.makeSession())))

        let expectation = expectation(description: "applePayTokenFailure")
        manager.getApplePayTokenId { tokenId, error in
            XCTAssertNil(tokenId)
            XCTAssertEqual(error?.error.code, "invalid-parameter")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // Note: getApplePayTokenId's `case .failure(let error):` non-REBaseErrorResponse
    // fallback (mirrors getTokenId's) is unreachable through the current public API —
    // REAPIClient.getTokenID only ever fails its publisher with REBaseErrorResponse
    // (both the build-failure Fail(error:) and NetworkEngine.sendRequest's completion
    // wrap RETokenError in REBaseErrorResponse). Exercising that branch would require
    // a fake APIClient conforming to a protocol, which Phase 1 deliberately defers to
    // the 3.0 developer-first work (see decision/recurly-client-ios-phase-1-plan).

    // MARK: Model coding

    func testRETokenResponse_decoding() throws {
        let json = "{\"id\":\"tok-1\",\"type\":\"credit_card\"}".data(using: .utf8)!
        let response = try JSONDecoder().decode(RETokenResponse.self, from: json)
        XCTAssertEqual(response.id, "tok-1")
        XCTAssertEqual(response.type, "credit_card")
    }

    func testREBaseErrorResponse_decoding() throws {
        let json = "{\"error\":{\"code\":\"invalid-parameter\",\"message\":\"bad input\",\"details\":[]}}".data(using: .utf8)!
        let response = try JSONDecoder().decode(REBaseErrorResponse.self, from: json)
        XCTAssertEqual(response.error.code, "invalid-parameter")
        XCTAssertEqual(response.error.message, "bad input")
    }

    func testRETokenRequest_encoding_flattensFieldsAndSnakeCasesBillingInfo() throws {
        var billingInfo = REBillingInfo()
        billingInfo.firstName = "Jane"
        billingInfo.lastName = "Doe"

        let request = RETokenRequest(
            cardData: RECardData(),
            billingInfo: billingInfo,
            version: "1.0.0",
            key: "test-key",
            deviceId: "device-123",
            sessionId: "session-456"
        )

        let data = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        // cardData + billingInfo fields flattened into the same top-level object
        XCTAssertEqual(json["number"] as? String, "")
        XCTAssertEqual(json["first_name"] as? String, "Jane")
        XCTAssertEqual(json["last_name"] as? String, "Doe")
        // scalar fields use default camelCase (no CodingKeys override)
        XCTAssertEqual(json["version"] as? String, "1.0.0")
        XCTAssertEqual(json["key"] as? String, "test-key")
        XCTAssertEqual(json["deviceId"] as? String, "device-123")
        XCTAssertEqual(json["sessionId"] as? String, "session-456")
    }

    // MARK: CreditCardValidator

    func testCreditCardValidator_additionalBrandDetection() {
        XCTAssertEqual(CreditCardValidator("6011000000000004").type, .discover)
        XCTAssertEqual(CreditCardValidator("3528000000000007").type, .jcb)
        XCTAssertEqual(CreditCardValidator("6759649826438453").type, .maestro)
    }

    func testCreditCardValidator_validNumberLengths() {
        XCTAssertTrue(CreditCardType.visa.validNumberLength.contains(13))
        XCTAssertTrue(CreditCardType.visa.validNumberLength.contains(16))
        XCTAssertFalse(CreditCardType.visa.validNumberLength.contains(15))
        XCTAssertTrue(CreditCardType.amex.validNumberLength.contains(15))
        XCTAssertTrue(CreditCardType.dinersClub.validNumberLength.contains(14))
    }

    func testCreditCardValidator_getCCFrom_groupsDigitsInFours() {
        XCTAssertEqual(CreditCardValidator.getCCFrom(string: "4111111111111111"), "4111 1111 1111 1111")
    }

    func testCreditCardValidator_getExpDateFrom_groupsIntoMonthYearPairs() {
        XCTAssertEqual(CreditCardValidator.getExpDateFrom(string: "1230"), "12/30")
    }

    func testCreditCardValidator_formatCCfrom_groupsFullVisaPattern() {
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: "4111111111111111"), "4111 1111 1111 1111")
    }

    // MARK: TokenizationAPI

    func testTokenizationAPI_getTokenID_pathMethodAbsoluteString() {
        let api = TokenizationAPI.getTokenID
        XCTAssertEqual(api.scheme, "https")
        XCTAssertEqual(api.baseURL, "api.recurly.com/js/v1")
        XCTAssertEqual(api.path, "/tokens")
        XCTAssertEqual(api.method, "POST")
        XCTAssertEqual(api.absoluteString, "https://api.recurly.com/js/v1/tokens")
    }

    func testTokenizationAPI_getApplePayTokenID_path() {
        XCTAssertEqual(TokenizationAPI.getApplePayTokenID.path, "/apple_pay/token")
        XCTAssertEqual(TokenizationAPI.getApplePayTokenID.absoluteString, "https://api.recurly.com/js/v1/apple_pay/token")
    }

    func testTokenizationAPI_euKeyPrefix_routesToEUHost() {
        REConfiguration.shared.apiPublicKey = "fra-test123"
        XCTAssertEqual(TokenizationAPI.getTokenID.baseURL, "api.eu.recurly.com/js/v1")
        XCTAssertEqual(TokenizationAPI.getTokenID.absoluteString, "https://api.eu.recurly.com/js/v1/tokens")
    }

    func testTokenizationAPI_euKeyPrefix_routesApplePayToEUHost() {
        REConfiguration.shared.apiPublicKey = "fra-test123"
        XCTAssertEqual(TokenizationAPI.getApplePayTokenID.absoluteString, "https://api.eu.recurly.com/js/v1/apple_pay/token")
    }

    func testTokenizationAPI_usKey_routesToUSHost() {
        REConfiguration.shared.apiPublicKey = "pub-test123"
        XCTAssertEqual(TokenizationAPI.getTokenID.baseURL, "api.recurly.com/js/v1")
        XCTAssertEqual(TokenizationAPI.getTokenID.absoluteString, "https://api.recurly.com/js/v1/tokens")
    }

    func testTokenizationAPI_emptyKey_defaultsToUSHost() {
        REConfiguration.shared.apiPublicKey = ""
        XCTAssertEqual(TokenizationAPI.getTokenID.baseURL, "api.recurly.com/js/v1")
    }

    // MARK: Extensions

    func testStringRemoveNonNumericChars_stripsNonDigits() {
        XCTAssertEqual("abc123-456".removeNonNumericChars(), "123456")
    }

    func testStringRemoveNonNumericChars_noOpWhenAlreadyClean() {
        XCTAssertEqual("12 30".removeNonNumericChars(), "12 30")
    }

    
}
