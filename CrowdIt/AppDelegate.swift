import UIKit
import GoogleMaps

// 1
let googleApiKey = "ENTER_KEY_HERE"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    //2
    GMSServices.provideAPIKey(googleApiKey)
    return true
  }
}
