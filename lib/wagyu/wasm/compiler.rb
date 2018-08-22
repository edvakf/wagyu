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
      when :const
        new_var { instr[:value].to_s }
      when :eq
        new_var { a, b = @stack.pop(2); "#{a} == #{b}" }
      when :ne
        new_var { a, b = @stack.pop(2); "#{a} != #{b}" }
      when :eqz
        new_var { "#{@stack.pop} == 0" }
      when :ge_u, :ge_s
        new_var { a, b = @stack.pop(2); "#{a} >= #{b}" }
      when :gt_u, :ge_s
        new_var { a, b = @stack.pop(2); "#{a} > #{b}" }
      when :le_u, :le_s
        new_var { a, b = @stack.pop(2); "#{a} <= #{b}" }
      when :lt_u, :le_s
        new_var { a, b = @stack.pop(2); "#{a} < #{b}" }
      when :set_local
        @code << "#{@locals[instr[:local_index]]} = #{@stack.pop}"
      when :get_local
        new_var { @locals[instr[:local_index]] }
      when :add
        new_var { a, b = @stack.pop(2); "#{a} + #{b}" }
      when :sub
        new_var { a, b = @stack.pop(2); "#{a} - #{b}" }
      when :mul
        new_var { a, b = @stack.pop(2); "#{a} * #{b}" }
      when :call
        n = @types[instr[:function_index]].params.length
        new_var { "_f#{instr[:function_index]}(#{@stack.pop(n).join(", ")})" }
      when :sqrt
        new_var { "Math.sqrt(#{@stack.pop})" }
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

      if rep.import_section
        rep.import_section.imports.each do |import_entry|
          if import_entry.kind == :function
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
          if export_entry.kind == :function

            raise StandardError("A function must not start with an underscore") if export_entry.field.start_with?("_")

            mod.module_class.class_eval do
              alias_method export_entry.field.to_sym, "_f#{export_entry.index}".to_sym
            end
          end
        end
      end

      mod
    end
  end
end
