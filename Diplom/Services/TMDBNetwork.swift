//
//  TMDBNetwork.swift
//  Diplom
//
//  Created by ryan on 06.11.2021.
//

import Foundation

class TMDBNetwork {

    private init() {}

    static let shared = TMDBNetwork()

    var configuration: TMDBConfiguration?

    var totalPages: Int = Int.max

    let decoder: JSONDecoder = {
        let jd = JSONDecoder()
        jd.keyDecodingStrategy = .convertFromSnakeCase
        return jd
    }()

    let CONFIGURATION_URL = "https://api.themoviedb.org/3/configuration"
    let NOW_PLAYING_URL = "https://api.themoviedb.org/3/movie/now_playing"

    let API_KEY = "f2f24e86fbed06fc3104ffa456c7d483"

    func fecthSearch(searchTerm: String, completionHandler: @escaping (MovieFeed?, Error?) -> ()) {
        let URL_BASE = "https://api.themoviedb.org/3/search/movie?api_key=\(API_KEY)&query=\(searchTerm)"
        guard let url = URL(string: URL_BASE) else {return}

        var searchResult: MovieFeed?
        var feedError: Error?
        let networkDispatchGroup = DispatchGroup()


        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            if let err = err {
                print("Failed to fetch apps:", err)
                feedError = MovieError.decodingError
                networkDispatchGroup.leave()
                return
            }
//                        print(data)
//                        print(String(data: data!, encoding: .utf8))
            guard let data = data else {return}

            do {
                searchResult = try self.decoder.decode(MovieFeed.self, from: data)

                //print(searchResult)
                feedError = MovieError.decodingError
                networkDispatchGroup.leave()

            } catch let jsonErr {
                debugPrint("Failed to decode json:", jsonErr)
                networkDispatchGroup.leave()
            }

        }.resume()
        networkDispatchGroup.notify(queue: .main) {
            completionHandler(searchResult, feedError)
        }
    }

    typealias FetchHandler = ((MovieFeed?, Error?) -> Void)

    func fetchMovies(page: Int, completionHandler: @escaping FetchHandler) {
        var feed: MovieFeed?
        var feedError: Error?
        let endpoint = "\(NOW_PLAYING_URL)?api_key=\(API_KEY)&page=\(page)&region=us"
        let networkDispatchGroup = DispatchGroup()

        if configuration == nil {
            networkDispatchGroup.enter()
            fetchConfiguration {
                networkDispatchGroup.leave()
            }
        }

        networkDispatchGroup.enter()
        guard let url = URL(string: endpoint) else {
            feedError = MovieError.urlError
            networkDispatchGroup.leave()
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, err in
            guard let data = data else {
                feedError = MovieError.invalidData
                networkDispatchGroup.leave()
                return
            }
            do {
                feed = try self.decoder.decode(MovieFeed.self, from: data)

                networkDispatchGroup.leave()

            } catch {
                feedError = MovieError.decodingError
                networkDispatchGroup.leave()
                return
            }
        }.resume()


        networkDispatchGroup.notify(queue: .main) {
            completionHandler(feed, feedError)
        }
    }

    func fetchConfiguration(completionHandler: @escaping () -> Void) {
        guard let url = URL(string: "\(CONFIGURATION_URL)?api_key=\(API_KEY)") else {
            completionHandler()
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                completionHandler()
                return
            }

            do {
                let config = try self.decoder.decode(TMDBConfiguration.self, from: data)
                self.configuration = config
                completionHandler()

                return
            } catch {
                completionHandler()
                return
            }
        }.resume()
    }

    func fetchCast(movieId: String, completionHandler: @escaping ((CastFeed, Error?) -> Void)) {
        let endpoint = "https://api.themoviedb.org/3/movie/\(movieId)/credits?api_key=\(API_KEY)"
        guard let url = URL(string: endpoint) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }

            do {
                let castFeed = try self.decoder.decode(CastFeed.self, from: data)
                completionHandler(castFeed, nil)
            } catch {
                print("Failed to decode cast data.")
                return
            }
        }.resume()
    }
}
