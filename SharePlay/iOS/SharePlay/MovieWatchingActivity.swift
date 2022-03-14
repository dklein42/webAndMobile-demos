//
//  MovieWatchingActivity.swift
//  SharePlay
//
//  Created by Daniel Klein on 14.03.22.
//

import Foundation
import GroupActivities

struct Movie: Codable, Hashable {
    var url: URL
    var title: String
    var description: String
}

struct MovieWatchingActivity: GroupActivity {
    let movie: Movie
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .watchTogether
        metadata.fallbackURL = movie.url
        metadata.title = movie.title
        return metadata
    }
}

