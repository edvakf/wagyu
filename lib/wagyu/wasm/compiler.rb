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

      function_body.code.each do |instr|
        case instr[:name]
        when :if
          add_instruction { "if #{@stack.pop}" }
        when :else
          @code << @stack.pop
          @code << "else"
        when :block
          @code << "catch(:b1) do"
          # TODO: catch clause can have a return value by passing the second argument to throw
        when :loop
          @code << "while true"
          # TODO: how to handle when loop returns a value?
        when :br_if
          @code << "throw :b1 if #{@stack.pop}"
          # TODO: support multi-level nes
        when :br
          if instr[:relative_depth] == 0
            @code << "next"
          else
            raise "Not implemented"
          end
        when :const
          add_instruction { instr[:value].to_s }
        when :eq
          add_instruction { a, b = @stack.pop(2); "#{a} == #{b}" }
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
          @stack << locals[instr[:local_index]]
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
        when :end
          @code << @stack.pop unless @stack.empty?
          @code << "end"
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
