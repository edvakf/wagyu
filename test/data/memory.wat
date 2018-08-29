;; https://ukyo.github.io/wasm-usui-book/webroot/get-started-webassembly.html
;; sum of $n integers (0 <= $n <= 4)
(module
  (memory 1 2)
  (data (i32.const 0) "\01\00\00\00\02\00\00\00\03\00\00\00\04\00\00\00")
  (func (export "sum") (param $n i32) (result i32)
    (local $i i32)
    (local $ret i32)
    i32.const 0
    tee_local $ret
    set_local $i
    block $exit
      loop $cont
        get_local $i
        get_local $n
        i32.eq
        br_if $exit
        get_local $i
        i32.const 4
        i32.mul
        i32.load
        get_local $ret
        i32.add
        set_local $ret
        get_local $i
        i32.const 1
        i32.add
        set_local $i
        br $cont
      end
    end
    get_local $ret)
)

;; 0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
;; 0000004: 0100 0000                                 ; WASM_BINARY_VERSION
;; ; section "Type" (1)
;; 0000008: 01                                        ; section code
;; 0000009: 00                                        ; section size (guess)
;; 000000a: 01                                        ; num types
;; ; type 0
;; 000000b: 60                                        ; func
;; 000000c: 01                                        ; num params
;; 000000d: 7f                                        ; i32
;; 000000e: 01                                        ; num results
;; 000000f: 7f                                        ; i32
;; 0000009: 06                                        ; FIXUP section size
;; ; section "Function" (3)
;; 0000010: 03                                        ; section code
;; 0000011: 00                                        ; section size (guess)
;; 0000012: 01                                        ; num functions
;; 0000013: 00                                        ; function 0 signature index
;; 0000011: 02                                        ; FIXUP section size
;; ; section "Memory" (5)
;; 0000014: 05                                        ; section code
;; 0000015: 00                                        ; section size (guess)
;; 0000016: 01                                        ; num memories
;; ; memory 0
;; 0000017: 01                                        ; limits: flags
;; 0000018: 01                                        ; limits: initial
;; 0000019: 02                                        ; limits: max
;; 0000015: 04                                        ; FIXUP section size
;; ; section "Export" (7)
;; 000001a: 07                                        ; section code
;; 000001b: 00                                        ; section size (guess)
;; 000001c: 01                                        ; num exports
;; 000001d: 03                                        ; string length
;; 000001e: 7375 6d                                  sum  ; export name
;; 0000021: 00                                        ; export kind
;; 0000022: 00                                        ; export func index
;; 000001b: 07                                        ; FIXUP section size
;; ; section "Code" (10)
;; 0000023: 0a                                        ; section code
;; 0000024: 00                                        ; section size (guess)
;; 0000025: 01                                        ; num functions
;; ; function body 0
;; 0000026: 00                                        ; func body size (guess)
;; 0000027: 01                                        ; local decl count
;; 0000028: 02                                        ; local type count
;; 0000029: 7f                                        ; i32
;; 000002a: 41                                        ; i32.const
;; 000002b: 00                                        ; i32 literal
;; 000002c: 22                                        ; tee_local
;; 000002d: 02                                        ; local index
;; 000002e: 21                                        ; set_local
;; 000002f: 01                                        ; local index
;; 0000030: 02                                        ; block
;; 0000031: 40                                        ; void
;; 0000032: 03                                        ; loop
;; 0000033: 40                                        ; void
;; 0000034: 20                                        ; get_local
;; 0000035: 01                                        ; local index
;; 0000036: 20                                        ; get_local
;; 0000037: 00                                        ; local index
;; 0000038: 46                                        ; i32.eq
;; 0000039: 0d                                        ; br_if
;; 000003a: 01                                        ; break depth
;; 000003b: 20                                        ; get_local
;; 000003c: 01                                        ; local index
;; 000003d: 41                                        ; i32.const
;; 000003e: 04                                        ; i32 literal
;; 000003f: 6c                                        ; i32.mul
;; 0000040: 28                                        ; i32.load
;; 0000041: 02                                        ; alignment
;; 0000042: 00                                        ; load offset
;; 0000043: 20                                        ; get_local
;; 0000044: 02                                        ; local index
;; 0000045: 6a                                        ; i32.add
;; 0000046: 21                                        ; set_local
;; 0000047: 02                                        ; local index
;; 0000048: 20                                        ; get_local
;; 0000049: 01                                        ; local index
;; 000004a: 41                                        ; i32.const
;; 000004b: 01                                        ; i32 literal
;; 000004c: 6a                                        ; i32.add
;; 000004d: 21                                        ; set_local
;; 000004e: 01                                        ; local index
;; 000004f: 0c                                        ; br
;; 0000050: 00                                        ; break depth
;; 0000051: 0b                                        ; end
;; 0000052: 0b                                        ; end
;; 0000053: 20                                        ; get_local
;; 0000054: 02                                        ; local index
;; 0000055: 0b                                        ; end
;; 0000026: 2f                                        ; FIXUP func body size
;; 0000024: 31                                        ; FIXUP section size
;; ; section "Data" (11)
;; 0000056: 0b                                        ; section code
;; 0000057: 00                                        ; section size (guess)
;; 0000058: 01                                        ; num data segments
;; ; data segment header 0
;; 0000059: 00                                        ; memory index
;; 000005a: 41                                        ; i32.const
;; 000005b: 00                                        ; i32 literal
;; 000005c: 0b                                        ; end
;; 000005d: 10                                        ; data segment size
;; ; data segment data 0
;; 000005e: 0100 0000 0200 0000 0300 0000 0400 0000   ; data segment data
;; 0000057: 16                                        ; FIXUP section size
