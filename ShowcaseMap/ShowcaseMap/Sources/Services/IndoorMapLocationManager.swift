import CoreLocation

final class IndoorMapLocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private(set) var lastKnownLocation: CLLocationCoordinate2D?
    private(set) var lastKnownFloor: Int?
    private var singleLocationCompletion: ((Int?) -> Void)?

    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }

    func requestSingleLocation(completion: @escaping (Int?) -> Void) {
        singleLocationCompletion = completion
        locationManager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorizationChange?(manager.authorizationStatus)
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastKnownLocation = location.coordinate
        onLocationUpdate?(location.coordinate)

        let floorLevel = location.floor?.level
        if let floorLevel {
            lastKnownFloor = floorLevel
        }
        singleLocationCompletion?(floorLevel)
        singleLocationCompletion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
}
