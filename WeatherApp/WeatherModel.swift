import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
    let wind: Wind
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

struct Wind: Codable {
    let speed: Double
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct ForecastData: Codable {
    let list: [ForecastEntry]
}

struct ForecastEntry: Codable {
    let dt_txt: String
    let main: Main
    let weather: [Weather]
}

struct DailyWeather: Identifiable {
    let id = UUID()
    let date: String
    let temp: Double
    let icon: String
}
