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
                let beats_per_min = songEntry[2] as! Int
                if songEntry.count == self.nFields {
                    self.songs.append(Song(id: String(describing: songEntry[0]),
                                           title: String(describing: songEntry[0]),
                                           artist: String(describing: songEntry[1]),
                                           bpm: (beats_per_min),
                                           chords: songEntry[3] as! Array<Array<Any?>>))
                } else {
                    print("getSongs: Received unexpected number of fields: \(songEntry.count) instead of \(self.nFields).")
                }
            }
        } catch {
            print("getSongs: NETWORKING ERROR")
        }
    }

}

