import Foundation
import GRDB
import Shared

extension Energy.Unit: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
        let integer = switch self {
        case .kilojoules: 1
        case .joules: 2
        case .kilocalories: 3
        case .calories: 4
        case .kilowattHours: 5
        }
        return integer.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Energy.Unit? {
        guard let value = Int.fromDatabaseValue(dbValue) else { return nil }
        switch value {
            case 1: return .kilojoules
            case 2: return .joules
            case 3: return .kilocalories
            case 4: return .calories
            case 5: return .kilowattHours
            default:
                assertionFailure("Unhandled energy unit value from database: \(value)")
                return nil
        }
    }
}

