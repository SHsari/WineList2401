//
//  WineLIst_2401
//
//  Created by Seokhyun Song on 1/3/24.
//  model part of the xlsx View.

import Foundation

class XlsxFileManager {
    
    private var xlsxFileList: [XlsxFileInfo] = []
    var InfoListString: [String] = []
    var xlsxNameList: [String] = []
    
    private struct XlsxFileInfo {
        var name: String
        var size: NSNumber?
        var creationDate: Date?
        var modificationDate: Date?
    }
    
    //Model
    init() {
        print("XlsxManager Init")
        
        let fileManager = FileManager.default
        do {
            // Document 디렉토리의 URL 얻기
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let directoryContents = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            
            // .xlsx 확장자를 가진 파일 필터링
            let xlsxFiles = directoryContents.filter { $0.pathExtension == "xlsx" }
            xlsxFileList = xlsxFiles.compactMap { url -> XlsxFileInfo? in
                let filePath = url.path
                if let attributes = try? fileManager.attributesOfItem(atPath: filePath) {
                    return XlsxFileInfo(
                        name: url.lastPathComponent,
                        size: attributes[.size] as? NSNumber,
                        creationDate: attributes[.creationDate] as? Date,
                        modificationDate: attributes[.modificationDate] as? Date
                    )
                }
                return nil
            }
        } catch {
            print("Error: \(error)")
        }
        fileInfoAsString()
        
    }
    private func fileInfoAsString() {
        print("file Info As String")
        
        for selectedFile in xlsxFileList {
            
            xlsxNameList.append(selectedFile.name)
            
            var fileInfoAsString: String = "File Name: \n  \(selectedFile.name)\n\n"
            if let fileSize = selectedFile.size{
                fileInfoAsString += "Size: \n  \(fileSize) Byte\n\n"
            }
            if let creationDate = selectedFile.creationDate {
                fileInfoAsString += "Created: \n  \(creationDate)\n\n"
            }
            if let modificationDate = selectedFile.modificationDate {
                fileInfoAsString += "Modified: \n  \(modificationDate)"
            }
            self.InfoListString.append(fileInfoAsString)
        }
        return
    }
}



