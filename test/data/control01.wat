;; block returns a value
(module
  (func (export "test") (result i32)
    (block $block (result i32)
      i32.const 1
      br $block
    )
  )
)
