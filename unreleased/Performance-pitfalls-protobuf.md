---
layout: unlisted
title: Performance Pitfalls in C# / .NET - Protobuf - repeated uint32 vs repeated fixed32
date: 2026-07-30
description: Looking at the performance of gRPC/protobuf serialisation
tagline: How could a uint32[] possibly be slow?
image: https://richardcocks.github.io/assets/img/1benchmark.png
---
# Performance Pitfalls in C# / .NET - Protobuf Arrays - `repeated uint32` vs `repeated fixed32`

As I find myself doing often, I was recently benchmarking transfer of a random stream with gRPC.

I wanted a batch of random numbers streamed between processes, and so my naive protobuf was defined as such:

```
syntax = "proto3";

option csharp_namespace = "RandomNumberGrpc";

package randomService;

message NumberBatch {
  int64 sequenceNumber = 1;
  repeated uint32 values = 2;
}
```

Naive, and looking retrospectively with some help from Our Friend, it was pointed out to me that `fixed32` would be faster. What I hadn't appreciated was just _how much_ faster the serialisation would be.

Upon learning that `uint32` is variable encoded, I expected a stream of `fixed32` to be reasonably faster, due to always being 4 bytes rather than being up to 5 bytes. I was expecting a speed increase of up to 2x, due to increased allocation and parsing overhead.

I didn't expect it to be a factor of 5.7x faster on my transfer benchmarks.

In fact, my stream of `uint32` was capped by CPU time in the protobuf encoding and decoding, switching to `fixed32` removed this and the transport layer became the bottleneck.

Removing the transport and microbenchmarking the serialisation and parsing directly, I certainly didn't expect over **a 190x speed difference** on serialisation between `uint32` and `fixed32`, and a 59x difference in parsing speed.

## Microbenchmarks - Results

Note: Smaller is better

### Ratio vs `fixed32` by batch size

Serialize:

| N | `uint32` random | `uint32` small (<128) | `uint32` medium (<16k) |
|---:|---:|---:|---:|
| 16 | 3.09 | 1.20 | 1.55 |
| 64 | 11.30 | 4.19 | 5.93 |
| 256 | 40.75 | 14.13 | 20.50 |
| 1,024 | 125.50 | 42.69 | 63.38 |
| 10,000 | 197.69 | 75.56 | 99.69 |

Parse:

| N | `uint32` random | `uint32` small (<128) | `uint32` medium (<16k) |
|---:|---:|---:|---:|
| 16 | 1.83 | 1.21 | 1.27 |
| 64 | 5.04 | 2.85 | 3.20 |
| 256 | 15.22 | 7.60 | 8.57 |
| 1,024 | 33.58 | 15.85 | 18.61 |
| 10,000 | 59.56 | 32.22 | 36.56 |

### Wire size ( 10k array size )

| scenario | bytes/value | notes |
|---|---|---|
| `fixed32` | 4.00 | always 4, by definition |
| `uint32` varint, random | 4.94 | 93.75% of values need the full 5 bytes |
| `uint32` varint, small (<128) | 1.00 | varint's best case |
| `uint32` varint, medium (<16384) | 1.99 | |
| `int32` varint, random | 7.40 | negatives sign-extend to 64 bits, 10 bytes each |
| `sint32` zigzag, random | 4.94 | recovers the `uint32` size |

### Serialize ( 10k array size )

| Scenario | Mean (ns/value) | Error | Ratio | RatioSD |
|---|---:|---:|---:|---:|
| **`fixed32`** | **0.0763** | 0.0018 | **1.00** | 0.02 |
| `uint32` small (<128) | 5.7624 | 0.2614 | 75.56 | 2.43 |
| `uint32` medium (<16k) | 7.6027 | 0.2225 | 99.69 | 2.35 |
| `sint32` zigzag random | 14.6771 | 0.2054 | 192.45 | 3.20 |
| `uint32` random | 15.0770 | 0.4895 | 197.69 | 4.97 |
| `int32` random | 24.6258 | 0.2570 | 322.89 | 5.00 |

### Parse ( 10k array size )

| Scenario | Mean (ns/value) | Error | Ratio | Allocated | Alloc Ratio |
|---|---:|---:|---:|---:|---:|
| **`fixed32`** | **0.2057** | 0.0143 | **1.00** | 4 B | 1.00 |
| `uint32` small (<128) | 6.6161 | 0.1724 | 32.22 | 13 B | 3.25 |
| `uint32` medium (<16k) | 7.5080 | 0.1826 | 36.56 | 13 B | 3.25 |
| `uint32` random | 12.2316 | 0.2528 | 59.56 | 13 B | 3.25 |
| `sint32` zigzag random | 12.6286 | 0.7901 | 61.50 | 13 B | 3.25 |
| `int32` random | 20.4702 | 0.3753 | 99.68 | 13 B | 3.25 |

- BenchmarkDotNet v0.15.8, Google.Protobuf 3.35.1
- .NET 10.0.10, X64 RyuJIT x86-64-v3, `net10.0`
- Windows 10 22H2 (19045), AMD Ryzen 7 3800X, 8 physical / 16 logical cores

## Results Commentary

Firstly, the memory allocation difference in parsing is clear, a set 3.25 ratio on all the variable length encodings. This is due to array resizing.

But that doesn't explain away the vast gulf in performance. Even with small uint32 values that fit in a single byte when variable encoded, `fixed32` gives far better performance than `uint32`. So what is going on here?

The major difference on the serialisation side is due to how `RepeatedField<T>.WriteTo` is implemented:

```
if (TryGetArrayAsSpanPinnedUnsafe(codec, out Span<byte> span, out GCHandle handle))
{
    span = span.Slice(0, Count * codec.FixedSize);
    WritingPrimitives.WriteRawBytes(ref ctx.buffer, ref ctx.state, span);
    handle.Free();
}
else
{
    for (int i = 0; i < count; i++) writer(ref ctx, array[i]);
}
```

The whole span written as raw bytes vs a loop emitting entries at a time. In retrospect an obvious win.

On the parsing side, the length of the output cannot be derived, and so there is also overhead in per-element parsing, and with the additional overhead of needing to resize the output buffer each power of two, and each time paying for a bounds-check in the `Add(T item)` call:

```
public void Add(T item)
{
    ProtoPreconditions.CheckNotNullUnconstrained(item, nameof(item));
    EnsureSize(count + 1);
    array[count++] = item;
}

private void EnsureSize(int size)
{
    if (array.Length < size)
    {
        size = Math.Max(size, MinArraySize);
        int newSize = Math.Max(array.Length * 2, size);
        SetSize(newSize);
    }
}
```

With a capacity comparison on every item added.

The fixed size parsing however can set capacity once with `EnsureSize(count + (length / codec.FixedSize));`, as well as the varint decoding itself also having overhead compared to a straight copy of known-endianness `fixed32` values.

## Conclusion

It's also worth pointing out, that for very small arrays, `uint32` comfortably beats `fixed32`, this optimisation only works for larger arrays, where the fixed cost of `GCHandle` and raw byte copying is worth paying compared to the simple loop.

Not only this, but with small arrays it'll be a fraction of the transport overhead. However, for larger arrays, `fixed32` becomes a clear winner. What surprised me a bit was how small the crossover point is. In pure serialisation, the crossover point is somewhere between 4 and 16 elements, although that will be made up with wire/transport costs at that size. On my machine, the crossover for being worth it after transport costs was around 64 elements.

You should not take the above to be a blanket recommendation of `fixed32`, there are significant downsides to saturating your memory bandwidth instead of your CPU time, although for maximising transfer, `fixed32` was still overall faster even scaled to all 8 of my cores.

If you are doing local IPC and are CPU bottlenecked instead of RPC and being network bandwidth constrained, and are transferring any kind of larger arrays of values in gRPC / protobuf, then be sure to consider a fixed size value and not variable length fields within the array.

This is still an unusual and artificial scenario, since most servers tend to run with excess CPU capacity even relative to memory bandwidth.

Also, for anything going across the wire, any smaller serialisation will almost always win out unless you can push over an estimated 1Gbit/sec. Whether the varint serialisation is smaller is also dependent on the range of values, for truly random data, frequent high bits will cause a larger varint serialisation.

On my machine, with a 512KB per core L2 cache, this advantage of transfer with a single core peaked at around 200x, at somewhere between 8k and 16k array length. This trailed off to merely 167x advantage once it spilled into L3 cache.

When scaled to multiple cores with memory bandwidth contention and cache-spilling, this advantage narrowed heavily to ~9.48x.

## Footnote: `bytes`

If you can reliably control for endianness and message size, then `bytes` has the same bulk copy semantics. This also lets you use other serialisers, which may be faster for your particular needs. As with anything, _always measure_ your particular scenarios. There is no better way to determine what works best for you.

Source code for benchmarks available at https://github.com/richardcocks/protobuf-varint-vs-fixed32

## Addendum - Datatables

### End-to-end gRPC streaming throughput

| values per message | `fixed32` values/sec | `uint32` values/sec | ratio |
|---:|---:|---:|---:|
| 1 | 590,781 | 653,108 | 0.90 |
| 10 | 5,709,851 | 4,428,514 | 1.29 |
| 100 | 40,296,542 | 16,068,879 | 2.51 |
| 1,000 | 118,643,270 | 20,786,817 | 5.71 |
| 10,000 | 171,156,887 | 38,105,392 | 4.49 |
| 100,000 | 175,583,638 | 36,380,059 | 4.83 |

### Singular (non-`repeated`) fields — per message

| Category | Scenario | Mean | Ratio | Message size |
|---|---|---:|---:|---:|
| Serialize | `fixed32` | 30.30 ns | 1.00 | 8 B |
| Serialize | `uint32` | 38.92 ns | 1.28 | 9 B |
| Serialize | `int32` (negative) | 51.22 ns | 1.69 | 14 B |
| Parse | `fixed32` | 58.32 ns | 1.00 | |
| Parse | `uint32` | 56.84 ns | 0.98 | |
| Parse | `int32` (negative) | 58.62 ns | 1.01 | |

### Array length sweep — serialization, per message

| N | `fixed32` | `uint32` | ratio | `int32` | ratio |
|---:|---:|---:|---:|---:|---:|
| 1 | 83.52 ns | 38.25 ns | 0.46 | 49.66 ns | 0.59 |
| 4 | 78.06 ns | 73.89 ns | 0.95 | 96.91 ns | 1.24 |
| 16 | 82.30 ns | 263.83 ns | 3.21 | 357.59 ns | 4.35 |
| 64 | 84.83 ns | 969.16 ns | 11.42 | 1,413.52 ns | 16.66 |
| 256 | 93.31 ns | 3,801.52 ns | 40.74 | 5,435.40 ns | 58.25 |
| 1,024 | 120.92 ns | 15,210.79 ns | 125.79 | 22,917.93 ns | 189.53 |
| 8,192 | 635.78 ns | 119,693.73 ns | 188.27 | 203,784.41 ns | 320.54 |
| 65,536 | 5,742.85 ns | 962,093.92 ns | 167.55 | 1,671,699.69 ns | 291.14 |

### Measured protobuf write paths

`[packed = false]` routes a repeated field through protobuf's per-element
writer. Applying it to `fixed32` as well as `uint32` gives two paths that share
the same dispatch, tag writing and buffer bookkeeping, differing only in how
each value is emitted.

| Path | ns/value | vs packed `fixed32` |
|---|---:|---:|
| packed `fixed32` (bulk copy) | 0.0804 | 1.00 |
| unpacked `fixed32` (per-element) | 6.1983 | 77.21 |
| unpacked `uint32` (per-element) | 14.9375 | 186.08 |
| packed `uint32` | 15.3743 | 191.52 |

| `CalculateSize` | ns/value |
|---|---:|
| packed `fixed32` | 0.0003 |
| packed `uint32` | 2.8213 |
| unpacked `uint32` | 2.8658 |

### Decomposition

Every endpoint is a real protobuf code path; no hand-written stand-ins.

| Step | Compares | Factor | Share (log-space) |
|---|---|---:|---:|
| bulk copy lost | packed → unpacked `fixed32` | 77.1x | **82.7%** |
| varint emit | unpacked `fixed32` → unpacked `uint32` | 2.41x | 16.7% |
| packing overhead | unpacked → packed `uint32` | 1.03x | 0.5% |
| **total** | packed `fixed32` → packed `uint32` | **191.2x** | 100% |

### Cache effects at large N

| N | `fixed32` | `uint32` | ratio | `fixed32` ns/value | copy bandwidth | working set |
|---:|---:|---:|---:|---:|---:|---:|
| 16,384 | 1.257 µs | 251.1 µs | 200.13 | 0.0767 | 52.1 GB/s | 128 KB |
| 32,768 | 2.606 µs | 505.5 µs | 194.36 | 0.0795 | 50.3 GB/s | 256 KB |
| 65,535 | 5.756 µs | 1,003.7 µs | 174.57 | 0.0878 | 45.5 GB/s | 512 KB |
| 65,536 | 5.841 µs | 1,002.9 µs | 171.88 | 0.0891 | 44.9 GB/s | 512 KB |
| 65,537 | 5.882 µs | 1,004.6 µs | 171.09 | 0.0898 | 44.6 GB/s | 512 KB |
| 131,072 | 12.285 µs | 2,050.9 µs | 167.18 | 0.0937 | 42.7 GB/s | 1 MB |

### `bytes` vs `repeated fixed32`

Both encode to 40,004 bytes for 10,000 values — packed `repeated fixed32`
and a `bytes` field are byte-identical on the wire.

| Category | Method | Mean (ns/value) | Ratio | Allocated |
|---|---|---:|---:|---:|
| Serialize | `repeated fixed32` | 0.0752 | 1.00 | – |
| Serialize | `bytes` (hand-packed) | 0.0730 | 0.97 | – |
| Parse | `repeated fixed32` | 0.2196 | 1.00 | 4 B |
| Parse | `bytes` + `MemoryMarshal.Cast` | 0.2310 | 1.06 | 4 B |

### Memory bandwidth contention

Each invocation serialises `Threads x 1,000,000` values, one message per thread.

| Threads | `fixed32` | `uint32` | ratio | `fixed32` speedup | `uint32` speedup |
|---:|---:|---:|---:|---:|---:|
| 1 | 178.0 µs | 14,372 µs | 80.79 | 1.00x | 1.00x |
| 2 | 383.0 µs | 16,209 µs | 42.37 | 0.93x | 1.77x |
| 4 | 1,060.9 µs | 16,472 µs | 15.53 | 0.67x | 3.49x |
| 8 | 1,936.2 µs | 18,323 µs | 9.48 | 0.74x | 6.28x |