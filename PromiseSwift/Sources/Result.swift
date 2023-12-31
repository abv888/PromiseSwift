import Foundation

public enum PromiseResult<T> {
    case value(T)
    case error(Error)
}

extension PromiseResult {
    public func valueOrThrow() throws -> T {
        switch self {
        case let .value(element):
            return element
        case let .error(error):
            throw error
        }
    }
    
    public func unbox() -> T? {
        switch self {
        case let .value(element):
            return element
        default:
            return nil
        }
    }
    
    public var maybeError: Error? {
        switch self {
        case let .error(error):
            return error
        default:
            return nil
        }
    }
    
    public func combining<R>(otherResult: PromiseResult<R>) -> PromiseResult<(T, R)> {
        switch self {
        case let .value(element):
            switch otherResult {
            case let .value(otherElement):
                return .value((element, otherElement))
            case let .error(error):
                return error.toPromiseResult()
            }
        case let .error(error):
            return error.toPromiseResult()
        }
    }
    
    public func map<U>(_ lambda: (_ transform: T) throws -> U) rethrows -> PromiseResult<U> {
        switch self {
        case let .value(element):
            return .value(try lambda(element))
        case let .error(error):
            return .error(error)
        }
    }
    
    public func catchMap<U>(_ lambda: (_ transform: T) throws -> U) -> PromiseResult<U> {
        switch self {
        case let .value(element):
            do {
                return .value(try lambda(element))
            } catch {
                return .error(error)
            }
        case let .error(error):
            return .error(error)
        }
    }
}

public func flatten<T>(_ result: PromiseResult<PromiseResult<T>>) -> PromiseResult<T> {
    switch result {
    case let .value(element):
        return element
    case let .error(error):
        return .error(error)
    }
}

extension Error {
    func toPromiseResult<T>() -> PromiseResult<T> {
        return .error(self)
    }
}
