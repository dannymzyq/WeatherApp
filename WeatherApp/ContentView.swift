import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @Environment(\.colorScheme) var colorScheme      // Permite detectar el modo claro u oscuro
    @FocusState private var isSearchFieldFocused: Bool // Para controlar el foco del TextField
    
    @State private var cityName: String = "Detectando..."
    @State private var temperature: String = "--°C"
    @State private var feelsLike: String = "--°C"
    @State private var humidity: String = "--%"
    @State private var windSpeed: String = "-- km/h"
    @State private var weatherIcon: String = "01d"
    @State private var inputCity: String = ""
    @State private var forecast: [DailyWeather] = []
    
    // Región del mapa (usada en CustomMapView)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var weatherManager: WeatherManagerProtocol?
    let geocoder = CLGeocoder()
    
    init(weatherManager: WeatherManagerProtocol) {
        self.weatherManager = weatherManager
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Área fija: buscador
                searchBar
                    .padding(.top, 40)
                    .padding(.bottom, 10)
                    .background(Color.clear)
                
                // Área desplazable: resto del contenido
                ScrollView {
                    VStack(spacing: 15) {
                        cityNameView
                        weatherDetailsView
                        
                        // Usamos CustomMapView para actualizar la ubicación cuando se suelta el mapa
                        CustomMapView(region: $region) { newCenter in
                            reverseGeocodeAndUpdateWeather(center: newCenter)
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        forecastView
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                    // Aseguramos que el contenido ocupe al menos la altura de la pantalla menos el encabezado fijo
                    .frame(minHeight: UIScreen.main.bounds.height - 100)
                }
            }
        }
        .onAppear {
            let defaultCity = locationManager.cityName
            fetchWeather(city: defaultCity)
            fetchLocation(for: defaultCity)
        }
        .onAppear {
            let defaultCity = locationManager.cityName
            fetchWeather(city: defaultCity)
            fetchLocation(for: defaultCity)
        }
        .onChange(of: locationManager.cityName) { newCity in
            if !newCity.isEmpty {
                fetchWeather(city: newCity)
                fetchLocation(for: newCity)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var searchBar: some View {
        HStack {
            TextField("Ingresa una ciudad", text: $inputCity)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(8)
                .frame(width: 250, height: 45)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)   // Muestra "Buscar" en el teclado
                .onSubmit {
                    // Cuando se presiona el botón de retorno, se ejecuta la búsqueda y se cierra el teclado.
                    isSearchFieldFocused = false
                    fetchWeather(city: inputCity)
                    fetchLocation(for: inputCity)
                }
            
            Button(action: {
                isSearchFieldFocused = false // Quitar el foco del TextField (oculta el teclado)
                fetchWeather(city: inputCity)
                fetchLocation(for: inputCity)
            }) {
                Text("Buscar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(8)
                    .frame(width: 90, height: 45)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                    .shadow(radius: 5)
            }
        }
    }
    
    private var cityNameView: some View {
        Text(cityName)
            .font(.system(size: 40, weight: .bold))
            .foregroundColor(.white)
            .padding(.top, 5)
    }
    
    private var weatherDetailsView: some View {
        ZStack {
            // La animación en el fondo, con opacidad reducida para que actúe como decoración
            LottieView(animationName: getWeatherAnimation(code: weatherIcon))
                .frame(width: 150, height: 150)
                .opacity(0.3)
            VStack(spacing: 10) {
                // Texto principal (temperatura)
                Text(temperature)
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.white)
                // Otros detalles del clima
                VStack(spacing: 5) {
                    Text("Sensación: \(feelsLike)")
                    Text("Humedad: \(humidity)")
                    Text("Viento: \(windSpeed)")
                }
                .font(.title3)
                .foregroundColor(.white)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var forecastView: some View {
        VStack {
            Text("Pronóstico de los próximos días")
                .font(.title2)
                .foregroundColor(.white)
                .padding(.top, 10)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(forecast) { day in
                        VStack(spacing: 5) {
                            Text(formatDate(day.date))
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("\(Int(day.temp))°C")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        .frame(width: 110, height: 140)
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.3))
                        )
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 160)
        }
    }
    
    // MARK: - Utilidades
    
    private var backgroundGradient: LinearGradient {
        // Ejemplo de gradiente adaptativo: aquí puedes ajustar los colores para modo claro y oscuro
        if colorScheme == .dark {
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]),
                                  startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(gradient: Gradient(colors: [Color.blue, Color.white]),
                                  startPoint: .top, endPoint: .bottom)
        }
    }
    
    private func fetchWeather(city: String) {
        guard !city.isEmpty else { return }
        
        weatherManager?.fetchWeather(for: city) { data in
            if let data = data {
                DispatchQueue.main.async {
                    self.cityName = data.name
                    self.temperature = "\(Int(data.main.temp))°C"
                    self.feelsLike = "\(Int(data.main.feels_like))°C"
                    self.humidity = "\(data.main.humidity)%"
                    self.windSpeed = "\(Int(data.wind.speed)) km/h"
                    self.weatherIcon = data.weather.first?.icon ?? "01d"
                }
            }
        }
        weatherManager?.fetchForecast(for: city) { forecastData in
            if let forecastData = forecastData {
                DispatchQueue.main.async {
                    self.forecast = forecastData.map { entry in
                        DailyWeather(
                            date: entry.dt_txt,
                            temp: entry.main.temp,
                            icon: entry.weather.first?.icon ?? "01d"
                        )
                    }
                }
            }
        }
    }
    
    private func fetchLocation(for city: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { placemarks, _ in
            if let location = placemarks?.first?.location {
                DispatchQueue.main.async {
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    )
                }
            }
        }
    }
    
    /// Cuando el usuario suelta el mapa, se realiza reverse geocoding para obtener la ciudad
    private func reverseGeocodeAndUpdateWeather(center: CLLocationCoordinate2D) {
        let loc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        geocoder.reverseGeocodeLocation(loc) { placemarks, _ in
            guard let place = placemarks?.first,
                  let city = place.locality, !city.isEmpty else { return }
            DispatchQueue.main.async {
                self.fetchWeather(city: city)
                self.cityName = city
                self.inputCity = city // Sincroniza el TextField con la ciudad
            }
        }
    }
    
    private func formatDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: dateStr) {
            formatter.dateFormat = "E HH:mm"
            return formatter.string(from: date)
        }
        return dateStr
    }
    
    private func getWeatherAnimation(code: String) -> String {
        switch code {
        case "01d": return "sunny"
        case "01n": return "moon"
        case "02d", "02n": return "cloudy"
        case "03d", "03n": return "cloud"
        case "04d", "04n": return "clouds"
        case "09d", "09n": return "rain"
        case "10d", "10n": return "rainy"
        case "11d", "11n": return "storm"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "fog"
        default: return "cloud"
        }
    }
}
