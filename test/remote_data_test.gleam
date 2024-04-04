import gleeunit
import remote_data as rd
import gleam/list
import gleam/int
import gleam/option.{None, Some}
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn map_test() {
  [
    #(rd.NotAsked, rd.NotAsked),
    #(rd.Loading, rd.Loading),
    #(rd.Failure("error"), rd.Failure("error")),
    #(rd.Success(1), rd.Success(2)),
  ]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.map(with: fn(x) { x + 1 })
    |> should.equal(expected)
  })
}

pub fn map_2_test() {
  let inputs = [
    #(rd.NotAsked, rd.NotAsked),
    #(rd.Loading, rd.Loading),
    #(rd.Failure("error"), rd.Failure("error")),
    #(rd.Success(1), rd.Success(2)),
  ]

  inputs
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    list.each(inputs, fn(input_output_2) {
      let #(input_2, expected_2) = input_output_2

      let result =
        input
        |> rd.map2(over2: input_2, with: fn(x, y) { x + y })

      should.be_true(list.contains([expected, expected_2], result))
    })
  })
}

pub fn map_error_test() {
  [
    #(rd.NotAsked, rd.NotAsked),
    #(rd.Loading, rd.Loading),
    #(rd.Failure("error"), rd.Failure("another error")),
    #(rd.Success(1), rd.Success(1)),
  ]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.map_error(with: fn(_) { "another error" })
    |> should.equal(expected)
  })
}

pub fn unwrap_test() {
  [
    #(rd.NotAsked, 0),
    #(rd.Loading, 0),
    #(rd.Failure("error"), 0),
    #(rd.Success(1), 1),
  ]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.unwrap(or: 0)
    |> should.equal(expected)
  })
}

pub fn try_test() {
  [
    #(rd.NotAsked, rd.NotAsked),
    #(rd.Loading, rd.Loading),
    #(rd.Failure("error"), rd.Failure("error")),
    #(rd.Success("1"), rd.Success(1)),
    #(rd.Success("NaN"), rd.Failure("not a number")),
  ]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.try(fn(n) {
      case int.parse(n) {
        Ok(n) -> rd.Success(n)
        Error(_) -> rd.Failure("not a number")
      }
    })
    |> should.equal(expected)
  })
}

pub fn to_option_test() {
  [
    #(rd.NotAsked, None),
    #(rd.Loading, None),
    #(rd.Failure("error"), None),
    #(rd.Success(1), Some(1)),
  ]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.to_option()
    |> should.equal(expected)
  })
}

pub fn from_option_test() {
  [#(None, rd.Failure("error")), #(Some(1), rd.Success(1))]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.from_option(or: "error")
    |> should.equal(expected)
  })
}

pub fn from_result_test() {
  [#(Error("error"), rd.Failure("error")), #(Ok(1), rd.Success(1))]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.from_result
    |> should.equal(expected)
  })
}

pub fn from_list() {
  [
    #([], rd.Success([])),
    #([rd.Success(1), rd.Success(2), rd.Success(3)], rd.Success([1, 2, 3])),
    #([rd.Failure("error"), rd.Success(2), rd.Success(3)], rd.Failure("error")),
    #([rd.Success(1), rd.NotAsked, rd.Success(3)], rd.NotAsked),
    #([rd.Success(1), rd.Success(2), rd.Loading], rd.Loading),
  ]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.from_list
    |> should.equal(expected)
  })
}

pub fn is_not_asked_test() {
  [
    #(rd.NotAsked, True),
    #(rd.Loading, False),
    #(rd.Failure("error"), False),
    #(rd.Success(1), False),
  ]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.is_not_asked
    |> should.equal(expected)
  })
}

pub fn is_loading_test() {
  [
    #(rd.NotAsked, False),
    #(rd.Loading, True),
    #(rd.Failure("error"), False),
    #(rd.Success(1), False),
  ]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.is_loading
    |> should.equal(expected)
  })
}

pub fn is_failure_test() {
  [
    #(rd.NotAsked, False),
    #(rd.Loading, False),
    #(rd.Failure("error"), True),
    #(rd.Success(1), False),
  ]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.is_failure
    |> should.equal(expected)
  })
}

pub fn is_success_test() {
  [
    #(rd.NotAsked, False),
    #(rd.Loading, False),
    #(rd.Failure("error"), False),
    #(rd.Success(1), True),
  ]
  |> list.map(fn(input_output) {
    let #(input, expected) = input_output

    input
    |> rd.is_success
    |> should.equal(expected)
  })
}
