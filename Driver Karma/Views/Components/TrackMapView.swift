import SwiftUI
import MapKit

struct TrackMapView: UIViewRepresentable {
    let track: [CLLocationCoordinate2D]

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.pointOfInterestFilter = .excludingAll
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.removeOverlays(map.overlays)
        map.removeAnnotations(map.annotations)
        guard track.count > 1 else { return }

        let line = MKPolyline(coordinates: track, count: track.count)
        map.addOverlay(line)

        let start = MKPointAnnotation()
        start.coordinate = track.first!
        start.title = "Start"
        let end = MKPointAnnotation()
        end.coordinate = track.last!
        end.title = "End"
        map.addAnnotations([start, end])

        map.setVisibleMapRect(
            line.boundingMapRect,
            edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
            animated: false
        )
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let line = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }
            let renderer = MKPolylineRenderer(polyline: line)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
    }
}