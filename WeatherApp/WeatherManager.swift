import Foundation


protocol WeatherManagerProtocol {
    func fetchWeather(for city: String, completion: @escaping (WeatherData?) -> Void)
    func fetchForecast(for city: String, completion: @escaping ([ForecastEntry]?) -> Void)
}

class WeatherManager: WeatherManagerProtocol {
    let apiKey = "aac2cb388422cf66ac3654026296d861" // 🔥 Reemplázalo con tu clave real de OpenWeatherMap
    let baseUrl = "https://api.openweathermap.org/data/2.5/weather?units=metric&lang=es"
    let forecastUrl = "https://api.openweathermap.org/data/2.5/forecast?units=metric&lang=es"
    
    func fetchWeather(for city: String, completion: @escaping (WeatherData?) -> Void) {
        let urlString = "\(baseUrl)&q=\(city)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let decoder = JSONDecoder()
                if let decodedData = try? decoder.decode(WeatherData.self, from: data) {
                    DispatchQueue.main.async {
                        completion(decodedData)
                    }
                }
            }
        }.resume()
    }
    
    func fetchForecast(for city: String, completion: @escaping ([ForecastEntry]?) -> Void) {
        let urlString = "\(forecastUrl)&q=\(city)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let decoder = JSONDecoder()
                if let decodedData = try? decoder.decode(ForecastData.self, from: data) {
                    DispatchQueue.main.async {
                        completion(decodedData.list)
                    }
                }
            }
        }.resume()
    }
    
    func test() {
        print("BCP ->")
    }
}
