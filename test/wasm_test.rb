require "test_helper"

class WasmTest < Minitest::Test
  def test_add
    instance = instantiate("add.wasm")
    result = instance.exports.add(1, 2)
    assert_equal(3, result)
  end

  def test_rem
    instance = instantiate("rem.wasm")
    result = instance.exports.rem(13, 4)
    assert_equal(1, result)
  end

  def test_square
    instance = instantiate("square.wasm")
    result = instance.exports.square(3)
    assert_equal(9, result)
  end

  def test_and
    instance = instantiate("and.wasm")
    assert_equal(0, instance.exports.and(0, 0))
    assert_equal(0, instance.exports.and(0, 1))
    assert_equal(0, instance.exports.and(1, 0))
    assert_equal(1, instance.exports.and(1, 1))
  end

  def test_or
    instance = instantiate("or.wasm")
    assert_equal(0, instance.exports.or(0, 0))
    assert_equal(1, instance.exports.or(0, 1))
    assert_equal(1, instance.exports.or(1, 0))
    assert_equal(1, instance.exports.or(1, 1))
  end

  def test_xor
    instance = instantiate("xor.wasm")
    assert_equal(0, instance.exports.xor(0, 0))
    assert_equal(1, instance.exports.xor(0, 1))
    assert_equal(1, instance.exports.xor(1, 0))
    assert_equal(0, instance.exports.xor(1, 1))
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

  def test_big_small_or_equal
    instance = instantiate("big_small_or_equal.wasm")
    assert_equal(1, instance.exports.big_small_or_equal(11, 10))
    assert_equal(2, instance.exports.big_small_or_equal(9, 10))
    assert_equal(3, instance.exports.big_small_or_equal(10, 10))
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

  def test_br_table
    instance = instantiate("br_table.wasm")
    result = instance.exports.switch(0)
    assert_equal(111, result)
    result = instance.exports.switch(2)
    assert_equal(333, result)
    result = instance.exports.switch(3)
    assert_equal(333, result)
    result = instance.exports.switch(-1)
    assert_equal(333, result)
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

  def test_global
    import_object = {
      env: {
        initial: 3
      }
    }
    instance = instantiate("global.wasm", import_object)
    result = instance.exports.counter()
    assert_equal(4, result)
    result = instance.exports.counter()
    assert_equal(5, result)
  end

  def test_memory
    str = "abcde"
    len = str.length
    mem = Wagyu::Wasm::Memory.new(initial: 1, maximum: 10)
    mem.buffer[0, len] = str
    import_object = {
      env: {
        str: mem
      }
    }
    instance = instantiate("reverse.wasm", import_object)
    instance.exports.reverse(len)
    assert_equal(str.reverse, mem.buffer[0, len])
  end

  def test_export_memory
    instance = instantiate("memory.wasm")
    result = instance.exports.sum(3)
    assert_equal(6, result)
    instance.exports.mem.i32_store(16, 5)
    result = instance.exports.sum(5)
    assert_equal(15, result)
  end

  def instantiate(file, import_object = nil)
    open("#{__dir__}/data/#{file}") do |f|
      Wagyu::Wasm.instantiate_streaming(f, import_object)
    end
  end
end
