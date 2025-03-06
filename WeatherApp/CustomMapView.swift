import SwiftUI
import MapKit
import CoreLocation

struct CustomMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var onRegionDidChange: (CLLocationCoordinate2D) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if uiView.region.center.latitude != region.center.latitude ||
           uiView.region.center.longitude != region.center.longitude {
            uiView.setRegion(region, animated: true)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        init(_ parent: CustomMapView) {
            self.parent = parent
        }
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let center = mapView.region.center
            DispatchQueue.main.async {
                self.parent.region = mapView.region
                self.parent.onRegionDidChange(center)
            }
        }
    }
}
