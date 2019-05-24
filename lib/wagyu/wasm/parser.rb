require "wagyu/wasm/internal"

module Wagyu::Wasm
  class Parser
    include Internal

    WASM_MAGIC = "\0asm"

    class ParseError < StandardError; end

    def initialize(io)
      @io = io
    end

    def parse
      read_magic
      version = read_version

      rep = Representation.new(version)
      loop do
        break if @io.eof?
        read_section(rep)
      end

      rep
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

    def read_section(rep)
      id = read_varuint # varuint32
      payload_len = read_varuint # varuint32 (there isn't quite a use case for this in ruby)

      case id
      when TypeID
        rep.type_section = read_type_section
      when ImportID
        rep.import_section = read_import_section
      when FunctionID
        rep.function_section = read_function_section
      when TableID
        rep.table_section = read_table_section
      when MemoryID
        rep.memory_section = read_memory_section
      when GlobalID
        rep.global_section = read_global_section
      when ExportID
        rep.export_section = read_export_section
      when StartID
        rep.start_section = read_start_section
      when ElementID
        rep.element_section = read_element_section
      when CodeID
        rep.code_section = read_code_section
      when DataID
        rep.data_section = read_data_section
      #when UnknownID
        #rep.name_section = read_name_section
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

    # ImportSection
    def read_import_section
      imports = Array.new(read_varuint) do
        read_import_entry
      end
      ImportSection.new(imports)
    end

    def read_import_entry
      module_len = read_varuint
      module_str = read_bytes(module_len)
      field_len = read_varuint
      field_str = read_bytes(field_len)
      kind = read_external_kind

      case kind
      when :function
        type = read_varuint
      when :table
        type = read_table_type
      when :memory
        type = read_memory_type
      when :global
        type = read_global_type
      else
        raise ParseError, 'unknown kind'
      end

      ImportEntry.new(module_str, field_str, kind, type)
    end

    def read_global_type
      content_type = read_value_type
      mutability = read_uint8 == 1 # varuint1 (bool)
      GlobalType.new(content_type, mutability)
    end

    def read_table_type
      element_type = read_elem_type
      limits = read_resizable_limits
      TableType.new(element_type, limits)
    end

    def read_memory_type
      limits = read_resizable_limits
      MemoryType.new(limits)
    end

    def read_resizable_limits
      flags = read_uint8 # 1 if the maximum field is present, 0 otherwise
      initial = read_varuint # initial length (in units of table elements or wasm pages)
      if flags == 1
        maximum = read_varuint # only present if specified by flags
      else
        maximum = nil
      end
      ResizableLimits.new(initial, maximum)
    end

    # FunctionSection
    def read_function_section
      types = Array.new(read_varuint) do
        read_varuint
      end
      FunctionSection.new(types)
    end

    # TableSection
    def read_table_section
      tables = Array.new(read_varuint) do
        read_table_type
      end
      TableSection.new(tables)
    end

    # MemorySection
    def read_memory_section
      memories = Array.new(read_varuint) do
        read_memory_type
      end
      MemorySection.new(memories)
    end

    # GlobalSection
    def read_global_section
      globals = Array.new(read_varuint) do
        read_global
      end
      GlobalSection.new(globals)
    end

    def read_global
      global_type = read_global_type
      expr = read_constant_expr
      Global.new(global_type, expr)
    end

    def read_constant_expr
      expr_instr = read_instruction
      # assert expr_instr[:name] == :const || expr_instr[:name] == :get_global
      end_instr = read_instruction
      # assert end_instr[:name] == :end
      expr_instr
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

    # StartSection
    def read_start_section
      funcidx = read_varuint
      StartSection.new(funcidx)
    end

    # ElementSection
    def read_element_section
      element_segments = Array.new(read_varuint) do
        read_element_segment
      end
      ElementsSection.new(element_segments)
    end

    def read_element_segment
      table_index = read_varuint
      offset_expr = read_constant_expr
      function_indices = Array.new(read_varuint) do
        read_varuint
      end
      ElementSegment.new(table_index, offset_expr, function_indices)
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
      end_pos = @io.pos + body_size

      locals = Array.new(read_varuint) do
        read_local_entry
      end

      code = read_code(end_pos)

      FunctionBody.new(locals, code)
    end

    def read_local_entry
      count = read_varuint # number of local variables of the following type
      type = read_value_type # type of the variables
      LocalEntry.new(count, type)
    end

    def read_code(end_pos)
      code = []
      loop do
        instr = read_instruction
        code << instr
        break if @io.pos == end_pos # may assert instr[:name] == :end
      end
      code
    end

    def read_instruction
      case read_uint8
      # control flow instructions
      when 0x00 then {name: :unreachable}
      when 0x01 then {name: :nop}
      when 0x02 then {name: :block, sig: read_block_type} # varint7
      when 0x03 then {name: :loop, sig: read_block_type} # varint7
      when 0x04 then {name: :if, sig: read_block_type} # varint7
      when 0x05 then {name: :else}
      when 0x0b then {name: :end}
      when 0x0c then {name: :br, relative_depth: read_varuint} # varuint32
      when 0x0d then {name: :br_if, relative_depth: read_varuint} # varuint32
      when 0x0e then
        target_table = Array.new(read_varuint) do
          read_varuint # varuint32
        end
        default_target = read_varuint
        {name: :br_table, target_table: target_table, default_target: default_target}
      when 0x0f then {name: :return}
      # call instructions
      when 0x10 then {name: :call, function_index: read_varuint} # varuint32
      when 0x11 then {name: :call_index, type_index: read_varuint, reserved: read_varuint == 1} # veruint32, varuint1
      # parametric instructions
      when 0x1a then {name: :drop}
      when 0x1b then {name: :select}
      # variable access
      when 0x20 then {name: :get_local, local_index: read_varuint} # varuint32
      when 0x21 then {name: :set_local, local_index: read_varuint} # varuint32
      when 0x22 then {name: :tee_local, local_index: read_varuint} # varuint32
      when 0x23 then {name: :get_global, global_index: read_varuint} # varuint32
      when 0x24 then {name: :set_global, global_index: read_varuint} # varuint32
      # memory-related instructions
      when 0x28 then {name: :load, type: :i32, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x29 then {name: :load, type: :i64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2a then {name: :load, type: :f32, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2b then {name: :load, type: :f64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2c then {name: :load8_s, type: :i32, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2d then {name: :load8_u, type: :i32, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2e then {name: :load16_s, type: :i32, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x2f then {name: :load16_u, type: :i32, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x30 then {name: :load8_s, type: :i64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x31 then {name: :load8_u, type: :i64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x32 then {name: :load16_s, type: :i64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x33 then {name: :load16_u, type: :i64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x34 then {name: :load32_s, type: :i64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x35 then {name: :load32_u, type: :i64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x36 then {name: :store, type: :i32, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x37 then {name: :store, type: :i64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x38 then {name: :store, type: :f32, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x39 then {name: :store, type: :f64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3a then {name: :store8, type: :f32, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3b then {name: :store16, type: :f32, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3a then {name: :store8, type: :f64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3b then {name: :store16, type: :f64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3c then {name: :store32, type: :f64, alignment: read_varuint, offset: read_varuint} # varuint32, varuint32
      when 0x3f then {name: :current_memory, reserved: read_varuint == 1} # varuint1
      when 0x40 then {name: :grow_memory, reserved: read_varuint == 1} # varuint1
      # constants
      when 0x41 then {name: :const, type: :i32, value: read_varint32} # NOTE: this is signed
      when 0x42 then {name: :const, type: :i64, value: read_varint64} # NOTE: this is signed
      when 0x43 then {name: :const, type: :f32, value: read_f32}
      when 0x44 then {name: :const, type: :f64, value: read_f64}
      # comparison instructions
      when 0x45 then {name: :eqz, type: :i32}
      when 0x46 then {name: :eq, type: :i32}
      when 0x47 then {name: :ne, type: :i32}
      when 0x48 then {name: :lt_s, type: :i32}
      when 0x49 then {name: :lt_u, type: :i32}
      when 0x4a then {name: :gt_s, type: :i32}
      when 0x4b then {name: :gt_u, type: :i32}
      when 0x4c then {name: :le_s, type: :i32}
      when 0x4d then {name: :le_u, type: :i32}
      when 0x4e then {name: :ge_s, type: :i32}
      when 0x4f then {name: :ge_u, type: :i32}
      when 0x50 then {name: :eqz, type: :i64}
      when 0x51 then {name: :eq, type: :i64}
      when 0x52 then {name: :ne, type: :i64}
      when 0x53 then {name: :lt_s, type: :i64}
      when 0x54 then {name: :lt_u, type: :i64}
      when 0x55 then {name: :gt_s, type: :i64}
      when 0x56 then {name: :gt_u, type: :i64}
      when 0x57 then {name: :le_s, type: :i64}
      when 0x58 then {name: :le_u, type: :i64}
      when 0x59 then {name: :ge_s, type: :i64}
      when 0x5a then {name: :ge_u, type: :i64}
      when 0x5b then {name: :eq, type: :f32}
      when 0x5c then {name: :ne, type: :f32}
      when 0x5d then {name: :lt, type: :f32}
      when 0x5e then {name: :gt, type: :f32}
      when 0x5f then {name: :le, type: :f32}
      when 0x60 then {name: :ge, type: :f32}
      when 0x61 then {name: :eq, type: :f64}
      when 0x62 then {name: :ne, type: :f64}
      when 0x63 then {name: :lt, type: :f64}
      when 0x64 then {name: :gt, type: :f64}
      when 0x65 then {name: :le, type: :f64}
      when 0x66 then {name: :ge, type: :f64}
      # numeric instructions
      when 0x67 then {name: :clz, type: :i32}
      when 0x68 then {name: :ctz, type: :i32}
      when 0x69 then {name: :popcnt, type: :i32}
      when 0x6a then {name: :add, type: :i32}
      when 0x6b then {name: :sub, type: :i32}
      when 0x6c then {name: :mul, type: :i32}
      when 0x6d then {name: :div_s, type: :i32}
      when 0x6e then {name: :div_u, type: :i32}
      when 0x6f then {name: :rem_s, type: :i32}
      when 0x70 then {name: :rem_u, type: :i32}
      when 0x71 then {name: :and, type: :i32}
      when 0x72 then {name: :or, type: :i32}
      when 0x73 then {name: :xor, type: :i32}
      when 0x74 then {name: :shl, type: :i32}
      when 0x75 then {name: :shr_s, type: :i32}
      when 0x76 then {name: :shr_u, type: :i32}
      when 0x77 then {name: :rotl, type: :i32}
      when 0x78 then {name: :rotr, type: :i32}
      when 0x79 then {name: :clz, type: :i64}
      when 0x7a then {name: :ctz, type: :i64}
      when 0x7b then {name: :popcnt, type: :i64}
      when 0x7c then {name: :add, type: :i64}
      when 0x7d then {name: :sub, type: :i64}
      when 0x7e then {name: :mul, type: :i64}
      when 0x7f then {name: :div_s, type: :i64}
      when 0x80 then {name: :div_u, type: :i64}
      when 0x81 then {name: :rem_s, type: :i64}
      when 0x82 then {name: :rem_u, type: :i64}
      when 0x83 then {name: :and, type: :i64}
      when 0x84 then {name: :or, type: :i64}
      when 0x85 then {name: :xor, type: :i64}
      when 0x86 then {name: :shl, type: :i64}
      when 0x87 then {name: :shr_s, type: :i64}
      when 0x88 then {name: :shr_u, type: :i64}
      when 0x89 then {name: :rotl, type: :i64}
      when 0x8a then {name: :rotr, type: :i64}
      when 0x8b then {name: :abs, type: :f32}
      when 0x8c then {name: :neg, type: :f32}
      when 0x8d then {name: :ceil, type: :f32}
      when 0x8e then {name: :floor, type: :f32}
      when 0x8f then {name: :trunc, type: :f32}
      when 0x90 then {name: :nearest, type: :f32}
      when 0x91 then {name: :sqrt, type: :f32}
      when 0x92 then {name: :add, type: :f32}
      when 0x93 then {name: :sub, type: :f32}
      when 0x94 then {name: :mul, type: :f32}
      when 0x95 then {name: :div, type: :f32}
      when 0x96 then {name: :min, type: :f32}
      when 0x97 then {name: :max, type: :f32}
      when 0x98 then {name: :copysign, type: :f32}
      when 0x99 then {name: :abs, type: :f64}
      when 0x9a then {name: :neg, type: :f64}
      when 0x9b then {name: :ceil, type: :f64}
      when 0x9c then {name: :floor, type: :f64}
      when 0x9d then {name: :trunc, type: :f64}
      when 0x9e then {name: :nearest, type: :f64}
      when 0x9f then {name: :sqrt, type: :f64}
      when 0xa0 then {name: :add, type: :f64}
      when 0xa1 then {name: :sub, type: :f64}
      when 0xa2 then {name: :mul, type: :f64}
      when 0xa3 then {name: :div, type: :f64}
      when 0xa4 then {name: :min, type: :f64}
      when 0xa5 then {name: :max, type: :f64}
      when 0xa6 then {name: :copysign, type: :f64}
      # conversions
      when 0xa7 then {name: :wrap, type: :i32, from: :i64}
      when 0xa8 then {name: :trunc_s, type: :i32, from: :f32}
      when 0xa9 then {name: :trunc_u, type: :i32, from: :f32}
      when 0xaa then {name: :trunc_s, type: :i32, from: :f64}
      when 0xab then {name: :trunc_u, type: :i32, from: :f64}
      when 0xac then {name: :extend_s, type: :i64, from: :i32}
      when 0xad then {name: :extend_u, type: :i64, from: :i32}
      when 0xae then {name: :trunc_s, type: :i64, from: :f32}
      when 0xaf then {name: :trunc_u, type: :i64, from: :f32}
      when 0xb0 then {name: :trunc_s, type: :i64, from: :f64}
      when 0xb1 then {name: :trunc_u, type: :i64, from: :f64}
      when 0xb2 then {name: :convert_s, type: :f32, from: :i32}
      when 0xb3 then {name: :convert_u, type: :f32, from: :i32}
      when 0xb4 then {name: :convert_s, type: :f32, from: :i64}
      when 0xb5 then {name: :convert_u, type: :f32, from: :i64}
      when 0xb6 then {name: :demote_u, type: :f32, from: :f64}
      when 0xb7 then {name: :convert_s, type: :f64, from: :i32}
      when 0xb8 then {name: :convert_u, type: :f64, from: :i32}
      when 0xb9 then {name: :convert_s, type: :f64, from: :i64}
      when 0xba then {name: :convert_u, type: :f64, from: :i64}
      when 0xbb then {name: :promote, type: :f64, from: :f32}
      # reinterpretations
      when 0xbc then {name: :reinterpret, type: :i32, from: :f32}
      when 0xbd then {name: :reinterpret, type: :i64, from: :f64}
      when 0xbe then {name: :reinterpret, type: :f32, from: :i32}
      when 0xbf then {name: :reinterpret, type: :f64, from: :i64}
      else raise ParseError, 'unknown opcode'
      end
    end

    # DataSection
    def read_data_section
      segments = Array.new(read_varuint) do
        read_data_segment
      end
      DataSection.new(segments)
    end

    def read_data_segment
      index = read_varuint
      offset_expr = read_constant_expr
      length = read_varuint
      data = read_bytes(length)
      DataSegment.new(index, offset_expr, data)
    end
  end
end
