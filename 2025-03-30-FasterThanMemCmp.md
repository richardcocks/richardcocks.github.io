---
layout: post
title: What's faster than Memcmp
date: 2025-03-30
description: What could be faster than memcmp? How to quickly compare arrays using Span<T>
tagline: What could be faster than memcmp? Benefits of Span<T>
image: https://richardcocks.github.io/assets/img/7aStackAlloc0.png
---

# 2025-03-30 What's faster than Memcmp?

In this post I look at improvements in .NET and using Span<T> for performance and portability.

I was examining portability issues in a code base that I wanted to migrate from .NET framework 4.8.1 to .NET8. I discovered use of `msvcrt.dll`. I quickly established it is a [popular stackoverflow answer](https://stackoverflow.com/a/1445405/1635976) for a fast way to compare byte arrays in .NET

The answer as provided (and faithfully copied into codebases is this):

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

| Method        | Job                  | Runtime              | Length     | Mean                 | Error              | StdDev             | Median               | Ratio | RatioSD | Gen0   | Allocated | Alloc Ratio |
|-------------- |--------------------- |--------------------- |----------- |---------------------:|-------------------:|-------------------:|---------------------:|------:|--------:|-------:|----------:|------------:|
| **MemCmp**        | **.NET 8.0**             | **.NET 8.0**             | **10**         |             **7.957 ns** |          **0.0683 ns** |          **0.0570 ns** |             **7.936 ns** |  **0.65** |    **0.01** |      **-** |         **-** |          **NA** |
| MemCmp        | .NET 9.0             | .NET 9.0             | 10         |             7.877 ns |          0.0967 ns |          0.0905 ns |             7.860 ns |  0.64 |    0.01 |      - |         - |          NA |
| MemCmp        | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 10         |            12.239 ns |          0.2138 ns |          0.1785 ns |            12.251 ns |  1.00 |    0.02 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| Loop          | .NET 8.0             | .NET 8.0             | 10         |             4.390 ns |          0.1014 ns |          0.0949 ns |             4.381 ns |  0.88 |    0.03 |      - |         - |          NA |
| Loop          | .NET 9.0             | .NET 9.0             | 10         |             6.439 ns |          0.1557 ns |          0.1853 ns |             6.461 ns |  1.29 |    0.05 |      - |         - |          NA |
| Loop          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 10         |             4.995 ns |          0.1172 ns |          0.1097 ns |             4.983 ns |  1.00 |    0.03 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| SequenceEqual | .NET 8.0             | .NET 8.0             | 10         |            21.341 ns |          0.4364 ns |          0.4850 ns |            21.211 ns |  0.15 |    0.00 |      - |         - |        0.00 |
| SequenceEqual | .NET 9.0             | .NET 9.0             | 10         |             7.611 ns |          0.1522 ns |          0.1349 ns |             7.575 ns |  0.05 |    0.00 |      - |         - |        0.00 |
| SequenceEqual | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 10         |           139.476 ns |          1.8444 ns |          1.7253 ns |           139.578 ns |  1.00 |    0.02 | 0.0100 |      64 B |        1.00 |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| Span          | .NET 8.0             | .NET 8.0             | 10         |             2.394 ns |          0.0472 ns |          0.0442 ns |             2.383 ns |  0.21 |    0.00 |      - |         - |          NA |
| Span          | .NET 9.0             | .NET 9.0             | 10         |             1.624 ns |          0.0319 ns |          0.0298 ns |             1.613 ns |  0.14 |    0.00 |      - |         - |          NA |
| Span          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 10         |            11.523 ns |          0.1308 ns |          0.1160 ns |            11.465 ns |  1.00 |    0.01 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| **MemCmp**        | **.NET 8.0**             | **.NET 8.0**             | **1024**       |            **36.745 ns** |          **0.2865 ns** |          **0.2540 ns** |            **36.691 ns** |  **0.89** |    **0.01** |      **-** |         **-** |          **NA** |
| MemCmp        | .NET 9.0             | .NET 9.0             | 1024       |            36.317 ns |          0.5662 ns |          0.5296 ns |            36.320 ns |  0.88 |    0.01 |      - |         - |          NA |
| MemCmp        | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1024       |            41.452 ns |          0.4057 ns |          0.3795 ns |            41.454 ns |  1.00 |    0.01 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| Loop          | .NET 8.0             | .NET 8.0             | 1024       |           247.326 ns |          4.1387 ns |          3.6688 ns |           245.622 ns |  0.66 |    0.01 |      - |         - |          NA |
| Loop          | .NET 9.0             | .NET 9.0             | 1024       |           246.738 ns |          3.6330 ns |          3.3983 ns |           245.835 ns |  0.66 |    0.01 |      - |         - |          NA |
| Loop          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1024       |           372.410 ns |          4.3253 ns |          4.0459 ns |           372.201 ns |  1.00 |    0.01 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| SequenceEqual | .NET 8.0             | .NET 8.0             | 1024       |            32.069 ns |          0.4411 ns |          0.4126 ns |            31.929 ns | 0.003 |    0.00 |      - |         - |        0.00 |
| SequenceEqual | .NET 9.0             | .NET 9.0             | 1024       |            21.439 ns |          0.2053 ns |          0.1920 ns |            21.355 ns | 0.002 |    0.00 |      - |         - |        0.00 |
| SequenceEqual | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1024       |         9,542.293 ns |        142.9646 ns |        133.7292 ns |         9,490.887 ns | 1.000 |    0.02 |      - |      64 B |        1.00 |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| Span          | .NET 8.0             | .NET 8.0             | 1024       |            12.408 ns |          0.1506 ns |          0.1409 ns |            12.363 ns |  0.51 |    0.01 |      - |         - |          NA |
| Span          | .NET 9.0             | .NET 9.0             | 1024       |            12.310 ns |          0.1266 ns |          0.1184 ns |            12.261 ns |  0.51 |    0.01 |      - |         - |          NA |
| Span          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1024       |            24.117 ns |          0.2111 ns |          0.1871 ns |            24.040 ns |  1.00 |    0.01 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| **MemCmp**        | **.NET 8.0**             | **.NET 8.0**             | **1048576**    |        **31,477.776 ns** |        **333.5957 ns** |        **312.0456 ns** |        **31,454.590 ns** |  **0.99** |    **0.02** |      **-** |         **-** |          **NA** |
| MemCmp        | .NET 9.0             | .NET 9.0             | 1048576    |        31,790.009 ns |        359.5187 ns |        336.2941 ns |        31,832.147 ns |  1.00 |    0.02 |      - |         - |          NA |
| MemCmp        | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1048576    |        31,693.469 ns |        444.1933 ns |        456.1538 ns |        31,609.790 ns |  1.00 |    0.02 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| Loop          | .NET 8.0             | .NET 8.0             | 1048576    |       247,350.116 ns |      3,668.4314 ns |      3,431.4530 ns |       246,041.577 ns |  0.65 |    0.01 |      - |         - |          NA |
| Loop          | .NET 9.0             | .NET 9.0             | 1048576    |       251,317.223 ns |      4,773.3177 ns |      5,305.5300 ns |       249,779.736 ns |  0.66 |    0.02 |      - |         - |          NA |
| Loop          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1048576    |       379,628.993 ns |      6,524.7114 ns |      5,783.9867 ns |       377,086.450 ns |  1.00 |    0.02 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| SequenceEqual | .NET 8.0             | .NET 8.0             | 1048576    |        20,974.963 ns |        155.0344 ns |        145.0193 ns |        20,969.058 ns | 0.002 |    0.00 |      - |         - |          NA |
| SequenceEqual | .NET 9.0             | .NET 9.0             | 1048576    |        20,615.505 ns |        198.4879 ns |        185.6657 ns |        20,556.505 ns | 0.002 |    0.00 |      - |         - |          NA |
| SequenceEqual | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1048576    |     9,744,674.688 ns |    100,384.5408 ns |     93,899.7618 ns |     9,732,532.812 ns | 1.000 |    0.01 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| Span          | .NET 8.0             | .NET 8.0             | 1048576    |        20,955.331 ns |        178.9836 ns |        167.4214 ns |        20,950.296 ns |  0.99 |    0.02 |      - |         - |          NA |
| Span          | .NET 9.0             | .NET 9.0             | 1048576    |        20,598.672 ns |        157.6620 ns |        147.4771 ns |        20,634.763 ns |  0.97 |    0.01 |      - |         - |          NA |
| Span          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1048576    |        21,176.643 ns |        314.5719 ns |        294.2507 ns |        21,022.195 ns |  1.00 |    0.02 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| **MemCmp**        | **.NET 8.0**             | **.NET 8.0**             | **1073741824** |   **111,762,734.375 ns** |  **2,164,917.0335 ns** |  **3,370,515.2752 ns** |   **110,668,500.000 ns** |  **1.04** |    **0.03** |      **-** |      **80 B** |          **NA** |
| MemCmp        | .NET 9.0             | .NET 9.0             | 1073741824 |   110,374,794.400 ns |  2,118,822.7575 ns |  2,828,567.7621 ns |   108,890,400.000 ns |  1.03 |    0.03 |      - |      80 B |          NA |
| MemCmp        | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1073741824 |   107,072,063.077 ns |    542,714.4187 ns |    453,191.1193 ns |   106,895,980.000 ns |  1.00 |    0.01 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| Loop          | .NET 8.0             | .NET 8.0             | 1073741824 |   280,450,679.167 ns |  5,539,011.5023 ns |  7,202,280.1454 ns |   278,676,200.000 ns |  0.69 |    0.02 |      - |     200 B |          NA |
| Loop          | .NET 9.0             | .NET 9.0             | 1073741824 |   523,091,792.857 ns |  4,991,594.9341 ns |  4,424,918.8946 ns |   522,044,250.000 ns |  1.29 |    0.02 |      - |     400 B |          NA |
| Loop          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1073741824 |   404,927,735.714 ns |  3,976,508.9789 ns |  3,525,071.6350 ns |   404,123,550.000 ns |  1.00 |    0.01 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| SequenceEqual | .NET 8.0             | .NET 8.0             | 1073741824 |    95,954,794.298 ns |  1,881,322.8760 ns |  3,245,189.7835 ns |    94,970,508.333 ns | 0.010 |    0.00 |      - |      67 B |          NA |
| SequenceEqual | .NET 9.0             | .NET 9.0             | 1073741824 |    94,486,122.500 ns |  1,875,529.6108 ns |  2,919,973.8857 ns |    92,713,450.000 ns | 0.010 |    0.00 |      - |      80 B |          NA |
| SequenceEqual | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1073741824 | 9,944,911,760.000 ns | 20,546,629.5765 ns | 19,219,330.0627 ns | 9,950,594,800.000 ns | 1.000 |    0.00 |      - |         - |          NA |
|               |                      |                      |            |                      |                    |                    |                      |       |         |        |           |             |
| Span          | .NET 8.0             | .NET 8.0             | 1073741824 |    92,945,091.026 ns |    759,542.2591 ns |    634,252.1863 ns |    92,581,400.000 ns |  0.97 |    0.01 |      - |      67 B |          NA |
| Span          | .NET 9.0             | .NET 9.0             | 1073741824 |    94,375,230.882 ns |  1,873,848.4555 ns |  3,025,916.2123 ns |    92,613,433.333 ns |  0.99 |    0.03 |      - |      67 B |          NA |
| Span          | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 1073741824 |    95,817,247.619 ns |  1,477,533.4494 ns |  1,309,794.9180 ns |    95,270,383.333 ns |  1.00 |    0.02 |      - |         - |          NA |


The first notable result is that for very small arrays, the overhead of calling `memcmp`  is a waste compared to a naive loop. In .NET Framework, the loop is overall fastest for 10 element arrays. This is not unexpected, but it's important to note; don't try to optimise if you actually have small arrays. The loop does not scale well at all however, and that advantage has completely disappeared by just 1000 elements.

The more biggest difference is between .NET framework and .NET 8. Even the loop is notably faster in .NET 8. There is a bizarre performance regression from .NET 8 to .NET 9 for 1GB arrays, which I will investigate separately to try to confirm that result, it may have been a glitch in the benchmark, given twice the memory allocations and twice the time taken.

When we look at `IEnumerable<T>.SequenceEqual`, it is 500 times faster for our 1MB array in .NET 8 than in .NET framework. In .NET8 and .NET9, `IEnumerable<T>.SequenceEqual` is faster than the version of memcmp I have on my machine.

There wasn't a significant difference between `ReadOnlySpan<T>.SequenceEqual` and `IEnumerable<T>.SequenceEqual`, with the difference around the margin of error.

memcmp is still a little slower across the board, it's still very fast but it's no longer necessary for highly performant array comparisons. When the original stackoverflow answer was written, nothing in .NET could come close to that performance, since `Span<T>` wasn't yet a thing, and for 1MB arrays, 

A benefit of the `ReadOnlySpan<T>` implementation over `IEnumerable<T>.SequenceEqual` is that we can also trust that it still perform acceptably when we target .NET Framework.

## Conclusion

If you're using .NET 8 and don't need to run in the .NET Framework runtime, don't write your own utility function and just use `IEnumerable<T>.SequenceEqual`, it's incredibly fast and doesn't need any external dependencies to just work.

If you're on .NET Framework, then bring in `System.Memory` and using `Span<T>.SequenceEquals` instead of relying on P/Invoke and external C libraries. Make sure any calls to `IEnumerable<T>.SequenceEquals` to checked to make sure they aren't operating on large arrays.


## Other considerations

If you regularly need to compare very large arrays and they are append-only and/or are compared more often than constructed, then it may make sense to avoid the comparison entirely by using a data structure that includes and maintains an order-sensitive hash of its contents. Most negative cases can be discounted through a hash comparison before doing the more expensive array comparison. Rebuilding this hash could be expensive for arrays that shuffle or remove items however.



