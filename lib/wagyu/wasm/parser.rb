require "wagyu/wasm/module"

module Wagyu::Wasm
  class Parser
    WASM_MAGIC = "\0asm"

    class ParseError < StandardError; end

    def initialize(io)
      @io = io
    end

    def parse()
      read_magic
      version = read_version

      mod = Module.new(version)
      loop do
        break if @io.eof?
        read_section(mod)
      end

      mod
    end

    private

    # common building blocks
    def read_bytes(n)
      @io.read(n)
    end

    def read_uint8
      read_bytes(1).ord
    end

    def read_uint32
      read_bytes(4).unpack('V')[0]
    end

    def read_f32
      read_bytes(4).unpack('e')[0]
    end

    def read_f64
      read_bytes(8).unpack('E')[0]
    end

    # https://en.wikipedia.org/wiki/LEB128#Decode_unsigned_integer
    def read_varuint
      result = 0
      shift = 0
      loop do
        byte = read_uint8
        result |= (byte & 0b0111_1111) << shift
        break if byte & 0b1000_0000 == 0 # byte.nobits?(0b1000_0000)
        shift += 7
      end
      result
    end

    # https://en.wikipedia.org/wiki/LEB128#Decode_signed_integer
    def read_varint(size)
      result = 0
      shift = 0
      loop do
        byte = read_uint8
        result |= (byte & 0b0111_1111) << shift
        shift += 7
        if byte & 0b1000_0000 == 0 # byte.nobits?(0b1000_0000)
          if (shift < size) && (byte & 0b0100_0000 != 0) # byte.anybits?(0b0100_0000)
            result |= (~0 << shift)
          end
          break
        end
      end
      result
    end

    def read_varint32
      read_varint(32)
    end

    def read_varint64
      read_varint(64)
    end

    def read_language_type
      case read_uint8
      when 0x7f then :i32
      when 0x7e then :i64
      when 0x7d then :f32
      when 0x7c then :f64
      when 0x70 then :anyfunc
      when 0x60 then :func
      when 0x40 then :empty_block_type
      else
        raise ParseError, 'unknown language type'
      end
    end

    def read_value_type
      case read_uint8
      when 0x7f then :i32
      when 0x7e then :i64
      when 0x7d then :f32
      when 0x7c then :f64
      else
        raise ParseError, 'unknown value type'
      end
    end

    def read_block_type
      case read_uint8
      when 0x7f then :i32
      when 0x7e then :i64
      when 0x7d then :f32
      when 0x7c then :f64
      when 0x40 then :empty_block_type
      else
        raise ParseError, 'unknown block type'
      end
    end

    def read_elem_type
      case read_uint8
      when 0x70 then :anyfunc
      else
        raise ParseError, 'unknown elem type'
      end
    end

    def read_external_kind
      case read_uint8
      when 0 then :function
      when 1 then :table
      when 2 then :memory
      when 3 then :global
      else
        raise ParseError, 'unknown kind'
      end
    end

    # Module
    def read_magic
      magic = read_bytes(4)
      raise ParseError, 'magic does not match' unless WASM_MAGIC == magic
    end

    def read_version
      read_uint32
    end

    def read_section(mod)
      id = read_varuint # varuint32
      payload_len = read_varuint # varuint32 (there isn't quite a use case for this in ruby)

      case id
      when TypeID
        mod.type_section = read_type_section
      #when ImportID
        #mod.import_section = read_type_section
      when FunctionID
        mod.function_section = read_function_section
      #when TableID
        #mod.table_section = read_table_section
      #when MemoryID
        #mod.memory_section = read_memory_section
      #when GlobalID
        #mod.global_section = read_global_section
      when ExportID
        mod.export_section = read_export_section
      #when StartID
        #mod.start_section = read_start_section
      #when ElementID
        #mod.element_section = read_element_section
      when CodeID
        mod.code_section = read_code_section
      #when DataID
        #mod.data_section = read_data_section
      #when UnknownID
        #mod.name_section = read_name_section
      else
        raise ParseError, 'undefined section found'
      end
    end

    # TypeSection
    def read_type_section
      types = Array.new(read_varuint) do
        read_func_type
      end
      TypeSection.new(types)
    end

    def read_func_type
      form = read_language_type
      raise ParseError, 'form of func_type must be `func` language type' unless form == :func

      params = Array.new(read_varuint) do
        read_value_type
      end

      results = Array.new(read_varuint) do
        read_value_type
      end

      FuncType.new(form, params, results)
    end

    # FunctionSection
    def read_function_section
      types = Array.new(read_varuint) do
        read_varuint
      end
      FunctionSection.new(types)
    end

    # ExportSection
    def read_export_section
      exports = Array.new(read_varuint) do
        read_export
      end
      ExportSection.new(exports)
    end

    def read_export
      field_len = read_varuint
      field_str = read_bytes(field_len)

      kind = read_external_kind
      index = read_varuint
      ExportEntry.new(field_str, kind, index)
    end

    # CodeSection
    def read_code_section
      bodies = Array.new(read_varuint) do
        read_function_body
      end
      CodeSection.new(bodies)
    end

    def read_function_body
      body_size = read_varuint # size of function body to follow, in bytes

      locals = Array.new(read_varuint) do
        read_local_entry
      end

      code = read_code(body_size)

      FunctionBody.new(locals, code)
    end

    def read_local_entry
      count = read_varuint # number of local variables of the following type
      type = read_value_type # type of the variables
      LocalEntry.new(count, type)
    end

    def read_code(body_size)
      start = @io.pos
      code = []
      loop do
        op = read_op
        code << op
        break if op[:op] == :end && @io.pos = start + body_size
      end
      code
    end

    def read_op
      case read_uint8
      # control flow operators
      when 0x00 then {op: :unreachable}
      when 0x01 then {op: :nop}
      when 0x02 then {op: :block, sig: read_block_type} # varint7
      when 0x03 then {op: :loop, sig: read_block_type} # varint7
      when 0x04 then {op: :if, sig: read_block_type} # varint7
      when 0x05 then {op: :else}
      when 0x0b then {op: :end}
      when 0x0c then {op: :br, relative_depth: read_varuint} # varuint32
      when 0x0d then {op: :br_if, relative_depth: read_varuint} # varuint32
      when 0x0e then
        target_table = Array.new(read_varuint) do
          read_varuint # varuint32
        end
        default_target = read_varuint
        {op: :br_table, target_table: target_table, default_target: default_target}
      when 0x0f then {op: :return}
      # call operators
      when 0x10 then {op: :call, function_index: read_varuint} # varuint32
      when 0x11 then {op: :call_index, type_index: read_varuint, reserved: read_varuint == 1} # veruint32, varuint1
      # parametric operators
      when 0x1a then {op: :drop}
      when 0x1b then {op: :select}
      # variable access
      when 0x20 then {op: :get_local, local_index: read_varuint} # varuint32
      when 0x21 then {op: :set_local, local_index: read_varuint} # varuint32
      when 0x22 then {op: :tee_local, local_index: read_varuint} # varuint32
      when 0x23 then {op: :get_global, global_index: read_varuint} # varuint32
      when 0x24 then {op: :set_global, global_index: read_varuint} # varuint32
      # memory-related operators
      when 0x28 then {op: :load, type: :i32, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x29 then {op: :load, type: :i64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2a then {op: :load, type: :f32, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2b then {op: :load, type: :f64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2c then {op: :load8_s, type: :i32, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2d then {op: :load8_u, type: :i32, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2e then {op: :load16_s, type: :i32, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2f then {op: :load16_u, type: :i32, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x30 then {op: :load8_s, type: :i64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x31 then {op: :load8_u, type: :i64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x32 then {op: :load16_s, type: :i64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x33 then {op: :load16_u, type: :i64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x34 then {op: :load32_s, type: :i64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x35 then {op: :load32_u, type: :i64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x36 then {op: :store, type: :i32, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x37 then {op: :store, type: :i64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x38 then {op: :store, type: :f32, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x39 then {op: :store, type: :f64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3a then {op: :store8, type: :f32, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3b then {op: :store16, type: :f32, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3a then {op: :store8, type: :f64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3b then {op: :store16, type: :f64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3c then {op: :store32, type: :f64, flags: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3f then {op: :current_memory, reserved: read_varuint == 1} # varuint1
      when 0x40 then {op: :grow_memory, reserved: read_varuint == 1} # varuint1
      # constants
      when 0x41 then {op: :const, type: :i32, value: read_varint32} # NOTE: this is signed
      when 0x42 then {op: :const, type: :i64, value: read_varint64} # NOTE: this is signed
      when 0x43 then {op: :const, type: :f32, value: read_f32}
      when 0x44 then {op: :const, type: :f64, value: read_f64}
      # comparison operators
      when 0x45 then {op: :eqz, type: :i32}
      when 0x46 then {op: :eq, type: :i32}
      when 0x47 then {op: :ne, type: :i32}
      when 0x48 then {op: :lt_s, type: :i32}
      when 0x49 then {op: :lt_u, type: :i32}
      when 0x4a then {op: :gt_s, type: :i32}
      when 0x4b then {op: :gt_u, type: :i32}
      when 0x4c then {op: :le_s, type: :i32}
      when 0x4d then {op: :le_u, type: :i32}
      when 0x4e then {op: :ge_s, type: :i32}
      when 0x4f then {op: :ge_u, type: :i32}
      when 0x50 then {op: :eqz, type: :i64}
      when 0x51 then {op: :eq, type: :i64}
      when 0x52 then {op: :ne, type: :i64}
      when 0x53 then {op: :lt_s, type: :i64}
      when 0x54 then {op: :lt_u, type: :i64}
      when 0x55 then {op: :gt_s, type: :i64}
      when 0x56 then {op: :gt_u, type: :i64}
      when 0x57 then {op: :le_s, type: :i64}
      when 0x58 then {op: :le_u, type: :i64}
      when 0x59 then {op: :ge_s, type: :i64}
      when 0x5a then {op: :ge_u, type: :i64}
      when 0x5b then {op: :eq, type: :f32}
      when 0x5c then {op: :ne, type: :f32}
      when 0x5d then {op: :lt, type: :f32}
      when 0x5e then {op: :gt, type: :f32}
      when 0x5f then {op: :le, type: :f32}
      when 0x60 then {op: :ge, type: :f32}
      when 0x61 then {op: :eq, type: :f64}
      when 0x62 then {op: :ne, type: :f64}
      when 0x63 then {op: :lt, type: :f64}
      when 0x64 then {op: :gt, type: :f64}
      when 0x65 then {op: :le, type: :f64}
      when 0x66 then {op: :ge, type: :f64}
      # numeric operators
      when 0x67 then {op: :clz, type: :i32}
      when 0x68 then {op: :ctz, type: :i32}
      when 0x69 then {op: :popcnt, type: :i32}
      when 0x6a then {op: :add, type: :i32}
      when 0x6b then {op: :sub, type: :i32}
      when 0x6c then {op: :mul, type: :i32}
      when 0x6d then {op: :div_s, type: :i32}
      when 0x6e then {op: :div_u, type: :i32}
      when 0x6f then {op: :rem_s, type: :i32}
      when 0x70 then {op: :rem_u, type: :i32}
      when 0x71 then {op: :and, type: :i32}
      when 0x72 then {op: :or, type: :i32}
      when 0x73 then {op: :xor, type: :i32}
      when 0x74 then {op: :shl, type: :i32}
      when 0x75 then {op: :shr_s, type: :i32}
      when 0x76 then {op: :shr_u, type: :i32}
      when 0x77 then {op: :rotl, type: :i32}
      when 0x78 then {op: :rotr, type: :i32}
      when 0x79 then {op: :clz, type: :i64}
      when 0x7a then {op: :ctz, type: :i64}
      when 0x7b then {op: :popcnt, type: :i64}
      when 0x7c then {op: :add, type: :i64}
      when 0x7d then {op: :sub, type: :i64}
      when 0x7e then {op: :mul, type: :i64}
      when 0x7f then {op: :div_s, type: :i64}
      when 0x80 then {op: :div_u, type: :i64}
      when 0x81 then {op: :rem_s, type: :i64}
      when 0x82 then {op: :rem_u, type: :i64}
      when 0x83 then {op: :and, type: :i64}
      when 0x84 then {op: :or, type: :i64}
      when 0x85 then {op: :xor, type: :i64}
      when 0x86 then {op: :shl, type: :i64}
      when 0x87 then {op: :shr_s, type: :i64}
      when 0x88 then {op: :shr_u, type: :i64}
      when 0x89 then {op: :rotl, type: :i64}
      when 0x8a then {op: :rotr, type: :i64}
      when 0x8b then {op: :abs, type: :f32}
      when 0x8c then {op: :neg, type: :f32}
      when 0x8d then {op: :ceil, type: :f32}
      when 0x8e then {op: :floor, type: :f32}
      when 0x8f then {op: :trunc, type: :f32}
      when 0x90 then {op: :nearest, type: :f32}
      when 0x91 then {op: :sqrt, type: :f32}
      when 0x92 then {op: :add, type: :f32}
      when 0x93 then {op: :sub, type: :f32}
      when 0x94 then {op: :mul, type: :f32}
      when 0x95 then {op: :div, type: :f32}
      when 0x96 then {op: :min, type: :f32}
      when 0x97 then {op: :max, type: :f32}
      when 0x98 then {op: :copysign, type: :f32}
      when 0x99 then {op: :abs, type: :f64}
      when 0x9a then {op: :neg, type: :f64}
      when 0x9b then {op: :ceil, type: :f64}
      when 0x9c then {op: :floor, type: :f64}
      when 0x9d then {op: :trunc, type: :f64}
      when 0x9e then {op: :nearest, type: :f64}
      when 0x9f then {op: :sqrt, type: :f64}
      when 0xa0 then {op: :add, type: :f64}
      when 0xa1 then {op: :sub, type: :f64}
      when 0xa2 then {op: :mul, type: :f64}
      when 0xa3 then {op: :div, type: :f64}
      when 0xa4 then {op: :min, type: :f64}
      when 0xa5 then {op: :max, type: :f64}
      when 0xa6 then {op: :copysign, type: :f64}
      # conversions
      when 0xa7 then {op: :wrap, type: :i32, from: :i64}
      when 0xa8 then {op: :trunc_s, type: :i32, from: :f32}
      when 0xa9 then {op: :trunc_u, type: :i32, from: :f32}
      when 0xaa then {op: :trunc_s, type: :i32, from: :f64}
      when 0xab then {op: :trunc_u, type: :i32, from: :f64}
      when 0xac then {op: :extend_s, type: :i64, from: :i32}
      when 0xad then {op: :extend_u, type: :i64, from: :i32}
      when 0xae then {op: :trunc_s, type: :i64, from: :f32}
      when 0xaf then {op: :trunc_u, type: :i64, from: :f32}
      when 0xb0 then {op: :trunc_s, type: :i64, from: :f64}
      when 0xb1 then {op: :trunc_u, type: :i64, from: :f64}
      when 0xb2 then {op: :convert_s, type: :f32, from: :i32}
      when 0xb3 then {op: :convert_u, type: :f32, from: :i32}
      when 0xb4 then {op: :convert_s, type: :f32, from: :i64}
      when 0xb5 then {op: :convert_u, type: :f32, from: :i64}
      when 0xb6 then {op: :demote_u, type: :f32, from: :f64}
      when 0xb7 then {op: :convert_s, type: :f64, from: :i32}
      when 0xb8 then {op: :convert_u, type: :f64, from: :i32}
      when 0xb9 then {op: :convert_s, type: :f64, from: :i64}
      when 0xba then {op: :convert_u, type: :f64, from: :i64}
      when 0xbb then {op: :promote, type: :f64, from: :f32}
      # reinterpretations
      when 0xbc then {op: :reinterpret, type: :i32, from: :f32}
      when 0xbd then {op: :reinterpret, type: :i64, from: :f64}
      when 0xbe then {op: :reinterpret, type: :f32, from: :i32}
      when 0xbf then {op: :reinterpret, type: :f64, from: :i64}
      else raise ParseError, 'unknown opcode'
      end
    end
  end
end
