(module
  (func $shift_left (export "shift_left") (param $lhs i32) (param $rhs i32) (result i32)
    (i32.shl
      (get_local $lhs)
      (get_local $rhs)
    )
  )
)

;; wat2wasm -v shift_left.wat
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
;; 0000018: 0a                                        ; string length
;; 0000019: 7368 6966 745f 6c65 6674                 shift_left  ; export name
;; 0000023: 00                                        ; export kind
;; 0000024: 00                                        ; export func index
;; 0000016: 0e                                        ; FIXUP section size
;; ; section "Code" (10)
;; 0000025: 0a                                        ; section code
;; 0000026: 00                                        ; section size (guess)
;; 0000027: 01                                        ; num functions
;; ; function body 0
;; 0000028: 00                                        ; func body size (guess)
;; 0000029: 00                                        ; local decl count
;; 000002a: 20                                        ; local.get
;; 000002b: 00                                        ; local index
;; 000002c: 20                                        ; local.get
;; 000002d: 01                                        ; local index
;; 000002e: 74                                        ; i32.shl
;; 000002f: 0b                                        ; end
;; 0000028: 07                                        ; FIXUP func body size
;; 0000026: 09                                        ; FIXUP section size
