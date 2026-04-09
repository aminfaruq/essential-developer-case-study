//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Amin faruq on 09/04/26.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        XCTAssertEqual(app.cells.count, 22)
        
        XCTAssertEqual(app.cells.firstMatch.images.count, 1)
    }
}
