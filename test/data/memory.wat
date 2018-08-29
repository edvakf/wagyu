;; https://ukyo.github.io/wasm-usui-book/webroot/get-started-webassembly.html
;; sum of $n integers (0 <= $n <= 4)
(module
  (memory (export "mem") 1 2)
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
;; 000001c: 02                                        ; num exports
;; 000001d: 03                                        ; string length
;; 000001e: 6d65 6d                                  mem  ; export name
;; 0000021: 02                                        ; export kind
;; 0000022: 00                                        ; export memory index
;; 0000023: 03                                        ; string length
;; 0000024: 7375 6d                                  sum  ; export name
;; 0000027: 00                                        ; export kind
;; 0000028: 00                                        ; export func index
;; 000001b: 0d                                        ; FIXUP section size
;; ; section "Code" (10)
;; 0000029: 0a                                        ; section code
;; 000002a: 00                                        ; section size (guess)
;; 000002b: 01                                        ; num functions
;; ; function body 0
;; 000002c: 00                                        ; func body size (guess)
;; 000002d: 01                                        ; local decl count
;; 000002e: 02                                        ; local type count
;; 000002f: 7f                                        ; i32
;; 0000030: 41                                        ; i32.const
;; 0000031: 00                                        ; i32 literal
;; 0000032: 22                                        ; tee_local
;; 0000033: 02                                        ; local index
;; 0000034: 21                                        ; set_local
;; 0000035: 01                                        ; local index
;; 0000036: 02                                        ; block
;; 0000037: 40                                        ; void
;; 0000038: 03                                        ; loop
;; 0000039: 40                                        ; void
;; 000003a: 20                                        ; get_local
;; 000003b: 01                                        ; local index
;; 000003c: 20                                        ; get_local
;; 000003d: 00                                        ; local index
;; 000003e: 46                                        ; i32.eq
;; 000003f: 0d                                        ; br_if
;; 0000040: 01                                        ; break depth
;; 0000041: 20                                        ; get_local
;; 0000042: 01                                        ; local index
;; 0000043: 41                                        ; i32.const
;; 0000044: 04                                        ; i32 literal
;; 0000045: 6c                                        ; i32.mul
;; 0000046: 28                                        ; i32.load
;; 0000047: 02                                        ; alignment
;; 0000048: 00                                        ; load offset
;; 0000049: 20                                        ; get_local
;; 000004a: 02                                        ; local index
;; 000004b: 6a                                        ; i32.add
;; 000004c: 21                                        ; set_local
;; 000004d: 02                                        ; local index
;; 000004e: 20                                        ; get_local
;; 000004f: 01                                        ; local index
;; 0000050: 41                                        ; i32.const
;; 0000051: 01                                        ; i32 literal
;; 0000052: 6a                                        ; i32.add
;; 0000053: 21                                        ; set_local
;; 0000054: 01                                        ; local index
;; 0000055: 0c                                        ; br
;; 0000056: 00                                        ; break depth
;; 0000057: 0b                                        ; end
;; 0000058: 0b                                        ; end
;; 0000059: 20                                        ; get_local
;; 000005a: 02                                        ; local index
;; 000005b: 0b                                        ; end
;; 000002c: 2f                                        ; FIXUP func body size
;; 000002a: 31                                        ; FIXUP section size
;; ; section "Data" (11)
;; 000005c: 0b                                        ; section code
;; 000005d: 00                                        ; section size (guess)
;; 000005e: 01                                        ; num data segments
;; ; data segment header 0
;; 000005f: 00                                        ; memory index
;; 0000060: 41                                        ; i32.const
;; 0000061: 00                                        ; i32 literal
;; 0000062: 0b                                        ; end
;; 0000063: 0c                                        ; data segment size
;; ; data segment data 0
;; 0000064: 0100 0000 0200 0000 0300 0000             ; data segment data
;; 000005d: 12                                        ; FIXUP section size
