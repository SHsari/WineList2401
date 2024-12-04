//
//  XlsxReader.swift
//  WineLIst_2401
//
//  Created by Seokhyun Song on 2/1/24.
//
import Foundation
import CoreXLSX

let overPrice = 99999999

struct WineInfo {
    
    var korName: String = "-"
    var wineType: String = "-"
    var engName: String = "-"
    var province: String = "-"
    var grape: String = "-"
    var price: Int = overPrice
    
    var quantity: UInt = 0
    var onOff: Bool = false
    
    var priceAsString: String {
        get{
            if price != overPrice {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return formatter.string(from: NSNumber(value: price)) ?? "-"
            } else { return "-"}
        }
        set{
            price = Int(newValue) ?? overPrice
        }
    }
    
    var country: String {
        get{ return province.components(separatedBy: ", ").last ?? "" }
    }
}


enum SortCriteria: String {
    case price
    case engName
    case province
    case grape
}

enum xlsxError: Error {
    case openingXlsx
    case parsingXlsx
    case findingMenuSheet
}

protocol WineListDelegate: AnyObject {
    func wineList_OpenXlsxErr (_ model: WineListManager, error: Error)
}

class WineListManager {
    
    weak var delegate: WineListDelegate?
    
    var listRed: [WineInfo] = []
    var listWhite: [WineInfo] = []
    var listOther: [[WineInfo]] = []
    var OthersSection: [String] = []
    
    func parseXlsx(_ fileURL: URL) throws{
        let filePath = fileURL.path
        guard let file = XLSXFile(filepath: filePath) else { throw xlsxError.openingXlsx }
        var foundSheet = false
        do {
            guard let sharedStrings = try file.parseSharedStrings() else { throw xlsxError.parsingXlsx }
            for workBook in try file.parseWorkbooks() {
                for (name, path) in try file.parseWorksheetPathsAndNames(workbook: workBook) {
                    guard name == "메뉴판용" else { continue }
                    foundSheet = true
                    let workSheet = try file.parseWorksheet(at: path)
                    if var rows_ = workSheet.data?.rows{
                        rows_.removeFirst()
                        for row_ in rows_{
                            if let wine = singleRowToWine(row_, sharedStrings: sharedStrings){
                                rowToWineInfo(wine)
                            }
                        }
                    }
                }
                if !foundSheet {
                    throw xlsxError.findingMenuSheet
                }
            }
        }
    }
    
    
    private func rowToWineInfo(_ wine: WineInfo){
        let wineType = wine.wineType
        switch wineType{
        case "R", "r": listRed.append(wine)
        case "W", "w": listWhite.append(wine)
        default:
            if let index = OthersSection.firstIndex(of: wineType) {
                listOther[index].append(wine)
            } else {
                OthersSection.append(wineType)
                listOther.append([wine])
            }
        }
        sortWines(by: .price)
    }
    
    
    func singleRowToWine(_ row: Row, sharedStrings: SharedStrings) -> WineInfo? {
        if row.cells.count > 4 {
            var wine = WineInfo()
            
            let updateActions: [String: (String) -> Void] = [
                "A": { wine.korName = $0 },
                "B": { if $0.count > 10 { wine.engName = $0 } else { wine.engName = "-" }},
                "C": { wine.wineType = $0 },
                "D": { wine.province = $0 },
                "E": { wine.grape = $0 },
                "F": { if $0.count > 4 { wine.priceAsString = $0 } else { wine.priceAsString = "-" }},
                "G": { let quantity = UInt($0) ?? 0; if quantity > 0 { wine.quantity = quantity}},
                "H": { wine.onOff = self.onOffChar($0) }
            ]
            
            for cell in row.cells {
                let value: String
                if cell.type == .sharedString, let index = Int(cell.value ?? ""), index < sharedStrings.items.count {
                    value = sharedStrings.items[index].text ?? "-"
                } else {
                    value = cell.value ?? "-"
                }
                if let action = updateActions[cell.reference.column.value] {
                    action(value)
                }
            }
            if wine.onOff, wine.quantity != 0 {
                return wine
            }
        }
        return nil
    }
    
    private func onOffChar(_ char: String?) -> Bool {
        switch char{
        case "N", "n", "x", "X": return false
        default: return true
        }
    }
    
    func sortWines(by criterion: SortCriteria) {
        listRed.sort { sortBy(wine1: $0, wine2: $1, criterion: criterion) }
        listWhite.sort { sortBy(wine1: $0, wine2: $1, criterion: criterion) }
        for index in listOther.indices {
            listOther[index].sort {
                sortBy(wine1: $0, wine2: $1, criterion: criterion)
            }
        }
    }
    
    private func sortBy(wine1: WineInfo, wine2: WineInfo, criterion: SortCriteria) -> Bool {
        switch criterion {
        case .engName: return wine1.engName < wine2.engName
        case .province:
            if wine1.country == wine2.country{
                if wine1.province == wine2.province{
                    return wine1.price < wine2.price
                } else { return wine1.province < wine2.province }
            } else { return wine1.country < wine2.country }
        case .grape:
            if wine1.grape == wine2.grape {
                return wine1.price < wine2.price
            } else { return wine1.grape < wine2.grape }
        default: return wine1.price < wine2.price
        }
    }
}
    
    
    /*
    func sortBy<T: Comparable>(_ keyPath: KeyPath<WineInfo, T>) {
        listRed.sortBy(keyPath: keyPath, ascending: true)
        listWhite.sortBy(keyPath: keyPath, ascending: true)
        for key in listOtherGrouped.keys {
            listOtherGrouped[key]?.sortBy(keyPath: keyPath, ascending: true)
        }
    }*/


/*
extension Array where Element == WineInfo {
    mutating func sortBy<T: Comparable>(keyPath: KeyPath<Element, T>, ascending: Bool = true) {
        sort {
            let value1 = $0[keyPath: keyPath]
            let value2 = $1[keyPath: keyPath]
            return ascending ? value1 < value2 : value1 > value2
        }
    }
}*/

