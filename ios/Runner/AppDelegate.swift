import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        ThreadedPlugin.register(with: self.registrar(forPlugin: "ThreadedPlugin")!)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

class ThreadedPlugin: NSObject, FlutterPlugin {
    var thread: Thread?
    let channel: FlutterMethodChannel
    var stop: Bool = false

    public init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name:"ios_callback_channel", binaryMessenger: registrar.messenger())
        let instance = ThreadedPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.publish(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "start" {
            self.thread = Thread(block: {
                while(!self.stop) {
                    let val = Int.random(in: 0...10_000_000)
                    self.channel.invokeMethod("ios_callback", arguments: val)
                    Thread.sleep(forTimeInterval: 0.01)
                }
            })
            self.thread?.start()
        }

        result(nil)
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        registrar.publish(NSNull())
        stop = true
        // Hack to wait for the other thread to finish
        Thread.sleep(forTimeInterval: 0.1)
    }
}
