//
//  Utils.swift
//  document_scanner_flutter
//
//  Created by Ishaq Hassan on 13/06/2021.
//

import Foundation
import WeScan

class Utils {
    
    static var channelName:String = "document_scanner_flutter"
    
    static func getScannedFile(results: ImageScannerResults) -> String? {
        var path: String?
        if(results.doesUserPreferEnhancedScan && results.enhancedScan != nil){
            path = saveImage(image: results.enhancedScan!.image)
            return path
        }
        path = saveImage(image: results.croppedScan.image)
        return path
    }

    static private func saveImage(image: UIImage) -> String? {
        
        guard let documentsDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { return nil }
        
        let fileName = uniqueFileNameWithExtention(fileExtension: "jpg")
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return nil }

        do {
            try data.write(to: fileURL)
            return fileURL.absoluteString
        } catch let error {
            print("error saving file with error", error)
            return nil
        }
        
    }


    static private func uniqueFileNameWithExtention(fileExtension: String) -> String {
        let uniqueString: String = ProcessInfo.processInfo.globallyUniqueString
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmsss"
        let dateString: String = formatter.string(from: Date())
        let uniqueName: String = "\(uniqueString)_\(dateString)"
        if fileExtension.count > 0 {
            let fileName: String = "\(uniqueName).\(fileExtension)"
            return fileName
        }
        
        return uniqueName
    }
}
