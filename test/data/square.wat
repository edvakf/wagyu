;; square(i32 i) -> i32
(module
  (func (export "square") (param $i i32) (result i32)
    (i32.mul
      (get_local $i)
      (get_local $i))))

;; $ wat2wasm -v square.wat
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
;; ; section "Export" (7)
;; 0000014: 07                                        ; section code
;; 0000015: 00                                        ; section size (guess)
;; 0000016: 01                                        ; num exports
;; 0000017: 06                                        ; string length
;; 0000018: 7371 7561 7265                           square  ; export name
;; 000001e: 00                                        ; export kind
;; 000001f: 00                                        ; export func index
;; 0000015: 0a                                        ; FIXUP section size
;; ; section "Code" (10)
;; 0000020: 0a                                        ; section code
;; 0000021: 00                                        ; section size (guess)
;; 0000022: 01                                        ; num functions
;; ; function body 0
;; 0000023: 00                                        ; func body size (guess)
;; 0000024: 00                                        ; local decl count
;; 0000025: 20                                        ; get_local
;; 0000026: 00                                        ; local index
;; 0000027: 20                                        ; get_local
;; 0000028: 00                                        ; local index
;; 0000029: 6c                                        ; i32.mul
;; 000002a: 0b                                        ; end
;; 0000023: 07                                        ; FIXUP func body size
;; 0000021: 09                                        ; FIXUP section size
