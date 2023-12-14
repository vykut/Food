import Foundation
import Shared
import GRDB

extension Quantity.Unit: DatabaseValueConvertible {
    var intValue: Int {
        switch self {
            case .kilograms: 1
            case .grams: 2
            case .decigrams: 3
            case .centigrams: 4
            case .milligrams: 5
            case .micrograms: 6
            case .nanograms: 7
            case .picograms: 8
            case .ounces: 9
            case .pounds: 10
            case .stones: 11
            case .metricTons: 12
            case .shortTons: 13
            case .carats: 14
            case .ouncesTroy: 15
            case .slugs: 16
            case .cups: 17
            case .teaspoons: 18
            case .tablespoons: 19
        }
    }
    
    public var databaseValue: DatabaseValue {
        intValue.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Quantity.Unit? {
        guard let value = Int.fromDatabaseValue(dbValue) else { return nil }
        switch value {
            case 1: return .kilograms
            case 2: return .grams
            case 3: return .decigrams
            case 4: return .centigrams
            case 5: return .milligrams
            case 6: return .micrograms
            case 7: return .nanograms
            case 8: return .picograms
            case 9: return .ounces
            case 10: return .pounds
            case 11: return .stones
            case 12: return .metricTons
            case 13: return .shortTons
            case 14: return .carats
            case 15: return .ouncesTroy
            case 16: return .slugs
            case 17: return .cups
            case 18: return .teaspoons
            case 19: return .tablespoons
            default:
                assertionFailure("Unhandled quantity unit value from database: \(value)")
                return nil
        }
    }
}
