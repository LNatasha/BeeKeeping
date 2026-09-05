import CoreLocation
import Observation

@Observable
class LocationFetcher: NSObject, CLLocationManagerDelegate {
    var coordinate: (latitude: Double, longitude: Double)?
    var isFetching: Bool = false

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        isFetching = true
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            isFetching = false
        @unknown default:
            isFetching = false
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isFetching else { return }
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            isFetching = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isFetching = false
        guard let loc = locations.last else { return }
        coordinate = (latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isFetching = false
    }
}
