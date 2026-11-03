//
//  Driver_KarmaApp.swift
//  Driver Karma
//
//  Created by Antony Rudkovsky on 2026-10-03.
//

import SwiftUI

@main
struct Driver_KarmaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                profile: .preview,
                overallScore: 87,
                lastSession: .preview,
                live: .preview
            )
        }
    }
}
