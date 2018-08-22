require "test_helper"

class WasmTest < Minitest::Test
  def test_add
    instance = instantiate("add.wasm")
    result = instance.exports.add(1, 2)
    assert_equal(3, result)
  end

  def test_square
    instance = instantiate("square.wasm")
    result = instance.exports.square(3)
    assert_equal(9, result)
  end

  def test_rms
    instance = instantiate("rms.wasm")
    result = instance.exports.rms(3.0, 4.0)
    assert_equal(5.0, result)
  end

  def test_fact
    instance = instantiate("fact.wasm")
    result = instance.exports.fact(10)
    assert_equal(3628800, result)
  end

  def test_sum
    instance = instantiate("sum.wasm")
    result = instance.exports.sum(10)
    assert_equal(55, result)
  end

  def test_control01
    instance = instantiate("control01.wasm")
    result = instance.exports.test()
    assert_equal(1, result)
  end

  def test_control02
    instance = instantiate("control02.wasm")
    result = instance.exports.test()
    assert_equal(1, result)
  end

  def test_control03
    instance = instantiate("control03.wasm")
    result = instance.exports.test()
    assert_equal(1, result)
  end

  def test_import
    import_object = {
      util: {
        multiply: ->(a, b){a * b}
      }
    }
    instance = instantiate("import.wasm", import_object)
    result = instance.exports.twice(3)
    assert_equal(6, result)
  end

  def instantiate(file, import_object = nil)
    open("#{__dir__}/data/#{file}") do |f|
      Wagyu::Wasm.instantiate_streaming(f, import_object)
    end
  end
end
