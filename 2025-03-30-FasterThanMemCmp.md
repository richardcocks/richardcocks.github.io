---
layout: post
title: What's faster than Memcmp
date: 2025-03-30
description: What could be faster than memcmp? How to quickly compare arrays using Span<T>
tagline: What could be faster than memcmp? Benefits of Span<T>
image: https://richardcocks.github.io/assets/img/1_dotnet_framework.png
---

# 2025-03-30 What's faster than Memcmp?

In this post I look at improvements in .NET and using Span<T> for performance and portability.

I was examining portability issues in a code base that I wanted to migrate from .NET framework 4.8.1 to .NET8. I discovered use of `msvcrt.dll`. I quickly established it is a [popular stackoverflow answer](https://stackoverflow.com/a/1445405/1635976) for a fast way to compare byte arrays in .NET

The answer as provided, and faithfully copied into codebases, is this:

```csharp
[DllImport("msvcrt.dll", CallingConvention=CallingConvention.Cdecl)]
static extern int memcmp(byte[] b1, byte[] b2, long count);

static bool ByteArrayCompare(byte[] b1, byte[] b2)
{
    // Validate buffers are the same length.
    // This also ensures that the count does not exceed the length of either buffer.  
    return b1.Length == b2.Length && memcmp(b1, b2, b1.Length) == 0;
}
```

A big performance improvement in modern .NET is the `Span<T>` type. The documentation describes it as:

> Provides a type-safe and memory-safe representation of a contiguous region of arbitrary memory.

That's not a super helpful description, but the summary is that it's stack-allocated rather than heap allocated.

`Span<T>` has an extension method `SequenceEqual<T>(this ReadOnlySpan<T> span, ReadOnlySpan<T> other)`, and we'll see how it fares.

```csharp
    public static bool EqualsSpan(ReadOnlySpan<byte> b1, ReadOnlySpan<byte> b2)
    {
        return b1.SequenceEqual(b2);
    }
```


Let's see how it stacks up against a couple of naive implementations, a `for` loop and using `Enumerable.SequenceEquals`:


```csharp
    public static bool EqualsLoop(byte[] b1, byte[] b2)
    {

        if (b1.Length != b2.Length) return false;
        for (int i = 0; i < b1.Length; i++)
        {
            if (b1[i] != b2[i]) return false;
        }

        return true;
    }

    public static bool EqualsSequenceEqual(byte[] b1, byte[] b2)
    {
        return b1.SequenceEqual(b2);
    }
```

We compare using two identical arrays since this is typically the worst-case for equality checking, and we're going to benchmark on a range of array sizes: 10 bytes, 1KB, 1MB and 1GB.

```csharp
    [Params(10, 1_024, 1_048_576, 1073741824)]
    public int Length { get; set; }

    byte[] first;
    byte[] second;

    [GlobalSetup]
    public void Setup()
    {
        var r = new Random(0);

        first = new byte[Length];
        second = new byte[Length];

        r.NextBytes(first);
        Array.Copy(first, second, Length);
    }
```

The setup is straightforward, we fill the first array with random data, and copy the data to the second array.


## Results

![Benchmark results graph](/assets/img/1_dotnet_framework.png "Lower is better")

```
BenchmarkDotNet v0.14.0, Windows 10 (10.0.19045.5679/22H2/2022Update)
AMD Ryzen 7 3800X, 1 CPU, 16 logical and 8 physical cores
.NET SDK 10.0.100-preview.2.25164.34
  [Host]               : .NET 9.0.3 (9.0.325.11113), X64 RyuJIT AVX2
  .NET 8.0             : .NET 8.0.14 (8.0.1425.11118), X64 RyuJIT AVX2
  .NET 9.0             : .NET 9.0.3 (9.0.325.11113), X64 RyuJIT AVX2
  .NET Framework 4.8.1 : .NET Framework 4.8.1 (4.8.9290.0), X64 RyuJIT VectorSize=256

```
| Method        | Job                  | Runtime              | Length         |                   Mean |    Ratio |  RatioSD | Allocated |
|---------------|----------------------|----------------------|----------------|-----------------------:|---------:|---------:|----------:|
| **MemCmp**    | **.NET 8.0**         | **.NET 8.0**         | **10**         |           **7.957 ns** | **0.65** | **0.01** |     **-** |
| MemCmp        | .NET 9.0             | .NET 9.0             | 10             |               7.877 ns |     0.64 |     0.01 |         - |
| MemCmp        | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 10             |              12.239 ns |     1.00 |     0.02 |         - |
|               |                      |                      |                |                        |          |          |           |
| Loop          | .NET 8.0             | .NET 8.0             | 10             |               4.390 ns |     0.88 |     0.03 |         - |
| Loop          | .NET 9.0             | .NET 9.0             | 10             |               6.439 ns |     1.29 |     0.05 |         - |
| Loop          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 10             |               4.995 ns |     1.00 |     0.03 |         - |
|               |                      |                      |                |                        |          |          |           |
| SequenceEqual | .NET 8.0             | .NET 8.0             | 10             |              21.341 ns |     0.15 |     0.00 |         - |
| SequenceEqual | .NET 9.0             | .NET 9.0             | 10             |               7.611 ns |     0.05 |     0.00 |         - |
| SequenceEqual | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 10             |             139.476 ns |     1.00 |     0.02 |      64 B |
|               |                      |                      |                |                        |          |          |           |
| Span          | .NET 8.0             | .NET 8.0             | 10             |               2.394 ns |     0.21 |     0.00 |         - |
| Span          | .NET 9.0             | .NET 9.0             | 10             |               1.624 ns |     0.14 |     0.00 |         - |
| Span          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 10             |              11.523 ns |     1.00 |     0.01 |         - |
|               |                      |                      |                |                        |          |          |           |
| **MemCmp**    | **.NET 8.0**         | **.NET 8.0**         | **1024**       |          **36.745 ns** | **0.89** | **0.01** |     **-** |
| MemCmp        | .NET 9.0             | .NET 9.0             | 1024           |              36.317 ns |     0.88 |     0.01 |         - |
| MemCmp        | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1024           |              41.452 ns |     1.00 |     0.01 |         - |
|               |                      |                      |                |                        |          |          |           |
| Loop          | .NET 8.0             | .NET 8.0             | 1024           |             247.326 ns |     0.66 |     0.01 |         - |
| Loop          | .NET 9.0             | .NET 9.0             | 1024           |             246.738 ns |     0.66 |     0.01 |         - |
| Loop          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1024           |             372.410 ns |     1.00 |     0.01 |         - |
|               |                      |                      |                |                        |          |          |           |
| SequenceEqual | .NET 8.0             | .NET 8.0             | 1024           |              32.069 ns |    0.003 |     0.00 |         - |
| SequenceEqual | .NET 9.0             | .NET 9.0             | 1024           |              21.439 ns |    0.002 |     0.00 |         - |
| SequenceEqual | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1024           |           9,542.293 ns |    1.000 |     0.02 |      64 B |
|               |                      |                      |                |                        |          |          |           |
| Span          | .NET 8.0             | .NET 8.0             | 1024           |              12.408 ns |     0.51 |     0.01 |         - |
| Span          | .NET 9.0             | .NET 9.0             | 1024           |              12.310 ns |     0.51 |     0.01 |         - |
| Span          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1024           |              24.117 ns |     1.00 |     0.01 |         - |
|               |                      |                      |                |                        |          |          |           |
| **MemCmp**    | **.NET 8.0**         | **.NET 8.0**         | **1048576**    |      **31,477.776 ns** | **0.99** | **0.02** |     **-** |
| MemCmp        | .NET 9.0             | .NET 9.0             | 1048576        |          31,790.009 ns |     1.00 |     0.02 |         - |
| MemCmp        | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1048576        |          31,693.469 ns |     1.00 |     0.02 |         - |
|               |                      |                      |                |                        |          |          |           |
| Loop          | .NET 8.0             | .NET 8.0             | 1048576        |         247,350.116 ns |     0.65 |     0.01 |         - |
| Loop          | .NET 9.0             | .NET 9.0             | 1048576        |         251,317.223 ns |     0.66 |     0.02 |         - |
| Loop          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1048576        |         379,628.993 ns |     1.00 |     0.02 |         - |
|               |                      |                      |                |                        |          |          |           |
| SequenceEqual | .NET 8.0             | .NET 8.0             | 1048576        |          20,974.963 ns |    0.002 |     0.00 |         - |
| SequenceEqual | .NET 9.0             | .NET 9.0             | 1048576        |          20,615.505 ns |    0.002 |     0.00 |         - |
| SequenceEqual | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1048576        |       9,744,674.688 ns |    1.000 |     0.01 |         - |
|               |                      |                      |                |                        |          |          |           |
| Span          | .NET 8.0             | .NET 8.0             | 1048576        |          20,955.331 ns |     0.99 |     0.02 |         - |
| Span          | .NET 9.0             | .NET 9.0             | 1048576        |          20,598.672 ns |     0.97 |     0.01 |         - |
| Span          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1048576        |          21,176.643 ns |     1.00 |     0.02 |         - |
|               |                      |                      |                |                        |          |          |           |
| **MemCmp**    | **.NET 8.0**         | **.NET 8.0**         | **1073741824** | **111,762,734.375 ns** | **1.04** | **0.03** |  **80 B** |
| MemCmp        | .NET 9.0             | .NET 9.0             | 1073741824     |     110,374,794.400 ns |     1.03 |     0.03 |      80 B |
| MemCmp        | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1073741824     |     107,072,063.077 ns |     1.00 |     0.01 |         - |
|               |                      |                      |                |                        |          |          |           |
| Loop          | .NET 8.0             | .NET 8.0             | 1073741824     |     280,450,679.167 ns |     0.69 |     0.02 |     200 B |
| Loop          | .NET 9.0             | .NET 9.0             | 1073741824     |     523,091,792.857 ns |     1.29 |     0.02 |     400 B |
| Loop          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1073741824     |     404,927,735.714 ns |     1.00 |     0.01 |         - |
|               |                      |                      |                |                        |          |          |           |
| SequenceEqual | .NET 8.0             | .NET 8.0             | 1073741824     |      95,954,794.298 ns |    0.010 |     0.00 |      67 B |
| SequenceEqual | .NET 9.0             | .NET 9.0             | 1073741824     |      94,486,122.500 ns |    0.010 |     0.00 |      80 B |
| SequenceEqual | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1073741824     |   9,944,911,760.000 ns |    1.000 |     0.00 |         - |
|               |                      |                      |                |                        |          |          |           |
| Span          | .NET 8.0             | .NET 8.0             | 1073741824     |      92,945,091.026 ns |     0.97 |     0.01 |      67 B |
| Span          | .NET 9.0             | .NET 9.0             | 1073741824     |      94,375,230.882 ns |     0.99 |     0.03 |      67 B |
| Span          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1073741824     |      95,817,247.619 ns |     1.00 |     0.02 |         - |


The first notable result is that for very small arrays, the overhead of calling `memcmp`  is a waste compared to a naive loop. In .NET Framework, the loop is overall fastest for 10 element arrays. This is not unexpected, but it's important to note; don't try to optimise if you actually have small arrays. The loop does not scale well at all however, and that advantage has completely disappeared by just 1000 elements.

The more biggest difference is between .NET framework and .NET 8. Even the loop is notably faster in .NET 8. There is a bizarre performance regression from .NET 8 to .NET 9 for 1GB arrays, which I will investigate separately to try to confirm that result, it may have been a glitch in the benchmark, given twice the memory allocations and twice the time taken.

When we look at `IEnumerable<T>.SequenceEqual`, it is **500 times faster for our 1MB array in .NET 8 than in .NET framework**. In .NET8 and .NET9, `IEnumerable<T>.SequenceEqual` is faster than the version of memcmp I have on my machine.

There wasn't a significant difference between `ReadOnlySpan<T>.SequenceEqual` and `IEnumerable<T>.SequenceEqual`, with the difference around the margin of error.

`memcmp` is still a little slower than `SequenceEqual` across the board. It's still very fast, much faster than naive methods, but it's clearly no longer necessary for achieving high performance for array comparisons. When the original stackoverflow answer was written, there was nothing available in .NET that could come close to that performance, as it was before `Span<T>` was added to the runtime.

A benefit of the `ReadOnlySpan<T>` implementation over using `IEnumerable<T>.SequenceEqual` is that we can also trust that it still perform acceptably when we target .NET Framework.

## Conclusion

If you're using .NET 8 and don't need to run in the .NET Framework runtime, don't write your own utility function and just use `IEnumerable<T>.SequenceEqual`, it's incredibly fast and doesn't need any external dependencies to just work.

If you're on .NET Framework, then bring in `System.Memory` and use `Span<T>.SequenceEquals` instead of relying on external C libraries. Make sure any calls to `IEnumerable<T>.SequenceEquals` are checked to make sure they aren't operating on large arrays.


## Other considerations

If you regularly need to compare very large arrays and they are append-only and/or are compared more often than constructed, then it may make sense to avoid the comparison entirely by using a data structure that includes and maintains an order-sensitive hash of its contents. Most negative cases can be discounted through a hash comparison before doing the more expensive array comparison. Rebuilding this hash could be expensive for arrays that shuffle or remove items however.

## Source Code

The source code to generate these results is available at https://github.com/richardcocks/memcomparison/ .

Pull requests always welcome.

