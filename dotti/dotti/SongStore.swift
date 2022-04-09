//
//  SongStore.swift
//  dotti
//
//  Created by Mary Keta on 3/30/22.
//

import Foundation

final class SongStore: ObservableObject {
    static let shared = SongStore() // create one instance of the class to be shared
    private init() {} // and make the constructor private so no other
                      // instances can be created
    @Published private(set) var songs = [Song]()
    private let nFields = 4

    private let serverUrl = "https://34.139.144.50/"

//    func postChatt(_ chatt: Chatt) async {
//        let jsonObj = ["chatterID": ChatterID.shared.id,
//                       "message": chatt.message]
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
//            print("postChatt: jsonData serialization error")
//            return
//        }
//
//        guard let apiUrl = URL(string: serverUrl+"postauth/") else {
//            print("postChatt: Bad URL")
//            return
//        }
//
//        var request = URLRequest(url: apiUrl)
//        request.httpMethod = "POST"
//        request.httpBody = jsonData
//
//        do {
//            let (_, response) = try await URLSession.shared.data(for: request)
//
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
//                print("postChatt: HTTP STATUS: \(httpStatus.statusCode)")
//                return
//            } else {
//                await getChatts()
//            }
//        } catch {
//            print("postChatt: NETWORKING ERROR")
//        }
//    }

    @MainActor
    func getSongs() async {
        guard let apiUrl = URL(string: serverUrl+"getsong/") else {
            print("getSong: Bad URL")
            return
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getSongs: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }

            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getSongs: failed JSON deserialization")
                return
            }
            let songsReceived = jsonObj["songs"] as? [[Any]] ?? []
            print("RECEIVED")
            print(songsReceived)

            self.songs = [Song]()
            for songEntry in songsReceived {
                print(songEntry)
                if songEntry.count == self.nFields {
                    self.songs.append(Song(id: String(describing: songEntry[0]),
                                           title: String(describing: songEntry[0]),
                                           artist: String(describing: songEntry[1]),
                                           bpm: String(describing: songEntry[2]),
                                           chords: songEntry[3] as! Array<Array<Any?>>))
                } else {
                    print("getSongs: Received unexpected number of fields: \(songEntry.count) instead of \(self.nFields).")
                }
            }
        } catch {
            print("getSongs: NETWORKING ERROR")
        }
    }

//    func addUser(_ idToken: String?) async {
//        guard let idToken = idToken else {
//            return
//        }
//
//        let jsonObj = ["clientID": "461601811012-mupq1mi8t66aeppqrf7s04bcslooetrs.apps.googleusercontent.com",
//                    "idToken" : idToken]
//
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
//            print("addUser: jsonData serialization error")
//            return
//        }
//
//        guard let apiUrl = URL(string: serverUrl+"adduser/") else {
//            print("addUser: Bad URL")
//            return
//        }
//
//        var request = URLRequest(url: apiUrl)
//        request.httpMethod = "POST"
//        request.httpBody = jsonData
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
//                print("addUser: HTTP STATUS: \(httpStatus.statusCode)")
//                return
//            }
//
//            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
//                print("addUser: failed JSON deserialization")
//                return
//            }
//
//            ChatterID.shared.id = jsonObj["chatterID"] as? String
//            ChatterID.shared.expiration = Date()+(jsonObj["lifetime"] as! TimeInterval)
//
//            guard let _ = ChatterID.shared.id else {
//                return
//            }
//            ChatterID.shared.save()
//        } catch {
//            print("addUser: NETWORKING ERROR")
//        }
//    }
}

