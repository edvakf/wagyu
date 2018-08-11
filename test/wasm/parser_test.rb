require "test_helper"

class ParserTest < Minitest::Test
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
      0x00, # body (local count = 0)
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
    assert_equal(1, mod.type_section.types[0].form)
    assert_equal(1, mod.type_section.types[0].params)
    assert_equal(1, mod.type_section.types[0].results)
    assert_equal(1, mod.function_section.types.length)
    assert_equal(1, mod.code_section.bodies.length)
  end

  def test_parse_simplest_function
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
    mod = parse(a)

    assert_equal(1, mod.version)
    assert_nil(mod.import_section)
    assert_nil(mod.table_section)
    assert_nil(mod.memory_section)
    assert_nil(mod.global_section)
    assert_nil(mod.start_section)
    assert_nil(mod.element_section)
    assert_nil(mod.data_section)
    assert_nil(mod.name_section)
    assert_equal(1, mod.type_section.types.length)
    assert_equal(:func, mod.type_section.types[0].form)
    assert_equal(1, mod.function_section.types.length)
    assert_equal(1, mod.export_section.exports.length)
    assert_equal('add', mod.export_section.exports[0].field)
    assert_equal(:function, mod.export_section.exports[0].kind)
    assert_equal(0, mod.export_section.exports[0].index)
    assert_equal(1, mod.code_section.bodies.length)
  end

  def parse(a)
    binary = a.pack('C*')
    io = StringIO.new(binary)
    Wagyu::Wasm::Parser.new(io).parse
  end
end
