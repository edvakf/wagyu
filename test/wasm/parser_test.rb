require "test_helper"

class WagyuTest < Minitest::Test
  def test_parse_simplest_function
    a = [
      0x00, 0x61, 0x73, 0x6d, # magic
      0x01, 0x00, 0x00, 0x00, # version
      # type section
      0x01, # id
      0x04, # payload_len
      0x01, # func type count
      0x60, # form (func is always 0x60)
      0x00, # param count
      0x00, # result count
      # function section
      0x03, # id
      0x02, # payload_len
      0x01, # type count
      0x00, # index in type section
      # code section
      0x0a, # id
      0x04, # payload_len
      0x01, # body count
      0x02, # body size
      0x00, # body
      0x0b, # end
    ]
    mod = parse(a)

    assert_equal(1, mod.version)
    assert_nil(mod.import_section)
    assert_nil(mod.table_section)
    assert_nil(mod.memory_section)
    assert_nil(mod.global_section)
    assert_nil(mod.export_section)
    assert_nil(mod.start_section)
    assert_nil(mod.element_section)
    assert_nil(mod.data_section)
    assert_nil(mod.name_section)
    assert_equal(1, mod.type_section.types.length)
    assert_equal(1, mod.function_section.types.length)
    assert_equal(1, mod.code_section.bodies.length)
  end

  def parse(a)
    binary = a.pack('C*')
    io = StringIO.new(binary)
    Wagyu::Wasm::Parser.new(io).parse
  end
end
