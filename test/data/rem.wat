(module
  (func $rem (export "rem") (param $lhs i32) (param $rhs i32) (result i32)
    get_local $lhs
    get_local $rhs
    i32.rem_s
  )
)

;; wat2wasm -v rem.wat
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
;; 0000018: 03                                        ; string length
;; 0000019: 7265 6d                                  rem  ; export name
;; 000001c: 00                                        ; export kind
;; 000001d: 00                                        ; export func index
;; 0000016: 07                                        ; FIXUP section size
;; ; section "Code" (10)
;; 000001e: 0a                                        ; section code
;; 000001f: 00                                        ; section size (guess)
;; 0000020: 01                                        ; num functions
;; ; function body 0
;; 0000021: 00                                        ; func body size (guess)
;; 0000022: 00                                        ; local decl count
;; 0000023: 20                                        ; local.get
;; 0000024: 00                                        ; local index
;; 0000025: 20                                        ; local.get
;; 0000026: 01                                        ; local index
;; 0000027: 6f                                        ; i32.rem_s
;; 0000028: 0b                                        ; end
;; 0000021: 07                                        ; FIXUP func body size
;; 000001f: 09                                        ; FIXUP section size
