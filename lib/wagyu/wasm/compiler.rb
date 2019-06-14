require "wagyu/wasm/parser"
require "wagyu/wasm/module"
require "pp"

module Wagyu::Wasm
  class MethodCompiler
    def initialize
      @var_num = 0
      @stack = []
      @code = []
    end

    def compile(function_index, function_body, type_index, types)
      type = types[type_index]

      params = type.params.map.with_index{|type, i| "p#{i}"}

      local_count = function_body.locals.map(&:count).sum

      locals = 0.upto(local_count-1).map{|i| "l#{i}" }

      @types = types

      @locals = params + locals

      @code << "def _f#{function_index}(#{params.join(", ")})"

      @controls = []

      function_body.code.each do |instr|
        compile_instr(instr)
      end

      # p @stack # should assert stack is empty??
      # pp @code

      return @code.join("\n")
    end

    def compile_instr(instr)
      case instr[:name]
      when :if
        condition = @stack.pop
        new_control(instr)
        @code << "depth = _if(#{condition}, ->{"
      when :else
        control = @controls.last
        raise "else must be called inside an if" if control.nil? || control[:type] != :if

        @code << "#{control[:var]} = #{@stack.pop}" unless control[:sig] == :empty_block_type
        @code << "-1"
        @code << "}){ # else"
      when :block
        new_control(instr)
        @code << "depth = _block{"
      when :loop
        new_control(instr)
        @code << "depth = _loop{"
      when :br_if
        raise "br must be called inside control flow" if @controls.empty?

        condition = @stack.pop

        tgt = @controls[-1-instr[:relative_depth]]
        @code << "#{tgt[:var]} = #{@stack.last}" if tgt[:var] # NOTICE: not @stack.pop

        @code << "next #{instr[:relative_depth]} if #{condition}"
      when :br
        raise "br must be called inside block or loop" if @controls.empty?

        tgt = @controls[-1-instr[:relative_depth]]
        @code << "#{tgt[:var]} = #{@stack.last}" if tgt[:var] # NOTICE: not @stack.pop
        # TODO: no instructions should follow br, but when they come, br must be treated as stack-polymorphic.

        @code << "next #{instr[:relative_depth]}"
      when :br_table
        @code << "case #{@stack.pop}"
        instr[:target_table].each.with_index do |depth, i|
          @code << "when #{i} then next #{depth}"
        end
        @code << "else next #{instr[:default_target]}"
        @code << "end"
      when :end
        control = @controls.pop

        if control.nil? # end of function
          # TODO: what happens when the function has no return value?
          @code << @stack.pop
          @code << "end"
        else
          @code << "#{control[:var]} = #{@stack.pop}" if control[:var]
          @code << "-1"
          @code << "}"
          @code << "next depth - 1 if depth > 0" unless @controls.empty?

          # https://www.w3.org/TR/wasm-core-1/#instructions%E2%91%A0
          # Taking a branch unwinds the operand stack up to the height where the targeted structured control instruction was entered.
          @stack.slice!(control[:stack_depth], @stack.length)
        end
      when :return
        @code << "return #{@stack.last}"
      when :const
        new_var { instr[:value].to_s }
      when :eq
        new_var { @stack.pop(2).join(" == ") }
      when :ne
        new_var { @stack.pop(2).join(" != ") }
      when :eqz
        new_var { "#{@stack.pop} == 0" }
      when :ge_u, :ge_s
        new_var { @stack.pop(2).join(" >= ") }
      when :gt_u, :gt_s
        new_var { @stack.pop(2).join(" > ") }
      when :le_u, :le_s
        new_var { @stack.pop(2).join(" <= ") }
      when :lt_u, :lt_s
        new_var { @stack.pop(2).join(" < ") }
      when :shl
        new_var { @stack.pop(2).join(" << ") }
      when :shr_u, :shr_s
        new_var { @stack.pop(2).join(" >> ") }
      when :tee_local
        @code << "#{@locals[instr[:local_index]]} = #{@stack.last}"
      when :set_local
        @code << "#{@locals[instr[:local_index]]} = #{@stack.pop}"
      when :get_local
        new_var { @locals[instr[:local_index]] }
      when :set_global
        @code << "@_g#{instr[:global_index]} = #{@stack.pop}"
      when :get_global
        new_var { "@_g#{instr[:global_index]}" }
      when :add
        new_var { @stack.pop(2).join(" + ") }
      when :sub
        new_var { @stack.pop(2).join(" - ") }
      when :mul
        new_var { @stack.pop(2).join(" * ") }
      when :div_u, :div_s, :div
        new_var { @stack.pop(2).join(" / ") } # it's an integer division if both operands are integers, otherwise float division
      when :rem_s, :rem_u
        new_var { @stack.pop(2).join(" % ") }
      when :call
        n = @types[instr[:function_index]].params.length
        new_var { "_f#{instr[:function_index]}(#{@stack.pop(n).join(", ")})" }
      when :sqrt
        new_var { "Math.sqrt(#{@stack.pop})" }
      when :load
        new_var { "@_m0.#{instr[:type]}_load(#{@stack.pop})" }
      when :load8_s
        new_var { "@_m0.#{instr[:type]}_load8_s(#{@stack.pop})" }
      when :load8_u
        new_var { "@_m0.#{instr[:type]}_load8_u(#{@stack.pop})" }
      when :load16_s
        new_var { "@_m0.#{instr[:type]}_load16_s(#{@stack.pop})" }
      when :load16_u
        new_var { "@_m0.#{instr[:type]}_load16_u(#{@stack.pop})" }
      when :load32_s
        new_var { "@_m0.#{instr[:type]}_load32_s(#{@stack.pop})" }
      when :load32_u
        new_var { "@_m0.#{instr[:type]}_load32_u(#{@stack.pop})" }
      when :store
        a, b = @stack.pop(2)
        @code << "@_m0.#{instr[:type]}_store(#{a}, #{b})"
      when :store8
        a, b = @stack.pop(2)
        @code << "@_m0.#{instr[:type]}_store8(#{a}, #{b})"
      when :store16
        a, b = @stack.pop(2)
        @code << "@_m0.#{instr[:type]}_store16(#{a}, #{b})"
      when :store32
        a, b = @stack.pop(2)
        @code << "@_m0.#{instr[:type]}_store32(#{a}, #{b})"
      when :store
      else
        raise StandardError.new("Unknown instruction: #{instr[:name]}")
      end
    end

    def new_control(instr)
      var =
        if instr[:sig] == :empty_block_type
          nil
        else
          new_var { "nil" }
        end
      @controls << {type: instr[:name], var: var, stack_depth: @stack.length}
    end

    def new_var
      var = "v#{@var_num}"
      @code << "#{var} = #{yield}"
      @stack << var
      @var_num += 1
      var
    end
  end


  class Compiler
    def initialize
    end

    # return Module
    def compile(io)
      rep = Parser.new(io).parse

      # pp rep

      mod = Module.new # mod is an instance of Module, which inherits Class

      import_funcs = 0

      num_globals = 0
      num_memories = 0

      after_initialize = []

      if rep.import_section
        rep.import_section.imports.each do |import_entry|
          case import_entry.kind
          when :function
            types = rep.type_section.types[import_entry.type]
            params = types.params.map.with_index{|type, i| "p#{i}"}

            # TODO: fix form of import_object
            method = <<~EVAL
              def _f#{import_funcs}(#{params.join(", ")})
                @import_object[:#{import_entry.module}][:#{import_entry.field}].call(#{params.join(", ")})
              end
            EVAL

            # puts method
            mod.module_class.class_eval(method)

            import_funcs += 1
          when :global
            # TODO: assert the field is provided
            after_initialize << "@_g#{num_globals} = @import_object[:#{import_entry.module}][:#{import_entry.field}]"
            num_globals += 1
          when :memory
            after_initialize << "@_m#{num_memories} = @import_object[:#{import_entry.module}][:#{import_entry.field}]"
            num_memories += 1
          end
        end
      end

      if rep.memory_section
        rep.memory_section.memories.each do |memory|
          after_initialize << "@_m#{num_memories} = Wagyu::Wasm::Memory.new(initial: #{memory.limits.initial}, maximum: #{memory.limits.maximum || "nil"})"
          num_memories += 1
        end
      end

      if rep.global_section
        rep.global_section.globals.each do |global|
          case global.expr[:name]
          when :const
            after_initialize << "@_g#{num_globals} = #{global.expr[:value]}"
            num_globals += 1
          when :get_global
            after_initialize << "@_g#{num_globals} = @_g#{global.expr[:global_index]}"
            num_globals += 1
          else
            raise StandardError("") # TODO
          end
        end
      end

      if rep.function_section
        rep.function_section.types.each_with_index do |type_idx, func_idx|

          method = MethodCompiler.new.compile(
            func_idx + import_funcs,
            rep.code_section.bodies[func_idx],
            type_idx,
            rep.type_section.types
          )

          # puts method
          mod.module_class.class_eval(method)
        end
      end

      if rep.export_section
        rep.export_section.exports.each_with_index do |export_entry, i|
          case export_entry.kind
          when :function

            raise StandardError("A function must not start with an underscore") if export_entry.field.start_with?("_")

            mod.module_class.class_eval do
              alias_method export_entry.field.to_sym, "_f#{export_entry.index}".to_sym
            end
          when :memory
            mod.module_class.class_eval( <<~DEFINE_MEMORY )
              def #{export_entry.field}
                @_m#{export_entry.index}
              end
            DEFINE_MEMORY
          end
        end
      end

      if rep.start_section
        after_initialize << "_f#{rep.start_section.index}"
      end

      if rep.data_section
        rep.data_section.segments.each do |segment|
          case segment.offset_expr[:name]
          when :const
            after_initialize << "@_m#{segment.index}.buffer[#{segment.offset_expr[:value]}, #{segment.data.length}] = #{segment.data.inspect}"
          else
            raise StandardError("") # TODO
          end
        end
      end

      mod.module_class.class_eval( <<~AFTER_INITIALIZE )
        def after_initialize
          #{after_initialize.join("\n")}
        end
      AFTER_INITIALIZE

      mod
    end
  end
end
