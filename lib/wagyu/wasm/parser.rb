require "wagyu/wasm/module"

module Wagyu::Wasm
  class Parser
    WASM_MAGIC = "\0asm"
    WASM_VERSIONS = {"\x01\0\0\0" => 1}.freeze

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

    def read_bytes(n)
      @io.read(n)
    end

    # https://en.wikipedia.org/wiki/LEB128#Decode_unsigned_integer
    def read_varuint
      result = 0
      shift = 0
      loop do
        byte = @io.read(1).ord
        result |= (byte & 0b0111_1111) << shift
        break if byte & 0b1000_0000 == 0
        shift += 7
      end
      result
    end

    # varuint7 (second highest bit is the sign bit)
    def read_value_type
      b = @io.read(1).ord
      (b & 0b0011_1111) * ((b & 0b0100_0000) == 0 ? 1 : -1)
    end

    def read_magic
      magic = read_bytes(4)
      raise ParseError, 'magic does not match' unless WASM_MAGIC == magic
    end

    def read_version
      version = read_bytes(4)
      raise ParseError, 'unknown version' unless WASM_VERSIONS.include?(version)
      WASM_VERSIONS[version]
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
      #when ExportID
        #mod.export_section = read_export_section
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
      form = read_value_type

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

    # CodeSection
    def read_code_section
      bodies = Array.new(read_varuint) do
        read_function_body
      end
      CodeSection.new(bodies)
    end

    def read_function_body
      body_size = read_varuint # size of function body to follow, in bytes
      pos1 = @io.pos

      locals = Array.new(read_varuint) do
        read_local_entry
      end
      pos2 = @io.pos

      code = @io.read(body_size - (pos2 - pos1) - 1) # 1 for the end of function body

      raise ParseError, 'failed to parse function body' unless read_bytes(1) == "\x0b"

      FunctionBody.new(locals, code)
    end

    def read_local_entry
      count = read_varuint # number of local variables of the following type
      type = read_value_type # type of the variables
      LocalEntry.new(count, type)
    end
  end
end
