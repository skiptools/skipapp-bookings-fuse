#if canImport(MapKit)
import MapKit
#endif
import SwiftUI

struct MapView : View {
    let latitude: Double
    let longitude: Double

    var body: some View {
        #if os(Android)
        // on Android platforms, we use com.google.maps.android.compose.GoogleMap within in a ComposeView
        ComposeView { MapComposer(latitude: latitude, longitude: longitude) }
        #else
        // on Darwin platforms, we use the new SwiftUI Map type
        if #available(iOS 17.0, macOS 14.0, *) {
            Map(initialPosition: .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))))
        } else {
            Text("Map requires iOS 17")
                .font(.title)
        }
        #endif
    }
}

#if SKIP
// skip.yml: implementation("com.google.maps.android:maps-compose:4.3.3")
import com.google.maps.android.compose.__
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng

struct MapComposer : ContentComposer {
    let latitude: Double
    let longitude: Double
    
    @Composable func Compose(context: ComposeContext) {
        GoogleMap(cameraPositionState: rememberCameraPositionState {
            position = CameraPosition.fromLatLngZoom(LatLng(latitude, longitude), Float(12.0))
        })
    }
}

#endif
