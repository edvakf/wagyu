require "test_helper"

class WasmTest < Minitest::Test
  def test_add
    open("#{__dir__}/data/add.wasm") do |f|
      klass = Wagyu::Wasm.compile_streaming(f)
      instance = Struct.new(:exports).new(klass.new)

      result = instance.exports.add(1, 2)
      assert_equal(3, result)
    end
  end

  def test_square
    open("#{__dir__}/data/square.wasm") do |f|
      klass = Wagyu::Wasm.compile_streaming(f)
      instance = Struct.new(:exports).new(klass.new)

      result = instance.exports.square(3)
      assert_equal(9, result)
    end
  end

  def test_rms
    open("#{__dir__}/data/rms.wasm") do |f|
      klass = Wagyu::Wasm.compile_streaming(f)
      instance = Struct.new(:exports).new(klass.new)

      result = instance.exports.rms(3.0, 4.0)
      assert_equal(5.0, result)
    end
  end
end
