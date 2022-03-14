//
//  MovieCoordinationManager.swift
//  SharePlay
//
//  Created by Daniel Klein on 14.03.22.
//

import Foundation
import Combine
import GroupActivities

class MovieCoordinationManager {
    static let shared = MovieCoordinationManager()
    
    @Published var groupSession: GroupSession<MovieWatchingActivity>?
    @Published var currentMovie: Movie?

    private var subscriptions: Set<AnyCancellable> = .init()

    private init() {
        Task {
            for await groupSession in MovieWatchingActivity.sessions() {
                self.groupSession = groupSession
                
                subscriptions.removeAll()
                
                groupSession.$state.sink { [weak self] state in
                    if case .invalidated = state {
                        // Setting groupSession to nil invalidates session state
                        self?.groupSession = nil
                        self?.subscriptions.removeAll()
                    }
                }.store(in: &subscriptions)
                
                groupSession.join()
                
                groupSession.$activity.sink { [weak self] activity in
                    self?.currentMovie = activity.movie
                }.store(in: &subscriptions)
            }
        }
    }

    func shareActivity(movie: Movie) async {
        let activity = MovieWatchingActivity(movie: movie)
        
        switch await activity.prepareForActivation() {
        case .activationDisabled:
            // No sharing requested, just play
            self.currentMovie = movie
        case .activationPreferred:
            // Sharing requested, so activate and play
            do {
                // This triggers activity observation above
                _ = try await activity.activate()
            }
            catch {
                print("Error while activating: \(error)")
            }
        case .cancelled:
            break
        default:
            break
        }
    }
}

