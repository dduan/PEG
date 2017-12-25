infix operator !!

// TODO: probably don't want to make this public.
public func !!<T>(value: T?, errorMessage: String) -> T {
    guard let value = value else {
        fatalError(errorMessage)
    }

    return value
}
