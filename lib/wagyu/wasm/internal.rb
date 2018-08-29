module Wagyu::Wasm
  module Internal
    UnknownID = 0
    TypeID = 1
    ImportID = 2
    FunctionID = 3
    TableID = 4
    MemoryID = 5
    GlobalID = 6
    ExportID = 7
    StartID = 8
    ElementID = 9
    CodeID = 10
    DataID = 11

    Representation = Struct.new(
      :version,
      # some sections are optional and can be nil
      :type_section,
      :import_section,
      :function_section,
      :table_section,
      :memory_section,
      :global_section,
      :export_section,
      :start_section,
      :element_section,
      :code_section,
      :data_section,
      :name_section
    )

    TypeSection = Struct.new(:types) # []FuncType
    ImportSection = Struct.new(:imports) # []ImportEntry
    FunctionSection = Struct.new(:types) # []varuint32
    TableSection = Struct.new(:tables) # []TableType
    MemorySection = Struct.new(:memories) # []MemoryType
    GlobalSection = Struct.new(:globals) # []GlobalVariable
    ExportSection = Struct.new(:exports) # []ExportEntry
    StartSection = Struct.new(:index) # uint32 (func index)
    ElementSection = Struct.new(:elements) # []ElemSegment
    CodeSection = Struct.new(:bodies) # []FunctionBody
    DataSection = Struct.new(:segments) # []DataSegment
    NameSection = Struct.new(:name, :funcs) # string, []FunctionNames

    ImportEntry = Struct.new(:module, :field, :kind, :type) # str, str, ExternalKind,

    FuncType = Struct.new(:form, :params, :results) # ValueType, []ValueType, []ValueType where ValueType is varint7
    GlobalType = Struct.new(:content_type, :mutability) # ValueType, bool (varuint1)
    TableType = Struct.new(:element_type, :limits) # ValueType, ResizableLimits
    MemoryType = Struct.new(:limits) # ResizableLimits
    ResizableLimits = Struct.new(:initial, :maximum) # int, nullable int

    FunctionBody = Struct.new(:locals, :code)
    LocalEntry = Struct.new(:count, :type)

    Global = Struct.new(:global_type, :expr) # GlobalType, instruction

    ExportEntry = Struct.new(:field, :kind, :index) # str, ExternalKind, int

    DataSegment = Struct.new(:index, :offset_expr, :data) # int (memory index), int (segment offset byte), binary
  end
end
