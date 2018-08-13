;; x = sqrt( a^2 + b^2 )
(module
  (func $square (param $num f32) (result f32)
    (f32.mul
      (get_local $num)
      (get_local $num)))
  (func $rms (param $lhs f32) (param $rhs f32) (result f32)
    get_local $lhs
    call $square
    get_local $rhs
    call $square
    f32.add
    f32.sqrt)
  (export "rms" (func $rms))
)

;; $ wat2wasm -v rms.wat
;; 0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
;; 0000004: 0100 0000                                 ; WASM_BINARY_VERSION
;; ; section "Type" (1)
;; 0000008: 01                                        ; section code
;; 0000009: 00                                        ; section size (guess)
;; 000000a: 02                                        ; num types
;; ; type 0
;; 000000b: 60                                        ; func
;; 000000c: 01                                        ; num params
;; 000000d: 7d                                        ; f32
;; 000000e: 01                                        ; num results
;; 000000f: 7d                                        ; f32
;; ; type 1
;; 0000010: 60                                        ; func
;; 0000011: 02                                        ; num params
;; 0000012: 7d                                        ; f32
;; 0000013: 7d                                        ; f32
;; 0000014: 01                                        ; num results
;; 0000015: 7d                                        ; f32
;; 0000009: 0c                                        ; FIXUP section size
;; ; section "Function" (3)
;; 0000016: 03                                        ; section code
;; 0000017: 00                                        ; section size (guess)
;; 0000018: 02                                        ; num functions
;; 0000019: 00                                        ; function 0 signature index
;; 000001a: 01                                        ; function 1 signature index
;; 0000017: 03                                        ; FIXUP section size
;; ; section "Export" (7)
;; 000001b: 07                                        ; section code
;; 000001c: 00                                        ; section size (guess)
;; 000001d: 01                                        ; num exports
;; 000001e: 03                                        ; string length
;; 000001f: 726d 73                                  rms  ; export name
;; 0000022: 00                                        ; export kind
;; 0000023: 01                                        ; export func index
;; 000001c: 07                                        ; FIXUP section size
;; ; section "Code" (10)
;; 0000024: 0a                                        ; section code
;; 0000025: 00                                        ; section size (guess)
;; 0000026: 02                                        ; num functions
;; ; function body 0
;; 0000027: 00                                        ; func body size (guess)
;; 0000028: 00                                        ; local decl count
;; 0000029: 20                                        ; get_local
;; 000002a: 00                                        ; local index
;; 000002b: 20                                        ; get_local
;; 000002c: 00                                        ; local index
;; 000002d: 94                                        ; f32.mul
;; 000002e: 0b                                        ; end
;; 0000027: 07                                        ; FIXUP func body size
;; ; function body 1
;; 000002f: 00                                        ; func body size (guess)
;; 0000030: 00                                        ; local decl count
;; 0000031: 20                                        ; get_local
;; 0000032: 00                                        ; local index
;; 0000033: 10                                        ; call
;; 0000034: 00                                        ; function index
;; 0000035: 20                                        ; get_local
;; 0000036: 01                                        ; local index
;; 0000037: 10                                        ; call
;; 0000038: 00                                        ; function index
;; 0000039: 92                                        ; f32.add
;; 000003a: 91                                        ; f32.sqrt
;; 000003b: 0b                                        ; end
;; 000002f: 0c                                        ; FIXUP func body size
;; 0000025: 16                                        ; FIXUP section size

