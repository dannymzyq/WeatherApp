import SwiftUI
import MapKit

struct WeatherMapView: View {
    var city: String
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428), // Coordenadas iniciales (Lima)
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    @State private var locationManager = CLLocationManager()
    
    var body: some View {
        VStack {
            Text("Ubicación de \(city)")
                .font(.headline)
                .foregroundColor(.white)
            
            Map(coordinateRegion: $region, showsUserLocation: true)
                .frame(height: 200)
                .cornerRadius(10)
                .padding()
                .onAppear {
                    getCoordinates(for: city)
                }
        }
    }
    
    func getCoordinates(for city: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { (placemarks, error) in
            if let placemark = placemarks?.first, let location = placemark.location {
                DispatchQueue.main.async {
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    )
                }
            } else {
                print("❌ Error obteniendo coordenadas: \(error?.localizedDescription ?? "Desconocido")")
            }
        }
    }
}
