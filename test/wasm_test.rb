require "test_helper"

class WasmTest < Minitest::Test
  def test_compile_add
    # (module
    #  (func $add (export "add") (param $lhs i32) (param $rhs i32) (result i32)
    #   get_local $lhs
    #   get_local $rhs
    #   i32.add)
    # )
    a = [
      0x00, 0x61, 0x73, 0x6d, # magic
      0x01, 0x00, 0x00, 0x00, # version
      # type section
      0x01, 0x07, 0x01, 0x60, 0x02, 0x7f, 0x7f, 0x01, 0x7f,
      # function section
      0x03, 0x02, 0x01, 0x00,
      # export section
      0x07, 0x07, 0x01, 0x03, 0x61, 0x64, 0x64, 0x00, 0x00,
      # code section
      0x0a, 0x09, 0x01, 0x07, 0x00, 0x20, 0x00, 0x20, 0x01, 0x6a, 0x0b,
    ]
    instance = compile(a)

    result = instance.exports.add(1, 2)
    assert_equal(3, result)
  end

  def compile(a)
    binary = a.pack('C*')
    klass = Wagyu::Wasm.compile(binary)
    Struct.new(:exports).new(klass.new)
  end
end
