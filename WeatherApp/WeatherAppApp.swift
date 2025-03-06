//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Danny Mendoza on 20/02/25.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(weatherManager: WeatherManager())
        }
    }
}
