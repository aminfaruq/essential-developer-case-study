//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Amin faruq on 06/01/26.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    // Kumpulan unit test untuk `URLSessionHTTPClient`.
    // Tujuan: Memastikan client melakukan request GET yang benar dan memetakan kombinasi data/response/error
    // menjadi hasil yang sesuai (success/failure).
    // Strategi: Menggunakan `URLProtocolStub` untuk mengintersep request jaringan dan menyuntikkan
    // data/response/error stub, serta mengamati request yang dikirim.
    
    // Mulai mengintersep seluruh request jaringan melalui `URLProtocolStub`.
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    // Hentikan intersepsi dan bersihkan stub/observer agar test lain tidak terpengaruh.
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // Memverifikasi bahwa `get(from:)` membuat request GET ke URL yang diberikan.
    func test_getFromUrl_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url, completion: { _ in })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // Jika terjadi error pada level request (mis. koneksi gagal), client harus mengembalikan error yang sama.
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    // Kombinasi tidak valid (data/response/error) harus menghasilkan kegagalan.
    // Tujuannya memastikan hanya kombinasi data + HTTPURLResponse (tanpa error) yang dianggap sukses.
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    // Jika menerima `HTTPURLResponse` valid dengan data, harus sukses dan mengembalikan pasangan (data, response).
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    // Jika menerima `HTTPURLResponse` valid dengan data `nil`, harus sukses dengan `Data()` kosong sebagai gantinya.
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    
    // MARK: Helpers
    
    /// Membuat instance `URLSessionHTTPClient` sebagai SUT dan mengaktifkan pelacakan memory leaks.
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    /// Helper untuk mengekstrak nilai sukses (data, response); gagal jika hasil bukan success.
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case .success(let data, let response):
            return (data, response)
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    /// Helper untuk mengekstrak error dari hasil; gagal jika hasil bukan failure.
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> NSError? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        
        switch result {
        case let .failure(error):
            return error as NSError
            
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    /// Helper sentral: menyetel stub (data/response/error), membuat SUT, melakukan request, dan menunggu hasil.
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClientResult!
        sut.get(from: anyURL(), completion: { result in
            receivedResult = result
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    /// Data sembarang untuk keperluan test.
    private func anyData() -> Data { Data(_: "any data".utf8) }
    
    /// `URLResponse` non-HTTP (tidak memiliki status code) untuk kasus tidak valid.
    private func nonHTTPURLResponse() ->  URLResponse { URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil) }
    
    /// `HTTPURLResponse` valid (status code default 200) untuk kasus valid.
    private func anyHTTPURLResponse() -> HTTPURLResponse { HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil) }
    
    
    /// Stub `URLProtocol` untuk mengintersep request jaringan.
    /// Memungkinkan kita mengamati request dan/atau menyuntikkan data/response/error tanpa jaringan sungguhan.
    private class URLProtocolStub: URLProtocol {
        
        // Menyimpan nilai stub yang akan dikembalikan saat request diintersep.
        private static var stub: Stub?
        // Callback opsional untuk mengamati setiap request yang masuk (mis. verifikasi URL/method).
        private static var requestObserver: ((URLRequest) -> Void)?
        
        // Paket nilai stub yang mungkin: data, response, dan/atau error.
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        /// Menyetel nilai stub global yang akan digunakan saat request diintersep.
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        /// Mendaftarkan observer untuk menerima setiap `URLRequest` yang datang.
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        /// Mulai mengintersep semua request dengan mendaftarkan kelas `URLProtocolStub`.
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        /// Berhenti mengintersep dan bersihkan state stub/observer.
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            
            stub = nil
            requestObserver = nil
        }
        
        /// Mengintersep semua request (kembalikan `true` agar URLLoadingSystem menggunakan stub ini).
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        /// Kembalikan request apa adanya (tidak perlu normalisasi).
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            // Jika ada observer, beritahu observer dengan request dan akhiri loading.
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            // Jika ada data stub, kirim ke client.
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            // Jika ada response stub, kirim ke client.
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            // Jika ada error stub, laporkan kegagalan ke client.
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            // Sinyalkan bahwa loading telah selesai.
            client?.urlProtocolDidFinishLoading(self)
        }
        
        /// Tidak ada pekerjaan khusus saat berhenti; diperlukan untuk memenuhi kontrak `URLProtocol`.
        override func stopLoading() {}
    }
}

