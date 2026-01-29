// EssentialFeed Architecture Overview

// This document summarizes the main layers and their responsibilities, with an ASCII diagram that renders everywhere.

// Layers

// - Domain (pure, stable): core models and truths of the app
//   - Example: `FeedItem`
// - Use Case / Interactor (application logic): orchestrates steps to fulfill a feature
//   - Example: `RemoteFeedLoader`
// - Boundary / Infrastructure (I/O and adapters): talks to the outside world and maps raw data into domain
//   - Abstraction: `HTTPClient`
//   - Implementation: `URLSessionHTTPClient`
//   - Mapping: `FeedItemsMapper`

// End-to-End Flow (ASCII)

/*
UI / Caller
    |
    v
RemoteFeedLoader (Use Case)
    |
    | depends on
    v
HTTPClient (protocol)  <---- implemented by ----  URLSessionHTTPClient  ---- uses ---->  URLSession
    ^
    |
    | returns (Data, HTTPURLResponse) or Error
    |
RemoteFeedLoader
    |
    | validates & maps
    v
FeedItemsMapper
    |
    v
[FeedItem] (Domain)
*/

// Error Contract

// `RemoteFeedLoader.Error` exposes stable, domain-focused categories:
// - `connectivity`: transport/request-level error from the HTTP client
// - `invalidData`: non-200 HTTP response or payload that fails decoding/mapping

// Testing Strategy

// - Use Case tests (`RemoteFeedLoaderTests`):
//   - Mock `HTTPClient` to drive success/failure
//   - Assert domain results (`[FeedItem]` or `.invalidData` / `.connectivity`)
// - HTTP Client tests (`URLSessionHTTPClientTests`):
//   - Intercept with `URLProtocol` stub to verify method/URL and all data/response/error combinations
// - Mapper tests (`FeedItemsMapperTests`, if present):
//   - Assert 200-only acceptance and JSON decoding correctness

// Notes

// - Keep the domain pure and stable; adapt the outside world via mappers and boundary abstractions.
// - Composition (wiring concrete dependencies) should happen at the app edge, not in the domain.
## SOP Checklist

- Do: Jaga domain model (mis. `FeedItem`) tetap murni dan stabil (tanpa detail jaringan/UI/storage)
- Do: Pusatkan validasi + mapping di mapper (mis. `FeedItemsMapper`), terapkan 200-only & fail fast pada JSON invalid
- Do: Abstraksikan boundary via protokol (mis. `HTTPClient`) dan uji implementasinya (mis. `URLSessionHTTPClient`)
- Do: Tulis test pada use case (mis. `RemoteFeedLoader`) memakai mock/stub boundary untuk menegakkan kontrak domain
- Do: Lakukan composition (wiring dependency konkret) di tepi aplikasi, bukan di domain/use case
- Don’t: Mem-parsing JSON langsung di UI/use case; gunakan mapper
- Don’t: Mengikat use case/domain pada framework tertentu (URLSession/Alamofire/CoreData)
- Don’t: Mengekspos error teknis infra ke domain/UI; petakan ke error domain (mis. `.connectivity`, `.invalidData`)
- Don’t: Mencampur komposisi dengan logika domain; jaga agar dependency injection terpusat

