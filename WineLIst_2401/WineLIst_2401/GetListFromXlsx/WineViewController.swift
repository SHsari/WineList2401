//
//  ViewController.swift
//  WineLIst_2401
//
//  Created by Seokhyun Song on 1/2/24.
//

import UIKit

class WineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var title_ENG: UILabel!
    @IBOutlet var title_KOR: UILabel!
    
    private let engTitle = ["Red Wine", "White Wine", "Other Wines"]
    private let korTitle = ["레드 와인", "화이트 와인", "기타"]
    private var scIndex = 0
    private var isLandscape = true
    
    private var wineList = WineListManager()
    var fileURL: URL?

    @IBAction func scDidChange(_ sender: UISegmentedControl) {
        scIndex = sender.selectedSegmentIndex
        self.title_ENG.text = engTitle[scIndex]
        self.title_KOR.text = korTitle[scIndex]
        tableView.reloadData()
    }
    
    @IBOutlet weak var sortByButton: UIButton!
    private var criteriaDict: [String: SortCriteria] = [
        "Price": .price,
        "Name(Eng)": .engName,
        "Province": .province,
        "Grape": .grape
    ]
    private func sortByPopUp() {
        let criteria = ["Price", "Province", "Grape", "Name(Eng)"]
        var optionsArray: [UIAction] = []
        for title in criteria {
            let option = UIAction(title: title, handler: { _ in
                self.wineList.sortWines(by: self.criteriaDict[title] ?? .price)
                self.tableView.reloadData()
            })
            optionsArray.append(option)
        }
        let optionsMenu = UIMenu(title: "Sort By:", options: .displayInline, children: optionsArray)
        
        sortByButton.menu = optionsMenu
    }
    
    
    /*
    private func presentXlsxVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let xlsxVC = storyboard.instantiateViewController(withIdentifier: "XlsxFileViewController") as? XlsxFileViewController {
            xlsxVC.fileSelection = self.fileSelector
            xlsxVC.modalPresentationStyle = .formSheet
            xlsxVC.modalTransitionStyle = .crossDissolve
            self.present(xlsxVC, animated: true, completion: nil)
        }
    }*/
    
  //  private func presentSettingsVC
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = fileURL {
            do{
                try wineList.parseXlsx(url)
            } catch let error as xlsxError{
                showAlert(error)
            } catch {
                showAlertWithMessage("An unknown error occurred.")
            }
    
            tableView.reloadData()
        }
        
        tableView.register(PortraitCell.nib(), forCellReuseIdentifier: PortraitCell.identifier)
        tableView.register(LandscapeCell.nib(), forCellReuseIdentifier: LandscapeCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        sortByPopUp()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if scIndex == 2 {
            return wineList.OthersSection.count
            // 기타와인에 다양한 종류가 있기 때문에 섹션 표시를 넣어야 합니다.
        } else { return 1 }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if scIndex == 2 {
            return wineList.OthersSection[section]    }
        else {  return nil  }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch scIndex {
        case 0: return wineList.listRed.count
        case 1: return wineList.listWhite.count
        case 2: return wineList.listOther[section].count
        default: return wineList.listRed.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var viewList: [WineInfo] = []
        
        switch scIndex{
        case 0: viewList = wineList.listRed
        case 1: viewList = wineList.listWhite
        case 2: viewList = wineList.listOther[indexPath.section]
        default: viewList = wineList.listRed
        }
        
        if isLandscape {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LandscapeCell", for: indexPath) as! LandscapeCell
            cell.korNameLabel.text = viewList[indexPath.row].korName
            cell.engNameLabel.text = viewList[indexPath.row].engName
            cell.priceLabel.text = viewList[indexPath.row].priceAsString
            cell.provinceLabel.text = viewList[indexPath.row].province
            cell.grapeLabel.text = viewList[indexPath.row].grape
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PortraitCell", for: indexPath) as! PortraitCell
            cell.korNameLabel.text = viewList[indexPath.row].korName
            cell.engNameLabel.text = viewList[indexPath.row].engName
            cell.priceLabel.text = viewList[indexPath.row].priceAsString
            cell.provinceLabel.text = viewList[indexPath.row].province
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0 // 원하는 헤더 높이 설정
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            isLandscape = UIDevice.current.orientation.isLandscape
            tableView.reloadData()
        })
    }
}
extension WineViewController {

    private func showAlert(_ error: xlsxError) {
        var message: String
        var title: String
        switch error {
        case .openingXlsx:
            message = "Cannot Open Xlsx File"
            title = "Cannot Open Xlsx File"
        case .parsingXlsx:
            message = "Cannot Parse Xlsx File"
            title = "Cannot Parse Xlsx File"
        case .findingMenuSheet:
            message = "Cannot Find Sheet For Menu"
            title = "Cannot Find Sheet For Menu"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlertWithMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
