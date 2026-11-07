import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Runs before the Flutter engine starts, so the flag is set before Hive
    // opens any box. Fox promises its data never leaves the device, and both
    // Hive's Documents directory and Application Support are otherwise part of
    // iCloud/iTunes device backups.
    AppDelegate.excludeFoxDataFromBackup()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private static func excludeFoxDataFromBackup() {
    let fileManager = FileManager.default
    let directories: [FileManager.SearchPathDirectory] = [
      .documentDirectory,
      .applicationSupportDirectory,
    ]
    for directory in directories {
      guard let url = fileManager.urls(for: directory, in: .userDomainMask).first else {
        continue
      }
      do {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var mutableURL = url
        try mutableURL.setResourceValues(values)
      } catch {
        NSLog("Fox: could not exclude \(url.path) from backup: \(error)")
      }
    }
  }
}
