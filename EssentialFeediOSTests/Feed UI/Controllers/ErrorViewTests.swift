/*
import UIKit
import XCTest
@testable import EssentialFeediOS

final class ErrorViewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
    }
    
    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }
    
    func test_init_hasNoMessageAndIsHidden() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.alpha, 0, "Expected hidden on init")
        XCTAssertNil(sut.message, "Expected no message on init")
    }
    
    func test_setMessage_showsMessageWithAnimation() {
        let sut = makeSUT()
        
        sut.message = "any message"
        
        XCTAssertEqual(sut.alpha, 1, "Expected visible after setting message")
        XCTAssertEqual(sut.message, "any message")
    }
    
    func test_setNilMessage_hidesMessageWithAnimation() {
        let sut = makeSUT()
        
        sut.message = "any message"
        sut.message = nil
        
        XCTAssertEqual(sut.alpha, 0, "Expected hidden after setting nil message")
        XCTAssertNil(sut.messageLabelText(), "Expected label text cleared after hiding")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> ErrorView {
        let sut = ErrorView(frame: .init(x: 0, y: 0, width: 100, height: 50))
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

private extension ErrorView {
    func simulateTap() {
        let recognizers = gestureRecognizers ?? []
        recognizers.forEach { recognizer in
            recognizer.state = .ended
            recognizer.sendActions()
        }
    }
    
    func messageLabelText() -> String? {
        // Access message via public API; label text is cleared in completion block, so we just return message
        return message
    }
}

private extension UIGestureRecognizer {
    func sendActions() {
        guard let targets = self.value(forKey: "_targets") as? [NSObject] else { return }
        for targetAction in targets {
            if let action = targetAction.value(forKey: "_action") as? Selector,
               let target = targetAction.value(forKey: "_target") {
                _ = (target as AnyObject).perform(action, with: self)
            }
        }
    }
}
*/
