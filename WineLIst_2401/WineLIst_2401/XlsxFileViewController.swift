//
//  XlsxViewController.swift
//  WineLIst_2401
//
//  Created by Seokhyun Song on 2/1/24.

let fileKey = "SelectedFileNameKey"
let fileListKey = "ExistingFilesKey"

enum FileErrors: Error {
    case NoXlsxFile
    case DirUnreachable
    case OpenXlsx
    case ParsingXlsx
}

import UIKit

class XlsxFileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FileSelectionDelegate {
    
    @IBOutlet weak var xlsxTableView: UITableView!
    @IBOutlet weak var xlsxInfoLabel: UILabel!
    @IBOutlet weak var selectButtonView: UIView!
    @IBOutlet weak var selectButtonViewHeightsConstraints: NSLayoutConstraint!
    @IBOutlet weak var selectButton: UIButton!
    @IBAction func selectButton(_ sender: UIButton) {
        if let indexPathRow = indexPathRow {
            UserDefaults.standard.set(xlsxFileNames[indexPathRow], forKey: fileKey)
            UserDefaults.standard.set(xlsxFileNames, forKey: fileListKey)
            presentWineVC(xlsxFilesURL[indexPathRow])
        }
    }
    
    var fileSelection = FileSelectionManager()
    private var xlsxFileInfoList: [String] = []
    private var xlsxFileNames: [String] = []
    private var xlsxFilesURL: [URL] = []
    private var indexPathRow: Int? = nil
    

    
    private func presentWineVC(_ fileURL: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let wineVC = storyboard.instantiateViewController(withIdentifier: "wineViewController") as? WineViewController {
            wineVC.modalPresentationStyle = .fullScreen
            wineVC.modalTransitionStyle = .crossDissolve
            wineVC.fileURL = fileURL
            self.present(wineVC, animated: true, completion: nil)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.xlsxFileNames = fileSelection.xlsxNameList
        self.xlsxFileInfoList = fileSelection.InfoListString
        self.xlsxFilesURL = fileSelection.xlsxFilesURL
    
        xlsxTableView.delegate = self
        xlsxTableView.dataSource = self
        xlsxTableView.register(UITableViewCell.self, forCellReuseIdentifier: "XlsxCell")
        
        selectButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if xlsxFileNames.count == 0{
            showAlert(FileErrors.NoXlsxFile)
        } 
        /*else if !fileSelection.shouldFindNewFile {
            presentWineVC(fileSelection.selectedFileURL!)
        }*/
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return xlsxFileNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "XlsxCell", for: indexPath)
        cell.textLabel?.text = xlsxFileNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 체크 마크 추가
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        indexPathRow = indexPath.row
        xlsxInfoLabel.text = xlsxFileInfoList[indexPath.row]
        
        if selectButton.isHidden {
            selectButtonViewHeightsConstraints.constant = 52
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
            self.selectButton.isHidden = false
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 다른 셀 선택 시 체크 마크 제거
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}

extension XlsxFileViewController {
    func fileSelection_DirNotReachable(_ model: FileSelectionManager) {
        // View에 오류 메시지 표시
        showAlert(FileErrors.DirUnreachable)
    }
    
    func wineList_OpenXlsxErr(_ model: WineListManager, error: FileErrors) {
        showAlert(error)
    }

    private func showAlert(_ error: FileErrors) {
        var message: String
        var title: String
        switch error {
            
        case .NoXlsxFile:
            message = "Xlsx file does not Exist"
            title = "No Xlsx Files"
        case .DirUnreachable:
            message = "Can't access to Document Directory"
            title = "Directory Access"
        case .OpenXlsx:
            message = "Failed to open Xlsx file"
            title = "OpenXlsx Error"
        case .ParsingXlsx:
            message = "Fail during parsing Xlsx file"
            title = "Xlsx Parsing Error"
            
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
