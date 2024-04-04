//// A type that represents a remote data fetch

import gleam/list
import gleam/option.{type Option, None, Some}

pub type RemoteData(a, error) {
  NotAsked
  Loading
  Failure(error)
  Success(a)
}

/// Map a function over the success value of a RemoteData
///
/// ## Examples
/// ```gleam
/// map(over: Success(42), with: fn(x) { x * 2 })
/// // -> Success(84)
/// ```
///
/// ```gleam
/// map(over: Failure("error"), with: fn(x) { x * 2 })
/// // -> Failure("error")
/// ```
pub fn map(
  over data: RemoteData(a, error),
  with mapper: fn(a) -> b,
) -> RemoteData(b, error) {
  case data {
    NotAsked -> NotAsked
    Loading -> Loading
    Failure(error) -> Failure(error)
    Success(a) -> Success(mapper(a))
  }
}

/// Map a function over the success value of two RemoteData values
///
/// ## Examples
/// ```gleam
/// map_2(over: Success(42), over_2: Success(2), with: fn(a, b) { a + b })
/// // -> Success(44)
/// ```
///
/// ```gleam
/// map_2(over: Failure("error"), over_2: Success(2), with: fn(a, b) { a + b })
/// // -> Failure("error")
/// ```
pub fn map2(
  over data1: RemoteData(a, error),
  over2 data2: RemoteData(b, error),
  with mapper: fn(a, b) -> c,
) -> RemoteData(c, error) {
  case data1, data2 {
    Success(a), Success(b) -> Success(mapper(a, b))
    Failure(error), _ | _, Failure(error) -> Failure(error)
    NotAsked, _ | _, NotAsked -> NotAsked
    Loading, _ | _, Loading -> Loading
  }
}

/// The same as `map2`, but with three RemoteData values
/// Check `map2` for more details
pub fn map3(
  over data1: RemoteData(a, error),
  over_2 data2: RemoteData(b, error),
  over_3 data3: RemoteData(c, error),
  with mapper: fn(a, b, c) -> d,
) -> RemoteData(d, error) {
  case data1, data2, data3 {
    Success(a), Success(b), Success(c) -> Success(mapper(a, b, c))
    Failure(error), _, _ | _, Failure(error), _ | _, _, Failure(error) ->
      Failure(error)
    NotAsked, _, _ | _, NotAsked, _ | _, _, NotAsked -> NotAsked
    Loading, _, _ | _, Loading, _ | _, _, Loading -> Loading
  }
}

/// Map a function over the error value of a RemoteData
///
/// ## Examples
/// ```gleam
/// map_error(over: Success(42), with: fn(_) { "error" })
/// // -> Success(42)
/// ```
///
/// ```gleam
/// map_error(over: Failure(42), with: fn(_) { "error" })
/// // -> Failure("error")
/// ```
pub fn map_error(
  over data: RemoteData(a, error),
  with mapper: fn(error) -> error_b,
) -> RemoteData(a, error_b) {
  case data {
    NotAsked -> NotAsked
    Loading -> Loading
    Failure(error) -> Failure(mapper(error))
    Success(a) -> Success(a)
  }
}

/// Chain a function that returns a RemoteData over the success value of a RemoteData
///
/// ## Examples
/// ```gleam
/// try(over: Success(42), with: fn(x) { Success(x * 2) })
/// // -> Success(84)
/// ```
///
/// ```gleam
/// try(over: Failure("error"), with: fn(x) { Success(x * 2) })
/// // -> Failure("error")
/// ```
///
/// ```gleam
/// try(over: Success(42), with: fn(x) { Failure("error") })
/// // -> Failure("error")
/// ```
pub fn try(
  over data: RemoteData(a, error),
  with mapper: fn(a) -> RemoteData(b, error),
) -> RemoteData(b, error) {
  case data {
    NotAsked -> NotAsked
    Loading -> Loading
    Failure(error) -> Failure(error)
    Success(a) -> mapper(a)
  }
}

/// Unwrap a RemoteData, providing a default value if the data is not Success
/// ## Examples
/// ```gleam
/// unwrap(data: Success(42), or: 0)
/// // -> 42
/// ```
///
/// ```gleam
/// unwrap(data: Failure("error"), or: 0)
/// // -> 0
/// ```
pub fn unwrap(data: RemoteData(a, error), or default: a) -> a {
  case data {
    Success(a) -> a
    _ -> default
  }
}

/// Convert a RemoteData to an Option
/// ## Examples
/// ```gleam
/// to_option(data: Success(42))
/// // -> Some(42)
/// ```
///
/// ```gleam
/// to_option(data: Failure("error"))
/// // -> None
/// ```
pub fn to_option(data: RemoteData(a, error)) -> Option(a) {
  case data {
    Success(a) -> Some(a)
    _ -> None
  }
}

/// Convert an Option to a RemoteData
/// ## Examples
/// ```gleam
/// from_option(option: Some(42), or: "error")
/// // -> Success(42)
/// ```
///
/// ```gleam
/// from_option(option: None, or: "error")
/// // -> Failure("error")
/// ```
pub fn from_option(option: Option(a), or error: error) -> RemoteData(a, error) {
  case option {
    Some(a) -> Success(a)
    None -> Failure(error)
  }
}

/// Convert a RemoteData to a Result
/// If the data is NotAsked or Loading, it will be converted to an Error with the provided error
/// ## Examples
/// ```gleam
/// to_result(data: Success(42), or: "error")
/// // -> Ok(42)
/// ```
///
/// ```gleam
/// to_result(data: Failure("error"), or: "another error")
/// // -> Error("error")
/// ```
///
/// ```gleam
/// to_result(data: Loading, or: "another error")
/// // -> Error("another error")
/// ```
pub fn to_result(
  data: RemoteData(a, error),
  or error: error,
) -> Result(a, error) {
  case data {
    Success(a) -> Ok(a)
    Failure(error) -> Error(error)
    _ -> Error(error)
  }
}

/// Convert a Result to a RemoteData
/// ## Examples
/// ```gleam
/// from_result(result: Ok(42))
/// // -> Success(42)
/// ```
///
/// ```gleam
/// from_result(result: Error("error"))
/// // -> Failure("error")
/// ```
pub fn from_result(result: Result(a, error)) -> RemoteData(a, error) {
  case result {
    Ok(a) -> Success(a)
    Error(error) -> Failure(error)
  }
}

/// Convert a list of RemoteData to a RemoteData of a list
/// ## Examples
/// ```gleam
/// from_list([Success(42), Success(43)])
/// // -> Success([42, 43])
/// ```
///
/// ```gleam
/// from_list([Success(42), Failure("error")])
/// // -> Failure("error")
/// ```
pub fn from_list(
  data_list: List(RemoteData(a, error)),
) -> RemoteData(List(a), error) {
  use acc, data <- list.fold(data_list, Success([]))

  use acc_value, data_value <- map2(acc, data)
  list.append(acc_value, [data_value])
}

/// Check if a RemoteData is a Success
/// ## Examples
/// ```gleam
/// is_not_asked(Success(42))
/// // -> False
/// ```
///
/// ```gleam
/// is_not_asked(NotAsked)
/// // -> True
/// ```
pub fn is_not_asked(data: RemoteData(_, _)) -> Bool {
  case data {
    NotAsked -> True
    _ -> False
  }
}

/// Check if a RemoteData is a Success
/// ## Examples
/// ```gleam
/// is_loading(Success(42))
/// // -> True
/// ```
///
/// ```gleam
/// is_loading(Failure("error"))
/// // -> False
/// ```
pub fn is_loading(data: RemoteData(_, _)) -> Bool {
  case data {
    Loading -> True
    _ -> False
  }
}

/// Check if a RemoteData is a Success
/// ## Examples
/// ```gleam
/// is_failure(Success(42))
/// // -> True
/// ```
///
/// ```gleam
/// is_failure(Failure("error"))
/// // -> False
/// ```
pub fn is_failure(data: RemoteData(_, _)) -> Bool {
  case data {
    Failure(_) -> True
    _ -> False
  }
}

/// Check if a RemoteData is a Success
/// ## Examples
/// ```gleam
/// is_success(Success(42))
/// // -> True
/// ```
///
/// ```gleam
/// is_success(Failure("error"))
/// // -> False
/// ```
pub fn is_success(data: RemoteData(_, _)) -> Bool {
  case data {
    Success(_) -> True
    _ -> False
  }
}
