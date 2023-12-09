import Flutter
import UIKit
import CoreLocation

public class GeocodingHandler: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "geocodingChannel", binaryMessenger: registrar.messenger())
        let instance = GeocodingHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getCityName" {
            guard let args = call.arguments as? [String: Any],
                  let latitude = args["latitude"] as? Double,
                  let longitude = args["longitude"] as? Double else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }

            let location = CLLocation(latitude: latitude, longitude: longitude)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first else {
                    result("Unknown")
                    return
                }
                let cityName = placemark.locality ?? "Unknown"
                result(cityName)
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
