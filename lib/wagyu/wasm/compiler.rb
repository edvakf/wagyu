require "wagyu/wasm/parser"
require "pp"

module Wagyu::Wasm
  class MethodCompiler
    def initialize
      @var_num = 0
      @stack = []
      @code = []
    end

    def compile(function_index, function_body, types)
      params = types.params.map.with_index{|type, i| "p#{i}"}

      local_count = function_body.locals.map(&:count).sum

      locals = 0.upto(local_count-1).map{|i| "l#{i}" }

      locals = params + locals

      @code << "def m#{function_index}(#{params.join(", ")})"

      controls = []

      function_body.code.each do |instr|
        case instr[:name]
        when :if
          condition = @stack.pop
          var = instr[:sig] == :empty_block_type ? nil : add_instruction { "nil" }
          controls << {type: :if, sig: instr[:sig], var: var, stack_depth: @stack.length}
          @code << "depth = _if(#{condition}, ->{"
        when :else
          control = controls.last
          raise "else must be called inside an if" if control.nil? || control[:type] != :if

          @code << "#{control[:var]} = #{@stack.pop}" unless control[:sig] == :empty_block_type
          @code << "-1"
          @code << "}){ # else"
        when :block
          var = instr[:sig] == :empty_block_type ? nil : add_instruction { "nil" }
          controls << {type: :block, sig: instr[:sig], var: var, stack_depth: @stack.length}
          @code << "depth = _block{"
        when :loop
          var = instr[:sig] == :empty_block_type ? nil : add_instruction { "nil" }
          controls << {type: :loop, sig: instr[:sig], var: var, stack_depth: @stack.length}
          @code << "depth = _loop{"
        when :br_if
          raise "br must be called inside control flow" if controls.empty?

          condition = @stack.pop

          tgt = controls[-1-instr[:relative_depth]]
          @code << "#{tgt[:var]} = #{@stack.last}" if tgt[:var] # NOTICE: not @stack.pop

          @code << "next #{instr[:relative_depth]} if #{condition}"
        when :br
          raise "br must be called inside block or loop" if controls.empty?

          tgt = controls[-1-instr[:relative_depth]]
          @code << "#{tgt[:var]} = #{@stack.last}" if tgt[:var] # NOTICE: not @stack.pop
          # TODO: no instructions should follow br, but when they come, br must be treated as stack-polymorphic.

          @code << "next #{instr[:relative_depth]}"
        when :end
          control = controls.pop

          if control.nil? # end of function
            # TODO: what happens when the function has no return value?
            @code << @stack.pop
            @code << "end"
          else
            @code << "#{control[:var]} = #{@stack.pop}" if control[:var]
            @code << "-1"
            @code << "}"
            @code << "next depth - 1 if depth > 0" unless controls.empty?

            # https://www.w3.org/TR/wasm-core-1/#instructions%E2%91%A0
            # Taking a branch unwinds the operand stack up to the height where the targeted structured control instruction was entered.
            @stack.slice!(control[:stack_depth], @stack.length)
          end
        when :const
          add_instruction { instr[:value].to_s }
        when :eq
          add_instruction { a, b = @stack.pop(2); "#{a} == #{b}" }
        when :ne
          add_instruction { a, b = @stack.pop(2); "#{a} != #{b}" }
        when :eqz
          add_instruction { "#{@stack.pop} == 0" }
        when :ge_u, :ge_s
          add_instruction { a, b = @stack.pop(2); "#{a} >= #{b}" }
        when :gt_u, :ge_s
          add_instruction { a, b = @stack.pop(2); "#{a} > #{b}" }
        when :le_u, :le_s
          add_instruction { a, b = @stack.pop(2); "#{a} <= #{b}" }
        when :lt_u, :le_s
          add_instruction { a, b = @stack.pop(2); "#{a} < #{b}" }
        when :set_local
          @code << "#{locals[instr[:local_index]]} = #{@stack.pop}"
        when :get_local
          add_instruction { locals[instr[:local_index]] }
        when :add
          add_instruction { a, b = @stack.pop(2); "#{a} + #{b}" }
        when :sub
          add_instruction { a, b = @stack.pop(2); "#{a} - #{b}" }
        when :mul
          add_instruction { a, b = @stack.pop(2); "#{a} * #{b}" }
        when :call
          add_instruction { "m#{instr[:function_index]}(#{@stack.pop})" }
        when :sqrt
          add_instruction { "Math.sqrt(#{@stack.pop})" }
        else
          raise StandardError.new("Unknown instruction: #{instr[:name]}")
        end
      end

      # p @stack # should assert stack is empty??
      # pp @code

      return @code.join("\n")
    end

    def add_instruction
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

      mod = Class.new do |c|
        def _if(condition, then_proc, &else_block)
          if condition
            then_proc.call
          elsif else_block
            yield else_block
          else
            -1
          end
        end

        def _loop(&block)
          while true
            depth = yield block
            next if depth == 0
            return depth
          end
        end

        def _block(&block)
          yield block
        end

        if rep.function_section
          rep.function_section.types.each_with_index do |type_idx, func_idx|

            method = MethodCompiler.new.compile(
              func_idx,
              rep.code_section.bodies[func_idx],
              rep.type_section.types[type_idx]
            )

            # puts method
            eval(method)
          end
        end

        if rep.export_section
          rep.export_section.exports.each_with_index do |export_entry, i|
            if export_entry.kind == :function
              alias_method export_entry.field.to_sym, "m#{export_entry.index}".to_sym
            end
          end
        end
      end

      mod
    end
  end
end
