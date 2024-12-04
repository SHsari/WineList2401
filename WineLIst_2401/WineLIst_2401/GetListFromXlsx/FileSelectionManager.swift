//
//  WineLIst_2401
//
//  Created by Seokhyun Song on 1/3/24.
//  model part of the xlsx View.

import Foundation


protocol FileSelectionDelegate: AnyObject {
    func fileSelection_DirNotReachable(_ model: FileSelectionManager)
}

class FileSelectionManager {

    weak var delegate: FileSelectionDelegate?

    private var xlsxFileList: [XlsxFileInfo] = []
    
    private let fileManager = FileManager.default
    private var documentDir: URL? = nil
    private var contentsInDir: [URL] = []
    
    var InfoListString: [String] = []
    var xlsxNameList: [String] = []
    var xlsxFilesURL: [URL] = []
    var selectedFileURL: URL?
    
    
    private struct XlsxFileInfo {
        var name: String
        var size: NSNumber?
        var creationDate: Date?
        var modificationDate: Date?
    }
    
    //Model
    init() {
        do {
            documentDir = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            contentsInDir = try fileManager.contentsOfDirectory(at: documentDir!, includingPropertiesForKeys: nil)
        } catch {
            delegate?.fileSelection_DirNotReachable(self)
        }
        fileLoader()
    }
    
    func shouldFindNewFile() -> Bool {
        if let loadedList = UserDefaults.standard.array(forKey: fileListKey) as? [String], loadedList == xlsxNameList{
            if let fileName = UserDefaults.standard.string(forKey: fileKey){  
                let fileURL = documentDir!.appendingPathComponent(fileName)
                    if FileManager.default.fileExists(atPath: fileURL.path){
                    self.selectedFileURL = fileURL
                    return false
                }
            }
        }
        UserDefaults.standard.removeObject(forKey: fileKey)
        UserDefaults.standard.removeObject(forKey: fileKey)
        return true
    }
    
   private func fileLoader(){ //xlsxFiles URL 과 xlsxFileList 를 설
        xlsxFilesURL = contentsInDir.filter { $0.pathExtension == "xlsx" }
        xlsxFileList = xlsxFilesURL.compactMap { url -> XlsxFileInfo? in
            if let attributes = try? fileManager.attributesOfItem(atPath: url.path) {
                return XlsxFileInfo(
                    name: url.lastPathComponent,
                    size: attributes[.size] as? NSNumber,
                    creationDate: attributes[.creationDate] as? Date,
                    modificationDate: attributes[.modificationDate] as? Date
                )
            }
            return nil
        }
        fileInfoAsString()
    }
    
    private func fileInfoAsString() {// fileInfoAsString을 설정해줌.
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
