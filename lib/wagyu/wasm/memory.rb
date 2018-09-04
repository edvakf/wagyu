module Wagyu::Wasm
  class Memory
    attr_accessor :buffer

    # https://webassembly.github.io/spec/core/exec/runtime.html#page-size
    PAGE_SIZE = 64 * 1024

    def initialize(initial:, maximum: nil)
      @buffer = String.new("\0", encoding: Encoding::ASCII_8BIT) * initial * PAGE_SIZE
      @maximum = maximum
    end

    def i32_load(i)
      @buffer[i, 4].unpack("L<").first # little endian unsigned long
    end

    def i64_load(i)
      @buffer[i, 8].unpack("Q<").first # little endian unsigned long long
    end

    def f32_load(i)
      @buffer[i, 4].unpack("e").first # little endian single precision float
    end

    def f64_load(i)
      @buffer[i, 8].unpack("E").first # little endian double precision float
    end

    def i64_load8_s(i)
      @buffer[i, 1].unpack("c").first # signed char
    end

    def i64_load8_u(i)
      @buffer[i, 1].unpack("C").first # unsigned char
    end

    def i64_load16_s(i)
      @buffer[i, 2].unpack("s<").first # little endian signed short
    end

    def i64_load16_u(i)
      @buffer[i, 2].unpack("S<").first # little endian unsigned short
    end

    def i64_load32_s(i)
      @buffer[i, 4].unpack("l<").first # little endian signed long
    end

    def i64_load32_u(i)
      @buffer[i, 4].unpack("L<").first # little endian unsigned long
    end

    alias_method :i32_load8_s, :i64_load8_s
    alias_method :i32_load8_u, :i64_load8_u
    alias_method :i32_load16_s, :i64_load16_s
    alias_method :i32_load16_u, :i64_load16_u

    def i32_store(i, n)
      @buffer[i, 4] = [n].pack("L<") # little endian unsigned long
    end

    def i64_store(i, n)
      @buffer[i, 8] = [n].pack("Q<") # little endian unsigned long long
    end

    def f32_store(i, n)
      @buffer[i, 4] = [n].pack("e") # little endian single precision float
    end

    def f64_store(i, n)
      @buffer[i, 8] = [n].pack("E") # little endian double precision float
    end

    def f64_store8(i, n)
      @buffer[i, 1] = [n].pack("C") # unsigned char
    end

    def f64_store16(i, n)
      @buffer[i, 2] = [n].pack("S<") # little endian unsigned short
    end

    def f64_store32(i, n)
      @buffer[i, 4] = [n].pack("L<") # little endian unsigned long
    end

    alias_method :f32_store8, :f64_store8
    alias_method :f32_store16, :f64_store16

    def size
      @buffer.length / PAGE_SIZE
    end

    def grow(page)
      # TODO: assert size + page < maximum
      @buffer.concat("\0" * (page * PAGE_SIZE - @buffer.length))
    end
  end
end
