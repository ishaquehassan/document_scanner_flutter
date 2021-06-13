import Flutter
import UIKit
import WeScan

public class SwiftDocumentScannerFlutterPlugin: NSObject, FlutterPlugin {
    
    var rootViewController: UIViewController?
    var result: FlutterResult?
    
    
    public override init() {
        super.init()
        rootViewController =
            (UIApplication.shared.delegate?.window??.rootViewController)!;
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "document_scanner_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftDocumentScannerFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        
        if(call.method == "camera"){
            camera()
        }else if(call.method == "gallery"){
            gallery()
        }else{
            result(FlutterMethodNotImplemented)
        }
        
    }
    
    private func camera(image: UIImage? = nil){
        let scannerViewController: ImageScannerController = ImageScannerController(image: image)
        scannerViewController.imageScannerDelegate = self
        rootViewController?.present(scannerViewController, animated:true, completion:nil)
    }
    
    func gallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        rootViewController?.present(imagePicker, animated: true)
    }
}

extension SwiftDocumentScannerFlutterPlugin : ImageScannerControllerDelegate{
    
    public func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        scanner.dismiss(animated: true)
        let path = Utils.getScannedFile(results: results)
        result?(path)
    }
    
    public func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true)
    }
    
    public func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        scanner.dismiss(animated: true)
    }
}

extension SwiftDocumentScannerFlutterPlugin: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        camera(image: image)
    }
}
