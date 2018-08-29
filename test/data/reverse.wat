(module
  (memory (import "env" "str") 0)
  (func (export "reverse") (param $len i32)
    (local $a i32)
    (local $b i32)
    (local $i i32)
    (local $j i32)
    (local $half i32)
    (set_local $i (i32.const 0))
    (set_local $half (i32.div_u (get_local $len) (i32.const 2)))

    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $half)))
      (set_local $j (i32.sub (i32.sub (get_local $len) (get_local $i)) (i32.const 1)))
      (set_local $a (i32.load8_u (get_local $i)))
      (set_local $b (i32.load8_u (get_local $j)))
      (i32.store8 (get_local $j) (get_local $a))
      (i32.store8 (get_local $i) (get_local $b))
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )
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
;; 000000e: 00                                        ; num results
;; 0000009: 05                                        ; FIXUP section size
;; ; section "Import" (2)
;; 000000f: 02                                        ; section code
;; 0000010: 00                                        ; section size (guess)
;; 0000011: 01                                        ; num imports
;; ; import header 0
;; 0000012: 03                                        ; string length
;; 0000013: 656e 76                                  env  ; import module name
;; 0000016: 03                                        ; string length
;; 0000017: 7374 72                                  str  ; import field name
;; 000001a: 02                                        ; import kind
;; 000001b: 00                                        ; limits: flags
;; 000001c: 00                                        ; limits: initial
;; 0000010: 0c                                        ; FIXUP section size
;; ; section "Function" (3)
;; 000001d: 03                                        ; section code
;; 000001e: 00                                        ; section size (guess)
;; 000001f: 01                                        ; num functions
;; 0000020: 00                                        ; function 0 signature index
;; 000001e: 02                                        ; FIXUP section size
;; ; section "Export" (7)
;; 0000021: 07                                        ; section code
;; 0000022: 00                                        ; section size (guess)
;; 0000023: 01                                        ; num exports
;; 0000024: 07                                        ; string length
;; 0000025: 7265 7665 7273 65                        reverse  ; export name
;; 000002c: 00                                        ; export kind
;; 000002d: 00                                        ; export func index
;; 0000022: 0b                                        ; FIXUP section size
;; ; section "Code" (10)
;; 000002e: 0a                                        ; section code
;; 000002f: 00                                        ; section size (guess)
;; 0000030: 01                                        ; num functions
;; ; function body 0
;; 0000031: 00                                        ; func body size (guess)
;; 0000032: 01                                        ; local decl count
;; 0000033: 05                                        ; local type count
;; 0000034: 7f                                        ; i32
;; 0000035: 41                                        ; i32.const
;; 0000036: 00                                        ; i32 literal
;; 0000037: 21                                        ; set_local
;; 0000038: 03                                        ; local index
;; 0000039: 20                                        ; get_local
;; 000003a: 00                                        ; local index
;; 000003b: 41                                        ; i32.const
;; 000003c: 02                                        ; i32 literal
;; 000003d: 6e                                        ; i32.div_u
;; 000003e: 21                                        ; set_local
;; 000003f: 05                                        ; local index
;; 0000040: 02                                        ; block
;; 0000041: 40                                        ; void
;; 0000042: 03                                        ; loop
;; 0000043: 40                                        ; void
;; 0000044: 20                                        ; get_local
;; 0000045: 03                                        ; local index
;; 0000046: 20                                        ; get_local
;; 0000047: 05                                        ; local index
;; 0000048: 46                                        ; i32.eq
;; 0000049: 0d                                        ; br_if
;; 000004a: 01                                        ; break depth
;; 000004b: 20                                        ; get_local
;; 000004c: 00                                        ; local index
;; 000004d: 20                                        ; get_local
;; 000004e: 03                                        ; local index
;; 000004f: 6b                                        ; i32.sub
;; 0000050: 41                                        ; i32.const
;; 0000051: 01                                        ; i32 literal
;; 0000052: 6b                                        ; i32.sub
;; 0000053: 21                                        ; set_local
;; 0000054: 04                                        ; local index
;; 0000055: 20                                        ; get_local
;; 0000056: 03                                        ; local index
;; 0000057: 2d                                        ; i32.load8_u
;; 0000058: 00                                        ; alignment
;; 0000059: 00                                        ; load offset
;; 000005a: 21                                        ; set_local
;; 000005b: 01                                        ; local index
;; 000005c: 20                                        ; get_local
;; 000005d: 04                                        ; local index
;; 000005e: 2d                                        ; i32.load8_u
;; 000005f: 00                                        ; alignment
;; 0000060: 00                                        ; load offset
;; 0000061: 21                                        ; set_local
;; 0000062: 02                                        ; local index
;; 0000063: 20                                        ; get_local
;; 0000064: 04                                        ; local index
;; 0000065: 20                                        ; get_local
;; 0000066: 01                                        ; local index
;; 0000067: 3a                                        ; i32.store8
;; 0000068: 00                                        ; alignment
;; 0000069: 00                                        ; store offset
;; 000006a: 20                                        ; get_local
;; 000006b: 03                                        ; local index
;; 000006c: 20                                        ; get_local
;; 000006d: 02                                        ; local index
;; 000006e: 3a                                        ; i32.store8
;; 000006f: 00                                        ; alignment
;; 0000070: 00                                        ; store offset
;; 0000071: 20                                        ; get_local
;; 0000072: 03                                        ; local index
;; 0000073: 41                                        ; i32.const
;; 0000074: 01                                        ; i32 literal
;; 0000075: 6a                                        ; i32.add
;; 0000076: 21                                        ; set_local
;; 0000077: 03                                        ; local index
;; 0000078: 0c                                        ; br
;; 0000079: 00                                        ; break depth
;; 000007a: 0b                                        ; end
;; 000007b: 0b                                        ; end
;; 000007c: 0b                                        ; end
;; 0000031: 4b                                        ; FIXUP func body size
;; 000002f: 4d                                        ; FIXUP section size
