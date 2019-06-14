(module
  (func $shift_right (export "shift_right") (param $lhs i32) (param $rhs i32) (result i32)
    (i32.shr_u
      (get_local $lhs)
      (get_local $rhs)
    )
  )
)

;; wat2wasm -v shift_right.wat
;; 0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
;; 0000004: 0100 0000                                 ; WASM_BINARY_VERSION
;; ; section "Type" (1)
;; 0000008: 01                                        ; section code
;; 0000009: 00                                        ; section size (guess)
;; 000000a: 01                                        ; num types
;; ; type 0
;; 000000b: 60                                        ; func
;; 000000c: 02                                        ; num params
;; 000000d: 7f                                        ; i32
;; 000000e: 7f                                        ; i32
;; 000000f: 01                                        ; num results
;; 0000010: 7f                                        ; i32
;; 0000009: 07                                        ; FIXUP section size
;; ; section "Function" (3)
;; 0000011: 03                                        ; section code
;; 0000012: 00                                        ; section size (guess)
;; 0000013: 01                                        ; num functions
;; 0000014: 00                                        ; function 0 signature index
;; 0000012: 02                                        ; FIXUP section size
;; ; section "Export" (7)
;; 0000015: 07                                        ; section code
;; 0000016: 00                                        ; section size (guess)
;; 0000017: 01                                        ; num exports
;; 0000018: 0b                                        ; string length
;; 0000019: 7368 6966 745f 7269 6768 74              shift_right  ; export name
;; 0000024: 00                                        ; export kind
;; 0000025: 00                                        ; export func index
;; 0000016: 0f                                        ; FIXUP section size
;; ; section "Code" (10)
;; 0000026: 0a                                        ; section code
;; 0000027: 00                                        ; section size (guess)
;; 0000028: 01                                        ; num functions
;; ; function body 0
;; 0000029: 00                                        ; func body size (guess)
;; 000002a: 00                                        ; local decl count
;; 000002b: 20                                        ; local.get
;; 000002c: 00                                        ; local index
;; 000002d: 20                                        ; local.get
;; 000002e: 01                                        ; local index
;; 000002f: 76                                        ; i32.shr_u
;; 0000030: 0b                                        ; end
;; 0000029: 07                                        ; FIXUP func body size
;; 0000027: 09                                        ; FIXUP section size
