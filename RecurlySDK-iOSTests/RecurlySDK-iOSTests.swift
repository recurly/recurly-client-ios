//
//  RecurlySDK-iOSTests.swift
//  RecurlySDK-iOSTests
//

import XCTest
import Combine
import PassKit
@testable import RecurlySDK

@MainActor
class RecurlySDK_iOSTests: XCTestCase {
    
    // If you are running these tests in Xcode
    // you should set your public key here.
    // Otherwise PUBLIC_KEY should be set from the command line
    let publicKey = getEnviornmentVar("PUBLIC_KEY") ?? ""
    
    let paymentHandler = RecurlyApplePaymentHandler()

    override func tearDown() {
        // Prevent state from a stubbed MockURLProtocol.requestHandler leaking into
        // the next test (XCTest execution order is not guaranteed).
        MockURLProtocol.requestHandler = nil
        // Prevent RecurlyConfiguration.shared.apiPublicKey (global static) from leaking
        // between tests — e.g. EU-routing tests set a "fra-" key that must not
        // bleed into other TokenizationAPI assertions (XCTest order is not guaranteed).
        RecurlyConfiguration.shared.apiPublicKey = ""
        super.tearDown()
    }

    private var testBillingInfo: RecurlyBillingInfo {
        RecurlyBillingInfo(
            firstName: "Jane",
            lastName: "Doe",
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
    }

    private func makeTestSession(number: String = "4111111111111111", expDate: String = "1230", cvv: String = "123") -> RecurlyCardSession {
        let session = RecurlyCardSession()
        session.number = number
        session.expDate = expDate
        session.cvv = cvv
        return session
    }
    
    func testPublicKeyIsValid() throws {
        
        try XCTSkipIf(publicKey.isEmpty, "PUBLIC_KEY not set")
        
        RecurlyConfiguration.shared.initialize(publicKey: publicKey)
        let session = makeTestSession()

        let tokenResponseExpectation = expectation(description: "TokenResponse")
        RecurlyTokenizationManager.shared.getTokenId(session: session, billingInfo: testBillingInfo) { tokenId, errorResponse in
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
        RecurlyConfiguration.shared.initialize(publicKey: publicKey)
        let session = makeTestSession()

        let tokenResponseExpectation = expectation(description: "TokenResponse")
        RecurlyTokenizationManager.shared.getTokenId(session: session, billingInfo: testBillingInfo) { tokenId, error in
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
            RecurlyApplePayItem(amountLabel: "Foo", amount: 3.80),
            RecurlyApplePayItem(amountLabel: "Bar", amount: 0.99),
            RecurlyApplePayItem(amountLabel: "Tax", amount: 1.53)
        ]
        var applePayInfo = RecurlyApplePayInfo(purchaseItems: items)
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

    func testApplePaymentHandler_didFinish_clearsCapturedTokenAndBillingInfo() {
        let handler = RecurlyApplePaymentHandler()
        handler.currentBillingInfo = PKContact()
        handler.paymentStatus = .success

        let clearedExpectation = expectation(description: "state cleared after didFinish")
        handler.completionHandler = { _, _, _ in
            // The clear happens on the main queue right after this callback returns, in
            // the same `didFinish` block. Enqueuing here (rather than sleeping a fixed
            // duration) guarantees this runs after the clear, since both share the
            // main queue's FIFO order.
            DispatchQueue.main.async {
                XCTAssertNil(handler.currentBillingInfo, "billing info must not outlive the completion callback")
                XCTAssertNil(handler.currentToken, "token must not outlive the completion callback")
                XCTAssertEqual(handler.paymentStatus, .failure, "status must reset so a reused handler can't replay a stale success")
                clearedExpectation.fulfill()
            }
        }

        let controller = PKPaymentAuthorizationController(paymentRequest: PKPaymentRequest())
        handler.paymentAuthorizationControllerDidFinish(controller)

        wait(for: [clearedExpectation], timeout: 2.0)
    }

    /// Regression guard for a real bug found in review: before `paymentStatus` was reset in
    /// `didFinish`, a handler reused for a second payment that never reached
    /// `didAuthorizePayment` still reported the first payment's `.success`, firing the second
    /// completion handler with `true` and nil token/contact — a false success.
    func testApplePaymentHandler_reusedAfterSuccess_doesNotReportFalseSuccessOnSecondFinish() {
        let handler = RecurlyApplePaymentHandler()
        handler.paymentStatus = .success

        // Wait for the first `didFinish` to fully complete (including its state clear,
        // guaranteed by the same main-queue FIFO trick as the test above) before firing
        // the second, so the two calls can't race.
        let firstCallExpectation = expectation(description: "first didFinish completes")
        handler.completionHandler = { _, _, _ in
            DispatchQueue.main.async { firstCallExpectation.fulfill() }
        }
        let firstController = PKPaymentAuthorizationController(paymentRequest: PKPaymentRequest())
        handler.paymentAuthorizationControllerDidFinish(firstController)
        wait(for: [firstCallExpectation], timeout: 2.0)

        let secondCallExpectation = expectation(description: "second didFinish reports failure, not a stale success")
        handler.completionHandler = { success, token, billingInfo in
            XCTAssertFalse(success, "a handler reused without a new didAuthorizePayment must not report success")
            XCTAssertNil(token)
            XCTAssertNil(billingInfo)
            secondCallExpectation.fulfill()
        }
        let secondController = PKPaymentAuthorizationController(paymentRequest: PKPaymentRequest())
        handler.paymentAuthorizationControllerDidFinish(secondController)

        wait(for: [secondCallExpectation], timeout: 2.0)
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

        //Test length-valid but Luhn-invalid card
        XCTAssertFalse(CreditCardValidator("4111111111111112").isValid)
    }

    func testRecurlyErrorResponse() throws {
        try XCTSkipIf(publicKey.isEmpty, "PUBLIC_KEY not set")
        
        //Initialize the SDK
        RecurlyConfiguration.shared.initialize(publicKey: publicKey)
        let session = makeTestSession()
        // Purposefully blank this out as if it were missing.
        session.expDate = ""

        let tokenResponseExpectation = expectation(description: "TokenErrorResponse")
        RecurlyTokenizationManager.shared.getTokenId(session: session, billingInfo: testBillingInfo) { tokenId, error in
            if let errorResponse = error {
                XCTAssertTrue(errorResponse.error.code == "invalid-parameter")
                tokenResponseExpectation.fulfill()
            }
        }
        wait(for: [tokenResponseExpectation], timeout: 5.0)
    }


    // MARK: - Offline coverage
    //
    // These tests run without PUBLIC_KEY / network access, exercising the real
    // NetworkEngine -> RecurlyAPIClient -> RecurlyTokenizationManager chain against a
    // MockURLProtocol-stubbed URLSession. They run on every PR, including forks.
    //
    // NOTE: two branches are intentionally not covered — NetworkEngine.sendRequest's
    // "nil data" guard (not reliably reachable via URLProtocol stubbing) and
    // createPOSTRequest(requestBodyObject:)'s JSONSerialization-failure path (forcing
    // it can raise an uncatchable Objective-C exception instead of a Swift error).

    // MARK: NetworkEngine

    func testNetworkEngine_sendRequest_success() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let responseJSON = "{\"id\":\"tok-123\",\"type\":\"credit_card\"}".data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        let engine = NetworkEngine()
        let result = engine.mapResponse(responseJSON, response, nil, responseModel: RecurlyTokenResponse.self)
        switch result {
        case .success(let response):
            XCTAssertEqual(response.id, "tok-123")
        case .failure(let error):
            XCTFail("unexpected failure: \(String(describing: error.error.message))")
        }
    }

    func testNetworkEngine_sendRequest_recurlyErrorBody() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let errorJSON = "{\"error\":{\"code\":\"invalid-parameter\",\"message\":\"boom\",\"details\":[]}}".data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        let engine = NetworkEngine()
        let result = engine.mapResponse(errorJSON, response, nil, responseModel: RecurlyTokenResponse.self)
        switch result {
        case .success:
            XCTFail("expected failure")
        case .failure(let error):
            XCTAssertEqual(error.error.code, "invalid-parameter")
        }
    }

    func testNetworkEngine_sendRequest_transportError() {
        let engine = NetworkEngine()
        let result = engine.mapResponse(nil, nil, URLError(.notConnectedToInternet), responseModel: RecurlyTokenResponse.self)
        switch result {
        case .success:
            XCTFail("expected failure")
        case .failure(let error):
            XCTAssertEqual(error.error.code, "network-error")
        }
    }

    func testNetworkEngine_sendRequest_nonSuccessStatusCode() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let body = "{}".data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)

        let engine = NetworkEngine()
        let result = engine.mapResponse(body, response, nil, responseModel: RecurlyTokenResponse.self)
        switch result {
        case .success:
            XCTFail("expected failure")
        case .failure(let error):
            XCTAssertEqual(error.error.code, "http-500")
        }
    }

    func testNetworkEngine_sendRequest_undecodableSuccessBody_returnsSdkInternal() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let garbage = "not json".data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        let engine = NetworkEngine()
        let result = engine.mapResponse(garbage, response, nil, responseModel: RecurlyTokenResponse.self)
        switch result {
        case .success:
            XCTFail("expected failure")
        case .failure(let error):
            XCTAssertEqual(error.error.code, "sdk-internal")
        }
    }


    func testNetworkEngine_mapResponse_noData_returnsNetworkError() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        let engine = NetworkEngine()
        let result = engine.mapResponse(nil, response, nil, responseModel: RecurlyTokenResponse.self)
        switch result {
        case .success:
            XCTFail("expected failure")
        case .failure(let error):
            XCTAssertEqual(error.error.code, "network-error")
        }
    }


    func testNetworkEngine_sendRequest_wiredThroughURLSession_success() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let responseJSON = "{\"id\":\"tok-123\",\"type\":\"credit_card\"}".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 200, httpVersion: nil, headerFields: nil), responseJSON, nil)
        }

        let engine = NetworkEngine(session: MockURLProtocol.makeSession())
        let expectation = expectation(description: "wiredThroughURLSession_success")
        engine.sendRequest(responseModel: RecurlyTokenResponse.self, request: URLRequest(url: url)) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.id, "tok-123")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("unexpected failure: \(String(describing: error.error.message))")
            }
        }
        // Generous timeout: exercises the real dataTask(...).resume() wiring end-to-end.
        wait(for: [expectation], timeout: 10.0)
    }


    func testNetworkEngine_sendRequest_wiredThroughURLSession_httpErrorStatus() {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        let body = "{}".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            (HTTPURLResponse(url: request.url ?? url, statusCode: 500, httpVersion: nil, headerFields: nil), body, nil)
        }

        let engine = NetworkEngine(session: MockURLProtocol.makeSession())
        let expectation = expectation(description: "wiredThroughURLSession_httpErrorStatus")
        engine.sendRequest(responseModel: RecurlyTokenResponse.self, request: URLRequest(url: url)) { result in
            switch result {
            case .success:
                XCTFail("expected failure")
            case .failure(let error):
                XCTAssertEqual(error.error.code, "http-500")
                expectation.fulfill()
            }
        }
        // Generous timeout: exercises real dataTask(...).resume() failure delivery.
        wait(for: [expectation], timeout: 10.0)
    }

    func testNetworkEngine_createPOSTRequest_setsTimeoutIntervalTo30() {
        let engine = NetworkEngine()
        let request = engine.createPOSTRequest(requestType: .getTokenID, requestBodyObject: ["key": "value"])
        XCTAssertEqual(request?.timeoutInterval, 30)
    }

    func testNetworkEngine_defaultSession_isPrivateEphemeralConfig() throws {
        // The default session must not be `URLSession.shared`, so the SDK never shares
        // the host app's connection pool, cache, or cookie jar.
        let engine = NetworkEngine()
        let mirror = Mirror(reflecting: engine)
        let session = try XCTUnwrap(mirror.children.first(where: { $0.label == "session" })?.value as? URLSession)

        XCTAssertFalse(session === URLSession.shared)
        XCTAssertNil(session.configuration.urlCache)
        XCTAssertFalse(session.configuration.httpShouldSetCookies)
        XCTAssertEqual(session.configuration.httpCookieAcceptPolicy, .never)
    }

    // MARK: RecurlyAPIClient

    func testREAPIClient_getTokenID_buildFailure_returnsFailPublisher() {
        struct UnencodableFixture: Codable {
            let value: Double
        }

        let apiClient = RecurlyAPIClient(networkEngine: NetworkEngine(session: MockURLProtocol.makeSession()))
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "buildFailure")

        apiClient.getTokenID(with: UnencodableFixture(value: .infinity), requestType: .getTokenID)
            .sink(receiveCompletion: { completion in
                if case .failure(let error as RecurlyBaseErrorResponse) = completion {
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

    // The tests below exercise `RecurlyAPIClient.makeToken(from:)` directly — the pure,
    // side-effect-free mapping seam extracted from `getToken`'s `sendRequest` completion.
    // This verifies the id-guard/card-mapping logic deterministically, without a real
    // `URLSession` round-trip (see CI flake history on the previous MockURLProtocol-driven
    // versions of these tests).

    func testRecurlyAPIClient_makeToken_missingId_returnsSdkInternal() {
        let response = RecurlyTokenResponse(type: "credit_card", id: nil, card: nil)

        let result = RecurlyAPIClient.makeToken(from: .success(response))

        guard case .failure(let error as RecurlyBaseErrorResponse) = result else {
            XCTFail("expected sdk-internal failure")
            return
        }
        XCTAssertEqual(error.error.code, "sdk-internal")
    }

    func testRecurlyAPIClient_makeToken_success_returnsFullTokenWithCard() {
        let card = RecurlyTokenCard(brand: "visa", firstSix: "411111", lastFour: "1111", expMonth: 12, expYear: 2030, issuingCountry: "US", fundingSource: "credit")
        let response = RecurlyTokenResponse(type: "credit_card", id: "tok-abc", card: card)

        let result = RecurlyAPIClient.makeToken(from: .success(response))

        guard case .success(let token) = result else {
            XCTFail("expected success")
            return
        }
        XCTAssertEqual(token.id, "tok-abc")
        XCTAssertEqual(token.type, "credit_card")
        XCTAssertEqual(token.card?.brand, "visa")
        XCTAssertEqual(token.card?.firstSix, "411111")
        XCTAssertEqual(token.card?.lastFour, "1111")
        XCTAssertEqual(token.card?.expMonth, 12)
        XCTAssertEqual(token.card?.expYear, 2030)
        XCTAssertEqual(token.card?.issuingCountry, "US")
        XCTAssertEqual(token.card?.fundingSource, "credit")
    }

    func testRecurlyAPIClient_makeToken_stillReturnsBareId_whenCardPresent() {
        let card = RecurlyTokenCard(brand: "visa", firstSix: "411111", lastFour: "1111", expMonth: 12, expYear: 2030, issuingCountry: "US", fundingSource: "credit")
        let response = RecurlyTokenResponse(type: "credit_card", id: "tok-abc", card: card)

        let result = RecurlyAPIClient.makeToken(from: .success(response)).map(\.id)

        guard case .success(let id) = result else {
            XCTFail("expected success")
            return
        }
        XCTAssertEqual(id, "tok-abc")
    }

    // MARK: RecurlyTokenizationManager

    /// Minimal `TokenAPIClient` fake letting `RecurlyTokenizationManager` tests assert
    /// delegation/validation logic deterministically (`Result.publisher` delivers
    /// synchronously), without driving a real `URLSession` round-trip.
    private struct StubTokenAPIClient: TokenAPIClient {
        var result: Result<RecurlyToken, Error> = .success(RecurlyToken(id: "stub-unused", type: nil, card: nil))
        var onCall: (() -> Void)? = nil
        var finishesWithoutValue = false

        func getToken<T: Codable>(with dataRequest: T, requestType: TokenizationAPI) -> AnyPublisher<RecurlyToken, Error> {
            onCall?()
            if finishesWithoutValue {
                return Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            return result.publisher.eraseToAnyPublisher()
        }

        func getTokenID<T: Codable>(with dataRequest: T, requestType: TokenizationAPI) -> AnyPublisher<String, Error> {
            getToken(with: dataRequest, requestType: requestType)
                .map(\.id)
                .eraseToAnyPublisher()
        }
    }

    func testRETokenizationManager_emptyCVV_doesNotHitNetwork() {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(onCall: {
            XCTFail("network should not be called when cvv is empty")
        }))
        let session = RecurlyCardSession()

        let expectation = expectation(description: "emptyCvv")
        manager.getTokenId(session: session) { tokenId, error in
            XCTAssertNil(tokenId)
            XCTAssertEqual(error?.error.code, "validation")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }


    func testRETokenizationManager_getToken_strongSelfCaptureKeepsManagerAliveUntilCompletion() {
        // The strong self-capture in getToken's Task keeps the manager alive here.
        var manager: RecurlyTokenizationManager? = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-abc", type: "credit_card", card: nil))
        ))
        let session = makeTestSession()

        let expectation = expectation(description: "completionCalledDespiteDeallocation")
        manager?.getToken(session: session) { _, _ in
            expectation.fulfill()
        }
        manager = nil

        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getTokenId_success() {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-abc", type: "credit_card", card: nil))
        ))
        let session = makeTestSession()

        let expectation = expectation(description: "tokenSuccess")
        manager.getTokenId(session: session) { tokenId, error in
            XCTAssertNil(error)
            XCTAssertEqual(tokenId, "tok-abc")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getTokenId_defaultResetOnSuccess_clearsSession() {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-abc", type: "credit_card", card: nil))
        ))
        let session = makeTestSession()

        // Reset and completion share one Task, in order, so no run-loop spin is needed here.
        let expectation = expectation(description: "resetOnSuccessDefault")
        manager.getTokenId(session: session) { tokenId, error in
            XCTAssertTrue(Thread.isMainThread, "completion must be delivered on the main thread")
            XCTAssertNil(error)
            XCTAssertEqual(session.number, "", "resetOnSuccess defaults to true")
            XCTAssertEqual(session.cvv, "")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getTokenId_resetOnSuccessFalse_keepsSessionData() {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-abc", type: "credit_card", card: nil))
        ))
        let session = makeTestSession()

        let expectation = expectation(description: "resetOnSuccessFalse")
        manager.getTokenId(session: session, resetOnSuccess: false) { tokenId, error in
            XCTAssertNil(error)
            XCTAssertEqual(session.cardData.number, "4111111111111111", "resetOnSuccess: false must keep the entered data")
            XCTAssertNotEqual(session.cvv, "")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getTokenId_resetOnSuccessFalse_doesNotResetOnFailure() {
        // A failed tokenization never resets the session regardless of `resetOnSuccess` —
        // this only confirms the parameter doesn't accidentally invert that behavior.
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .failure(RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "invalid-parameter", message: "bad card", details: [])))
        ))
        let session = makeTestSession()

        let expectation = expectation(description: "resetOnSuccessFalse_failure")
        manager.getTokenId(session: session, resetOnSuccess: false) { tokenId, error in
            XCTAssertNotNil(error)
            XCTAssertEqual(session.cardData.number, "4111111111111111")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getTokenId_defaultResetOnSuccess_doesNotResetOnFailure() {
        // A decline must never wipe the card, even with the default resetOnSuccess.
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .failure(RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "invalid-parameter", message: "bad card", details: [])))
        ))
        let session = makeTestSession()

        let expectation = expectation(description: "defaultResetOnSuccess_failure")
        manager.getTokenId(session: session) { tokenId, error in
            XCTAssertTrue(Thread.isMainThread, "completion must be delivered on the main thread")
            XCTAssertNotNil(error)
            XCTAssertEqual(session.cardData.number, "4111111111111111", "a decline must not reset the session under the default resetOnSuccess: true")
            XCTAssertNotEqual(session.cvv, "")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getTokenId_failureMapped() {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .failure(RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "invalid-parameter", message: "bad card", details: [])))
        ))
        let session = RecurlyCardSession()
        session.cvv = "123"

        let expectation = expectation(description: "tokenFailure")
        manager.getTokenId(session: session) { tokenId, error in
            XCTAssertTrue(Thread.isMainThread, "completion must be delivered on the main thread")
            XCTAssertNil(tokenId)
            XCTAssertEqual(error?.error.code, "invalid-parameter")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getApplePayTokenId_success() {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-apple-abc", type: "credit_card", card: nil))
        ))

        // Unlike getToken, this path has no @MainActor hop before subscribe — drive it
        // from a background queue to actually test the main-thread delivery contract.
        let expectation = expectation(description: "applePayTokenSuccess")
        DispatchQueue.global().async {
            manager.getApplePayTokenId(paymentData: RecurlyApplePaymentData(), paymentMethod: RecurlyApplePaymentMethod()) { tokenId, error in
                XCTAssertTrue(Thread.isMainThread, "completion must be delivered on the main thread")
                XCTAssertNil(error)
                XCTAssertEqual(tokenId, "tok-apple-abc")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRETokenizationManager_getApplePayTokenId_failureMapped() {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .failure(RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "invalid-parameter", message: "bad apple pay token", details: [])))
        ))

        let expectation = expectation(description: "applePayTokenFailure")
        manager.getApplePayTokenId(paymentData: RecurlyApplePaymentData(), paymentMethod: RecurlyApplePaymentMethod()) { tokenId, error in
            XCTAssertNil(tokenId)
            XCTAssertEqual(error?.error.code, "invalid-parameter")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRecurlyTokenizationManager_getToken_success_surfacesCard() {
        let card = RecurlyTokenCard(brand: "visa", firstSix: "411111", lastFour: "1111", expMonth: 12, expYear: 2030, issuingCountry: "US", fundingSource: "credit")
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-abc", type: "credit_card", card: card))
        ))
        let session = makeTestSession()

        let expectation = expectation(description: "getTokenSuccess")
        manager.getToken(session: session) { token, error in
            XCTAssertNil(error)
            XCTAssertEqual(token?.id, "tok-abc")
            XCTAssertEqual(token?.card?.brand, "visa")
            XCTAssertEqual(token?.card?.lastFour, "1111")
            XCTAssertEqual(token?.card?.expMonth, 12)
            XCTAssertEqual(token?.card?.expYear, 2030)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRecurlyTokenizationManager_getToken_success_cardAbsent() {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-x", type: "credit_card", card: nil))
        ))
        let session = makeTestSession()

        let expectation = expectation(description: "getTokenSuccess_cardAbsent")
        manager.getToken(session: session) { token, error in
            XCTAssertNil(error)
            XCTAssertEqual(token?.id, "tok-x")
            XCTAssertNil(token?.card)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRecurlyTokenizationManager_getApplePayToken_success_surfacesCard() {
        let card = RecurlyTokenCard(brand: "master", firstSix: "555555", lastFour: "4444", expMonth: 6, expYear: 2029, issuingCountry: "ZZ", fundingSource: "debit")
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-apple-abc", type: "credit_card", card: card))
        ))

        let expectation = expectation(description: "getApplePayTokenSuccess")
        manager.getApplePayToken(paymentData: RecurlyApplePaymentData(), paymentMethod: RecurlyApplePaymentMethod()) { token, error in
            XCTAssertNil(error)
            XCTAssertEqual(token?.id, "tok-apple-abc")
            XCTAssertEqual(token?.card?.brand, "master")
            XCTAssertEqual(token?.card?.lastFour, "4444")
            XCTAssertEqual(token?.card?.issuingCountry, "ZZ")
            XCTAssertEqual(token?.card?.fundingSource, "debit")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRecurlyTokenizationManager_getApplePayTokenId_stillReturnsBareId_whenCardPresent() {
        let card = RecurlyTokenCard(brand: "master", firstSix: "555555", lastFour: "4444", expMonth: 6, expYear: 2029, issuingCountry: "ZZ", fundingSource: "debit")
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-apple-abc", type: "credit_card", card: card))
        ))

        let expectation = expectation(description: "getApplePayTokenIdRegression")
        manager.getApplePayTokenId(paymentData: RecurlyApplePaymentData(), paymentMethod: RecurlyApplePaymentMethod()) { tokenId, error in
            XCTAssertNil(error)
            XCTAssertEqual(tokenId, "tok-apple-abc")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Async/Await

    func testRecurlyTokenizationManager_async_emptyCVV_doesNotHitNetwork() async {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(onCall: {
            XCTFail("network should not be called when cvv is empty")
        }))
        let session = RecurlyCardSession()

        do {
            _ = try await manager.getTokenId(session: session)
            XCTFail("expected getTokenId to throw")
        } catch {
            XCTAssertEqual((error as? RecurlyBaseErrorResponse)?.error.code, "validation")
        }
    }

    func testRecurlyTokenizationManager_async_getTokenId_success() async throws {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-abc", type: "credit_card", card: nil))
        ))
        let session = makeTestSession()

        let tokenId = try await manager.getTokenId(session: session)
        XCTAssertEqual(tokenId, "tok-abc")
    }

    func testRecurlyTokenizationManager_async_getTokenId_failureMapped() async {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .failure(RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "invalid-parameter", message: "bad card", details: [])))
        ))
        let session = RecurlyCardSession()
        session.cvv = "123"

        do {
            _ = try await manager.getTokenId(session: session)
            XCTFail("expected getTokenId to throw")
        } catch {
            XCTAssertEqual((error as? RecurlyBaseErrorResponse)?.error.code, "invalid-parameter")
        }
    }

    func testRecurlyTokenizationManager_async_getToken_success_surfacesCard() async throws {
        let card = RecurlyTokenCard(brand: "visa", firstSix: "411111", lastFour: "1111", expMonth: 12, expYear: 2030, issuingCountry: "US", fundingSource: "credit")
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-abc", type: "credit_card", card: card))
        ))
        let session = makeTestSession()

        let token = try await manager.getToken(session: session)
        XCTAssertEqual(token.id, "tok-abc")
        XCTAssertEqual(token.card?.brand, "visa")
        XCTAssertEqual(token.card?.lastFour, "1111")
        XCTAssertEqual(token.card?.expMonth, 12)
        XCTAssertEqual(token.card?.expYear, 2030)
    }

    func testRecurlyTokenizationManager_async_getApplePayToken_success_surfacesCard() async throws {
        let card = RecurlyTokenCard(brand: "master", firstSix: "555555", lastFour: "4444", expMonth: 6, expYear: 2029, issuingCountry: "ZZ", fundingSource: "debit")
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-apple-abc", type: "credit_card", card: card))
        ))

        let token = try await manager.getApplePayToken(paymentData: RecurlyApplePaymentData(), paymentMethod: RecurlyApplePaymentMethod())
        XCTAssertEqual(token.id, "tok-apple-abc")
        XCTAssertEqual(token.card?.brand, "master")
        XCTAssertEqual(token.card?.lastFour, "4444")
    }

    func testRecurlyTokenizationManager_async_getApplePayToken_failureMapped() async {
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .failure(RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "invalid-parameter", message: "bad apple pay token", details: [])))
        ))

        do {
            _ = try await manager.getApplePayToken(paymentData: RecurlyApplePaymentData(), paymentMethod: RecurlyApplePaymentMethod())
            XCTFail("expected getApplePayToken to throw")
        } catch {
            XCTAssertEqual((error as? RecurlyBaseErrorResponse)?.error.code, "invalid-parameter")
        }
    }

    func testRecurlyTokenizationManager_async_finishesWithoutValue_throwsInternal() async {
        var stub = StubTokenAPIClient()
        stub.finishesWithoutValue = true
        let manager = RecurlyTokenizationManager(apiClient: stub)
        let session = RecurlyCardSession()
        session.cvv = "123"

        do {
            _ = try await manager.getToken(session: session)
            XCTFail("expected getToken to throw when the publisher finishes without a value")
        } catch {
            XCTAssertEqual((error as? RecurlyBaseErrorResponse)?.error.code, "sdk-internal")
        }
    }

    func testRecurlyTokenizationManager_async_getApplePayTokenId_stillReturnsBareId_whenCardPresent() async throws {
        let card = RecurlyTokenCard(brand: "master", firstSix: "555555", lastFour: "4444", expMonth: 6, expYear: 2029, issuingCountry: "ZZ", fundingSource: "debit")
        let manager = RecurlyTokenizationManager(apiClient: StubTokenAPIClient(
            result: .success(RecurlyToken(id: "tok-apple-abc", type: "credit_card", card: card))
        ))

        let tokenId = try await manager.getApplePayTokenId(paymentData: RecurlyApplePaymentData(), paymentMethod: RecurlyApplePaymentMethod())
        XCTAssertEqual(tokenId, "tok-apple-abc")
    }

    // Note: getApplePayTokenId's `case .failure(let error):` non-RecurlyBaseErrorResponse
    // fallback (mirrors getTokenId's) is unreachable through the public API —
    // RecurlyAPIClient.getToken (used by both, via the shared `subscribe` helper) only ever
    // fails its publisher with RecurlyBaseErrorResponse.

    // MARK: Model coding

    func testRETokenResponse_decoding() throws {
        let json = "{\"id\":\"tok-1\",\"type\":\"credit_card\"}".data(using: .utf8)!
        let response = try JSONDecoder().decode(RecurlyTokenResponse.self, from: json)
        XCTAssertEqual(response.id, "tok-1")
        XCTAssertEqual(response.type, "credit_card")
    }

    func testRecurlyTokenResponse_decoding_withCard() throws {
        let json = """
        {"id":"tok-1","type":"credit_card","card":{"brand":"visa","first_six":"411111","last_four":"1111","exp_month":12,"exp_year":2030,"issuing_country":"US","funding_source":"credit"}}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(RecurlyTokenResponse.self, from: json)
        XCTAssertEqual(response.id, "tok-1")
        XCTAssertEqual(response.type, "credit_card")
        let card = try XCTUnwrap(response.card)
        XCTAssertEqual(card.brand, "visa")
        XCTAssertEqual(card.firstSix, "411111")
        XCTAssertEqual(card.lastFour, "1111")
        XCTAssertEqual(card.expMonth, 12)
        XCTAssertEqual(card.expYear, 2030)
        XCTAssertEqual(card.issuingCountry, "US")
        XCTAssertEqual(card.fundingSource, "credit")
    }

    func testRecurlyCardData_debugDescription_neverContainsCardData() {
        var cardData = RecurlyCardData()
        cardData.number = "4111111111111111"
        cardData.month = "12"
        cardData.year = "2030"
        cardData.cvv = "123"

        XCTAssertEqual(cardData.debugDescription, "RecurlyCardData(<redacted>)")
        XCTAssertEqual("\(cardData)", "RecurlyCardData(<redacted>)")
    }

    func testREBaseErrorResponse_decoding() throws {
        let json = "{\"error\":{\"code\":\"invalid-parameter\",\"message\":\"bad input\",\"details\":[]}}".data(using: .utf8)!
        let response = try JSONDecoder().decode(RecurlyBaseErrorResponse.self, from: json)
        XCTAssertEqual(response.error.code, "invalid-parameter")
        XCTAssertEqual(response.error.message, "bad input")
    }

    func testRETokenRequest_encoding_flattensFieldsAndSnakeCasesBillingInfo() throws {
        var billingInfo = RecurlyBillingInfo()
        billingInfo.firstName = "Jane"
        billingInfo.lastName = "Doe"

        let request = RecurlyTokenRequest(
            cardData: RecurlyCardData(),
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
        XCTAssertEqual(CreditCardValidator("6449000000000006").type, .discover)
        XCTAssertEqual(CreditCardValidator("6490000000000004").type, .discover)
    }

    func testCreditCardValidator_validNumberLengths() {
        XCTAssertTrue(CreditCardType.visa.validNumberLength.contains(13))
        XCTAssertTrue(CreditCardType.visa.validNumberLength.contains(16))
        XCTAssertTrue(CreditCardType.visa.validNumberLength.contains(19))
        XCTAssertFalse(CreditCardType.visa.validNumberLength.contains(15))
        XCTAssertTrue(CreditCardType.amex.validNumberLength.contains(15))
        XCTAssertTrue(CreditCardType.dinersClub.validNumberLength.contains(14))
    }


    func testCreditCardValidator_getExpDateFrom_groupsIntoMonthYearPairs() {
        XCTAssertEqual(CreditCardValidator.getExpDateFrom(string: "1230"), "12/30")
    }

    func testCreditCardValidator_getExpDateFrom_ignoresWhitespace() {
        XCTAssertEqual(CreditCardValidator.getExpDateFrom(string: "12 30"), "12/30")
    }

    func testCreditCardValidator_getExpDateFrom_ignoresSurroundingWhitespace() {
        XCTAssertEqual(CreditCardValidator.getExpDateFrom(string: "  12/30  "), "12/30")
    }


    func testCreditCardValidator_expDateIsInvalid_emptyIsNotInvalid() {
        // A freshly-split "" produces [""], and indexing date[1] unguarded there was the
        // original out-of-bounds crash risk. Empty is treated as "not yet entered", not invalid.
        XCTAssertFalse(CreditCardValidator.expDateIsInvalid(""))
    }

    func testCreditCardValidator_expDateIsInvalid_malformedNonEmptyValue_isInvalid() {
        // A non-empty value that doesn't split into exactly two components (no "/" present)
        // is treated as invalid, unlike the empty case above.
        XCTAssertTrue(CreditCardValidator.expDateIsInvalid("1"))
    }

    func testCreditCardValidator_formatCCfrom_groupsFullVisaPattern() {
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: "4111111111111111"), "4111 1111 1111 1111")
    }


    func testCreditCardValidator_formatCCfrom_groupsDinersClub14AsFourSixFour() {
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: "36227206271667"), "3622 720627 1667")
    }

    func testCreditCardValidator_formatCCfrom_diners16DoesNotTruncate() {
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: "3600000000000008"), "3600 0000 0000 0008")
    }

    func testCreditCardValidator_formatCCfrom_visa19DigitsGroupsAsFourFourFourFourThree() {
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: "4111111111111111110"), "4111 1111 1111 1111 110")
    }

    func testCreditCardValidator_formatCCfrom_maestro19DoesNotTruncate() {
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: "6759000000000000005"), "6759 0000 0000 0000 005")
    }

    func testCreditCardValidator_formatCCfrom_unionPay19DoesNotTruncate() {
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: "6220000000000000008"), "6220 0000 0000 0000 008")
    }

    func testCreditCardValidator_formatCCfrom_jcb19DoesNotTruncate() {
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: "3528000000000000007"), "3528 0000 0000 0000 007")
    }


    func testCreditCardValidator_formatCCfrom_discover19DoesNotTruncate() {
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: "6011000000000000001"), "6011 0000 0000 0000 001")
    }

    func testCreditCardValidator_formatCCfrom_capsMaestroAt19WhenPasteIsLonger() {
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: "67590000000000000059"), "6759 0000 0000 0000 005")
    }

    func testCreditCardValidator_formatCCfrom_preservesDigitsThroughReformatting() {
        let input = "4111 1111 1111 1111"
        XCTAssertEqual(CreditCardValidator.formatCCfrom(string: input).digitsOnly, input.digitsOnly)
    }

    func testCreditCardValidator_isValid_accepts19DigitVisa() {
        let validator = CreditCardValidator("4111111111111111110")
        XCTAssertEqual(validator.type, .visa)
        XCTAssertTrue(validator.isValid)
    }

    func testCreditCardValidator_isValid_accepts13DigitVisa() {
        let validator = CreditCardValidator("4222222222222")
        XCTAssertEqual(validator.type, .visa)
        XCTAssertTrue(validator.isValid)
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
        RecurlyConfiguration.shared.apiPublicKey = "fra-test123"
        XCTAssertEqual(TokenizationAPI.getTokenID.baseURL, "api.eu.recurly.com/js/v1")
        XCTAssertEqual(TokenizationAPI.getTokenID.absoluteString, "https://api.eu.recurly.com/js/v1/tokens")
    }

    func testTokenizationAPI_euKeyPrefix_routesApplePayToEUHost() {
        RecurlyConfiguration.shared.apiPublicKey = "fra-test123"
        XCTAssertEqual(TokenizationAPI.getApplePayTokenID.absoluteString, "https://api.eu.recurly.com/js/v1/apple_pay/token")
    }

    func testTokenizationAPI_usKey_routesToUSHost() {
        RecurlyConfiguration.shared.apiPublicKey = "pub-test123"
        XCTAssertEqual(TokenizationAPI.getTokenID.baseURL, "api.recurly.com/js/v1")
        XCTAssertEqual(TokenizationAPI.getTokenID.absoluteString, "https://api.recurly.com/js/v1/tokens")
    }

    func testTokenizationAPI_emptyKey_defaultsToUSHost() {
        RecurlyConfiguration.shared.apiPublicKey = ""
        XCTAssertEqual(TokenizationAPI.getTokenID.baseURL, "api.recurly.com/js/v1")
    }

    func testTokenizationAPI_userAgent_structure() {
        let userAgent = TokenizationAPI.getTokenID.userAgent
        XCTAssertTrue(userAgent.hasPrefix("recurly-ios/"), "User-Agent should start with recurly-ios/<version>")
        XCTAssertTrue(userAgent.contains("device/"))
        XCTAssertTrue(userAgent.contains("os/"))
        XCTAssertTrue(userAgent.contains("appName/"))
        XCTAssertFalse(userAgent.contains("carrierName"), "carrierName was removed with CoreTelephony/CTCarrier")
    }

    func testRecurlySDKVersion_isNonEmpty() {
        XCTAssertFalse(RecurlySDK.version.isEmpty, "RecurlySDK.version must resolve to either the bundle version or the fallback constant")
    }

    func testRETokenizationManager_getTokenId_wireBodyIncludesSDKVersion() throws {
        let url = URL(string: "https://api.recurly.com/js/v1/tokens")!
        var capturedBody: Data?
        let responseJSON = "{\"id\":\"tok-abc\",\"type\":\"credit_card\"}".data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            if let stream = request.httpBodyStream {
                stream.open()
                defer { stream.close() }
                var data = Data()
                var buffer = [UInt8](repeating: 0, count: 1024)
                while stream.hasBytesAvailable {
                    let read = stream.read(&buffer, maxLength: buffer.count)
                    guard read > 0 else { break }
                    data.append(buffer, count: read)
                }
                capturedBody = data
            }
            return (HTTPURLResponse(url: request.url ?? url, statusCode: 200, httpVersion: nil, headerFields: nil), responseJSON, nil)
        }

        let manager = RecurlyTokenizationManager(apiClient: RecurlyAPIClient(networkEngine: NetworkEngine(session: MockURLProtocol.makeSession())))
        let session = makeTestSession()

        let expectation = expectation(description: "tokenSuccess")
        manager.getTokenId(session: session) { _, _ in
            expectation.fulfill()
        }
        // Generous timeout: exercises the real dataTask(...).resume() wiring end-to-end
        // (asserts the actual serialized wire body).
        wait(for: [expectation], timeout: 10.0)

        let body = try XCTUnwrap(capturedBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(json["version"] as? String, RecurlySDK.version, "Wire 'version' field must be the SDK/client-library version, not the host app's version")
    }

    // MARK: Extensions

    func testStringRemoveNonNumericChars_stripsNonDigits() {
        XCTAssertEqual("abc123-456".removeNonNumericChars(), "123456")
    }

    func testStringRemoveNonNumericChars_noOpWhenAlreadyClean() {
        XCTAssertEqual("12 30".removeNonNumericChars(), "12 30")
    }

    func testStringRemoveNonNumericChars_keepsExceptionCharacter_whenNoOtherNonDigits() {
        XCTAssertEqual("12/30".removeNonNumericChars(exceptions: "/"), "12/30")
    }

    func testStringRemoveNonNumericChars_keepsExceptionCharacter_whenOtherNonDigitsPresent() {
        XCTAssertEqual("12/3a".removeNonNumericChars(exceptions: "/"), "12/3")
    }

    func testStringRemoveNonNumericChars_keepsExceptionCharacter_whenLeadingJunkPresent() {
        XCTAssertEqual("1a2/30".removeNonNumericChars(exceptions: "/"), "12/30")
    }

    // Regex metacharacters in `exceptions` are matched literally. These cases would
    // change meaning if the filter were built from a character class.
    func testStringRemoveNonNumericChars_treatsHyphenExceptionLiterally_notAsRange() {
        XCTAssertEqual("1-2a".removeNonNumericChars(exceptions: "-/"), "1-2")
        XCTAssertEqual("1(2*3a".removeNonNumericChars(exceptions: "-/"), "123")
    }

    func testStringRemoveNonNumericChars_keepsClosingBracketException_whenOtherNonDigitsPresent() {
        XCTAssertEqual("12]3a".removeNonNumericChars(exceptions: "]"), "12]3")
    }

    func testStringRemoveNonNumericChars_keepsOpeningBracketException_whenOtherNonDigitsPresent() {
        XCTAssertEqual("1[2a".removeNonNumericChars(exceptions: "["), "1[2")
    }

    func testStringRemoveNonNumericChars_stripsNonAsciiDigits() {
        XCTAssertEqual("\u{0661}\u{0662}3a".removeNonNumericChars(), "3")
    }

    func testStringRemoveNonNumericChars_emptyString_returnsEmpty() {
        XCTAssertEqual("".removeNonNumericChars(), "")
    }

    func testStringDigitsOnly_stripsSpacesAndSymbols() {
        XCTAssertEqual("4111 1111-1111 1111".digitsOnly, "4111111111111111")
    }

    // MARK: - RecurlyCardSession input behavior
    //
    // Each test constructs its own session, so no shared teardown reset is needed.

    /// Two-digit year five years out. Keeps the expiry-date tests valid for the
    /// foreseeable future.
    private var futureTwoDigitYear: Int {
        Calendar.current.component(.year, from: Date()) + 5 - 2000
    }

    func testCardSession_cardNumber_visaPaste_formatsIntoFourDigitGroups() {
        let session = RecurlyCardSession()
        session.number = "4111111111111111"
        XCTAssertEqual(session.number, "4111 1111 1111 1111")
    }

    func testCardSession_cardNumber_visaPaste_storesDigitsOnlyInCardData() {
        let session = RecurlyCardSession()
        session.number = "4111111111111111"
        // Regression test: `cardData.number` must hold digits only. It must never hold
        // the space-formatted display string. Kept separate from the formatting test
        // above so this specific regression fails on its own.
        XCTAssertEqual(session.cardData.number, "4111111111111111")
    }

    func testCardSession_cardNumber_amexPaste_formatsIntoAmexGrouping() {
        let session = RecurlyCardSession()
        session.number = "378282246310005"
        XCTAssertEqual(session.number, "3782 822463 10005")
        XCTAssertEqual(session.cardData.number, "378282246310005")
    }

    func testCardSession_cardNumber_overLengthPaste_truncatesToBrandMaxLength() {
        // The cap comes from the current value's own detected brand, so pasting past
        // the brand's max length truncates rather than leaving raw digits in the field.
        let session = RecurlyCardSession()
        session.number = "4111111111111111"
        session.number = "41111111111111119999"
        XCTAssertEqual(session.number, "4111 1111 1111 1111 999")
        XCTAssertEqual(session.cardData.number, "4111111111111111999")
    }

    func testCardSession_cardNumber_backspacingFormattedNumber_ungroupsCleanly() {
        let session = RecurlyCardSession()
        session.number = "4111111111111111"
        XCTAssertEqual(session.number, "4111 1111 1111 1111")
        session.number = String(session.number.dropLast())
        XCTAssertEqual(session.number, "4111 1111 1111 111")
        session.number = String(session.number.dropLast(4))
        XCTAssertEqual(session.number, "4111 1111 1111")
    }

    func testCardSession_cvv_amexRequiresFourDigits() {
        let session = RecurlyCardSession()
        session.number = "378282246310005"
        session.cvv = "123"
        XCTAssertTrue(session.cvvError)
        session.cvv = "1234"
        XCTAssertFalse(session.cvvError)
        XCTAssertEqual(session.cardData.cvv, "1234")
    }

    func testCardSession_cvv_nonAmexRequiresThreeDigits() {
        let session = RecurlyCardSession()
        session.number = "4111111111111111"
        session.cvv = "123"
        XCTAssertFalse(session.cvvError)
        XCTAssertEqual(session.cardData.cvv, "123")
    }

    func testCardSession_cvv_clearingFieldAlsoClearsDerivedCardData() {
        // `cardData` is derived from `cvv` live, so a cleared field cannot leave a stale
        // CVV behind for tokenization to read.
        let session = RecurlyCardSession()
        session.number = "4111111111111111"
        session.cvv = "123"
        XCTAssertEqual(session.cardData.cvv, "123")
        session.cvv = ""
        XCTAssertFalse(session.cvvError)
        XCTAssertEqual(session.cardData.cvv, "", "cardData must reflect the cleared field, not a stale stored value")
    }

    func testCardSession_cvv_revalidatesWhenBrandChangesToRequireMoreDigits() {
        // Switching from a 3-digit-CVV brand to Amex (4 digits) re-flags a CVV that
        // is now too short, without altering the digits themselves.
        let session = RecurlyCardSession()
        session.number = "4111111111111111"
        session.cvv = "123"
        XCTAssertFalse(session.cvvError)
        session.number = "378282246310005"
        XCTAssertTrue(session.cvvError, "amex now needs 4 digits, so the stale 3-digit CVV is flagged")
        XCTAssertEqual(session.cardData.cvv, "123", "digits are not cleared, only re-flagged")
    }

    func testCardSession_cvv_revalidatesWhenBrandChangesToRequireFewerDigits() {
        // Clears the stale CVV outright — a truncated "1234" -> "123" is a different,
        // wrong code that would otherwise validate clean.
        let session = RecurlyCardSession()
        session.number = "378282246310005"
        session.cvv = "1234"
        XCTAssertFalse(session.cvvError)
        session.number = "4111111111111111"
        XCTAssertEqual(session.cvv, "", "the stale 4-digit CVV must be cleared, not truncated to a wrong 3-digit value")
        XCTAssertFalse(session.cvvError, "an untouched (now-empty) field is not yet an error, matching every other empty-field default")
        XCTAssertEqual(session.cardData.cvv, "")
    }

    func testCardSession_expDate_singleDigitFive_isZeroPrefixed() {
        let session = RecurlyCardSession()
        session.expDate = "5"
        XCTAssertEqual(session.expDate, "05")
    }

    func testCardSession_expDate_singleDigitZeroOrOne_isNotPrefixed() {
        // "0" and "1" are valid first digits of a two-digit month (01-12), so they are
        // left as-is instead of being zero-prefixed.
        let zero = RecurlyCardSession()
        zero.expDate = "0"
        XCTAssertEqual(zero.expDate, "0")

        let one = RecurlyCardSession()
        one.expDate = "1"
        XCTAssertEqual(one.expDate, "1")
    }

    func testCardSession_expDate_fourDigitPaste_insertsSlashAndValidates() {
        let session = RecurlyCardSession()
        let futureYear = futureTwoDigitYear
        session.expDate = "12\(futureYear)"
        XCTAssertEqual(session.expDate, "12/\(futureYear)")
        XCTAssertFalse(session.expDateError)
        XCTAssertEqual(session.cardData.month, "12")
        XCTAssertEqual(session.cardData.year, "20\(futureYear)")
    }

    func testCardSession_expDate_pasteWithSpaceSeparator_isAccepted() {
        let session = RecurlyCardSession()
        let futureYear = futureTwoDigitYear
        session.expDate = "12 \(futureYear)"
        XCTAssertEqual(session.expDate, "12/\(futureYear)")
        XCTAssertFalse(session.expDateError)
    }

    func testCardSession_expDate_shortenAfterComplete_alsoClearsDerivedMonthAndYear() {
        // `cardData` is derived live, so an incomplete date yields empty month/year, not a stale value.
        let session = RecurlyCardSession()
        let futureYear = futureTwoDigitYear
        session.expDate = "12\(futureYear)"
        XCTAssertEqual(session.cardData.month, "12")
        session.expDate = "12"
        XCTAssertTrue(session.expDateError)
        XCTAssertEqual(session.cardData.month, "", "cardData must reflect the incomplete field, not a stale stored value")
        XCTAssertEqual(session.cardData.year, "")
    }

    func testCardSession_validNumberAndFutureExpDate_leaveBothErrorFlagsUnset() {
        let futureYear = futureTwoDigitYear
        let session = RecurlyCardSession()
        session.number = "4111111111111111"

    func testCardSession_reset_clearsDidAttemptValidationLatch() {
        let session = makeTestSession(number: "4111111111111111", expDate: "12\(futureTwoDigitYear)", cvv: "123")
        session.cvv = ""
        session.validateData()
        XCTAssertTrue(session.cvvError)
        session.reset()
        // After reset, an untouched (empty) field must go back to "not yet an error" —
        // the didAttemptValidation latch itself must be cleared, not just the fields.
        session.number = "4"
        XCTAssertFalse(session.cvvError, "reset() must clear the didAttemptValidation latch, not just blank the fields")
    }

    func testCardSession_validateDataError_isNotClearedByKeystrokeInAnotherField() {
        // `didAttemptValidation` makes every field's didSet treat an empty value as an
        // error, so a validateData() failure on one field survives an edit to another.
        let session = RecurlyCardSession()
        XCTAssertFalse(session.validateData())
        XCTAssertTrue(session.cvvError)
        XCTAssertTrue(session.expDateError)

        session.number = "4"
        XCTAssertTrue(session.cvvError, "editing the number field must not clear a validateData-set CVV error while CVV is still empty")

        session.expDate = "12"
        session.expDate = ""
        XCTAssertTrue(session.expDateError, "clearing the exp date after latching must still flag it as an error, not treat it as untouched")
    }

    func testCardSession_cvv_sanitizationStripsSpaces() {
        // A pasted " 123" must not reach the wire as a space-containing "clean" CVV.
        let session = RecurlyCardSession()
        session.cvv = " 1 2"
        XCTAssertEqual(session.cvv, "12", "spaces must be stripped, not counted as characters")
    }

    func testCardSession_isComplete_emptySession_isFalse() {
        let session = RecurlyCardSession()
        XCTAssertFalse(session.isComplete)
    }

    func testCardSession_isComplete_partiallyFilledSession_isFalse() {
        let session = RecurlyCardSession()
        session.number = "4111111111111111"
        XCTAssertFalse(session.isComplete)
    }

    func testCardSession_isComplete_fullyValidSession_isTrue() {
        let session = makeTestSession(number: "4111111111111111", expDate: "12\(futureTwoDigitYear)", cvv: "123")
        XCTAssertTrue(session.isComplete)
    }

    func testCardSession_isComplete_doesNotMutateErrorFlagsOrLatch() {
        // Unlike validateData(), reading isComplete must have no side effects.
        let session = RecurlyCardSession()
        _ = session.isComplete
        XCTAssertFalse(session.cardNumberError)
        XCTAssertFalse(session.expDateError)
        XCTAssertFalse(session.cvvError)
        session.number = "4"
        XCTAssertFalse(session.cvvError, "isComplete must not have latched didAttemptValidation")
    }
        session.expDate = "12\(futureYear)"
        XCTAssertFalse(session.cardNumberError)
        XCTAssertFalse(session.expDateError)
    }

    func testCardSession_validateData_allFieldsValid_returnsTrueAndLeavesErrorsUnset() {
        let session = makeTestSession(number: "4111111111111111", expDate: "12\(futureTwoDigitYear)", cvv: "123")
        XCTAssertTrue(session.validateData())
        XCTAssertFalse(session.cardNumberError)
        XCTAssertFalse(session.expDateError)
        XCTAssertFalse(session.cvvError)
    }

    func testCardSession_validateData_emptyFields_returnsFalseAndFlagsEveryField() {
        // Unlike the live flags, validateData() treats an empty field as invalid.
        let session = RecurlyCardSession()
        XCTAssertFalse(session.cardNumberError, "an untouched field is not yet a live error")
        XCTAssertFalse(session.validateData())
        XCTAssertTrue(session.cardNumberError)
        XCTAssertTrue(session.expDateError)
        XCTAssertTrue(session.cvvError)
    }

    func testCardSession_validateData_incompleteCVV_returnsFalse() {
        let session = makeTestSession(number: "4111111111111111", expDate: "12\(futureTwoDigitYear)", cvv: "1")
        XCTAssertFalse(session.validateData())
        XCTAssertTrue(session.cvvError)
    }

    func testCardSession_reset_blanksEveryField() {
        let session = makeTestSession(number: "4111111111111111", expDate: "12\(futureTwoDigitYear)", cvv: "123")
        session.reset()
        XCTAssertEqual(session.number, "")
        XCTAssertEqual(session.expDate, "")
        XCTAssertEqual(session.cvv, "")
        XCTAssertFalse(session.cardNumberError)
        XCTAssertFalse(session.expDateError)
        XCTAssertFalse(session.cvvError)
    }

    func testCreditCardValidator_expDateIsInvalid_currentMonthAndYear_isValid() {
        // Classic off-by-one: a card expiring in the current month has not expired yet.
        let now = Calendar.current.dateComponents([.year, .month], from: Date())
        let month = String(format: "%02d", now.month ?? 1)
        let year = String(format: "%02d", (now.year ?? 2000) % 100)
        XCTAssertFalse(CreditCardValidator.expDateIsInvalid("\(month)/\(year)"))
    }

}
