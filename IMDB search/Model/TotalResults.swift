struct TotalResults: Codable {
    let page, totalResults, totalPages: Int
    let movies: [Movie]

    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case movies = "results"
    }
}
