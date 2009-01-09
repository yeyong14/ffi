require File.expand_path(File.join(File.dirname(__FILE__), "bench_helper"))

require 'benchmark'
require 'ffi'
iter = 100_000

module StructBench
  extend FFI::Library
  extend FFI::Library
  ffi_lib LIBTEST_PATH
  attach_function :bench_s32_v, [ :int ], :void
  attach_function :bench_struct_in, :ptr_ret_int32_t, [ :buffer_in, :int ], :void
  attach_function :bench_struct_out, :ptr_ret_int32_t, [ :buffer_out, :int ], :void
  attach_function :bench_struct_inout, :ptr_ret_int32_t, [ :buffer_inout, :int ], :void
end
class TestStruct < FFI::Struct
  layout :i, :int, :p, :pointer
end
puts "Benchmark FFI call(Struct.alloc_in) performance, #{iter}x"
10.times {
  puts Benchmark.measure {
    iter.times { StructBench.bench_struct_in(TestStruct.alloc_in, 0) }
  }
}
puts "Benchmark FFI call(Struct.alloc_out) performance, #{iter}x"
10.times {
  puts Benchmark.measure {
    iter.times { StructBench.bench_struct_out(TestStruct.alloc_out, 0) }
  }
}
puts "Benchmark FFI call(Struct.alloc_inout) performance, #{iter}x"
10.times {
  puts Benchmark.measure {
    iter.times { StructBench.bench_struct_inout(TestStruct.alloc_inout, 0) }
  }
}
s = TestStruct.new
puts "Benchmark FFI Struct.get(:int) performance, #{iter}x"
10.times {
  puts Benchmark.measure {
    iter.times { s[:i] }
  }
}
puts "Benchmark FFI Struct.put(:int) performance, #{iter}x"
10.times {
  puts Benchmark.measure {
    iter.times { s[:i] = 0x12345678 }
  }
}
puts "Benchmark FFI Struct.get(:pointer) performance, #{iter}x"
10.times {
  puts Benchmark.measure {
    iter.times { s[:p] }
  }
}
puts "Benchmark FFI Struct.put(:pointer) performance, #{iter}x"
10.times {
  p = MemoryPointer.new :int
  puts Benchmark.measure {
    iter.times { s[:p] = p }
  }
}
puts "Benchmark FFI Struct.get(:string) performance, #{iter}x"
class StringStruct < FFI::Struct
  layout :s, :string
end
10.times {
  mp = MemoryPointer.new 1024
  mp.put_string(0, "Hello, World")
  s = StringStruct.new
  s.pointer.put_pointer(0, mp)
  puts Benchmark.measure {
    iter.times { s[:s] }
  }
}
