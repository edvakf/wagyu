(module
  (table 2 anyfunc)
  (func $f1 (result i32) i32.const 42)
  (func $f2 (result i32) i32.const 13)
  (elem (i32.const 0) $f1 $f2)
  (type $return_i32 (func (result i32)))
  (func (export "callByIndex") (param $i i32) (result i32)
    get_local $i
    call_indirect (type $return_i32))
)


;; 0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
;; 0000004: 0100 0000                                 ; WASM_BINARY_VERSION
;; ; section "Type" (1)
;; 0000008: 01                                        ; section code
;; 0000009: 00                                        ; section size (guess)
;; 000000a: 02                                        ; num types
;; ; type 0
;; 000000b: 60                                        ; func
;; 000000c: 00                                        ; num params
;; 000000d: 01                                        ; num results
;; 000000e: 7f                                        ; i32
;; ; type 1
;; 000000f: 60                                        ; func
;; 0000010: 01                                        ; num params
;; 0000011: 7f                                        ; i32
;; 0000012: 01                                        ; num results
;; 0000013: 7f                                        ; i32
;; 0000009: 0a                                        ; FIXUP section size
;; ; section "Function" (3)
;; 0000014: 03                                        ; section code
;; 0000015: 00                                        ; section size (guess)
;; 0000016: 03                                        ; num functions
;; 0000017: 00                                        ; function 0 signature index
;; 0000018: 00                                        ; function 1 signature index
;; 0000019: 01                                        ; function 2 signature index
;; 0000015: 04                                        ; FIXUP section size
;; ; section "Table" (4)
;; 000001a: 04                                        ; section code
;; 000001b: 00                                        ; section size (guess)
;; 000001c: 01                                        ; num tables
;; ; table 0
;; 000001d: 70                                        ; anyfunc
;; 000001e: 00                                        ; limits: flags
;; 000001f: 02                                        ; limits: initial
;; 000001b: 04                                        ; FIXUP section size
;; ; section "Export" (7)
;; 0000020: 07                                        ; section code
;; 0000021: 00                                        ; section size (guess)
;; 0000022: 01                                        ; num exports
;; 0000023: 0b                                        ; string length
;; 0000024: 6361 6c6c 4279 496e 6465 78              callByIndex  ; export name
;; 000002f: 00                                        ; export kind
;; 0000030: 02                                        ; export func index
;; 0000021: 0f                                        ; FIXUP section size
;; ; section "Elem" (9)
;; 0000031: 09                                        ; section code
;; 0000032: 00                                        ; section size (guess)
;; 0000033: 01                                        ; num elem segments
;; ; elem segment header 0
;; 0000034: 00                                        ; table index
;; 0000035: 41                                        ; i32.const
;; 0000036: 00                                        ; i32 literal
;; 0000037: 0b                                        ; end
;; 0000038: 02                                        ; num function indices
;; 0000039: 00                                        ; function index
;; 000003a: 01                                        ; function index
;; 0000032: 08                                        ; FIXUP section size
;; ; section "Code" (10)
;; 000003b: 0a                                        ; section code
;; 000003c: 00                                        ; section size (guess)
;; 000003d: 03                                        ; num functions
;; ; function body 0
;; 000003e: 00                                        ; func body size (guess)
;; 000003f: 00                                        ; local decl count
;; 0000040: 41                                        ; i32.const
;; 0000041: 2a                                        ; i32 literal
;; 0000042: 0b                                        ; end
;; 000003e: 04                                        ; FIXUP func body size
;; ; function body 1
;; 0000043: 00                                        ; func body size (guess)
;; 0000044: 00                                        ; local decl count
;; 0000045: 41                                        ; i32.const
;; 0000046: 0d                                        ; i32 literal
;; 0000047: 0b                                        ; end
;; 0000043: 04                                        ; FIXUP func body size
;; ; function body 2
;; 0000048: 00                                        ; func body size (guess)
;; 0000049: 00                                        ; local decl count
;; 000004a: 20                                        ; get_local
;; 000004b: 00                                        ; local index
;; 000004c: 11                                        ; call_indirect
;; 000004d: 00                                        ; signature index
;; 000004e: 00                                        ; call_indirect reserved
;; 000004f: 0b                                        ; end
;; 0000048: 07                                        ; FIXUP func body size
;; 000003c: 13                                        ; FIXUP section size
