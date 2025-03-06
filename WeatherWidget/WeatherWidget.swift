import WidgetKit
import SwiftUI

// Define el modelo de entrada para el widget
struct WeatherEntry: TimelineEntry {
    let date: Date
    let temperature: String
    let city: String
    // Puedes agregar más datos si lo deseas, como icono, etc.
}

// Proveedor que suministra entradas al widget
struct WeatherProvider: TimelineProvider {
    // Vista de marcador de posición
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), temperature: "--°C", city: "Ciudad")
    }
    
    // Vista instantánea (snapshot)
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let entry = WeatherEntry(date: Date(), temperature: "25°C", city: "Lima")
        completion(entry)
    }
    
    // Provee la línea de tiempo para el widget (actualiza cada hora en este ejemplo)
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        // Aquí podrías llamar a tu API o usar datos cacheados.
        let currentDate = Date()
        let entry = WeatherEntry(date: currentDate, temperature: "25°C", city: "Lima")
        
        // Actualiza cada 60 minutos
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 60, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// Vista principal del widget
struct WeatherWidgetEntryView: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    var entry: WeatherEntry
    
    var body: some View {
        ZStack {
            if widgetRenderingMode == .fullColor {
                // Fondo a pantalla completa
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .white]),
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                // Fallback para iOS < 17 o modo vibrante
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .white]),
                    startPoint: .top, endPoint: .bottom
                )
            }
            
            VStack {
                Text(entry.city)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(entry.temperature)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
        .containerBackground(.fill, for: .widget)
        .containerShape(Rectangle())           // Deshabilita márgenes de contenido
    }
}

// Define el widget
@main
struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Clima Actual")
        .description("Muestra el clima actual de tu ciudad.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

extension WidgetConfiguration
{
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration
    {
        if #available(iOSApplicationExtension 17.0, *)
        {
            return self.contentMarginsDisabled()
        }
        else
        {
            return self
        }
    }
}
