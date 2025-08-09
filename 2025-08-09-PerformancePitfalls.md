---
layout: post
title: Performance Pitfalls in C# / .NET
date: 2025-08-09
description: Looking at the performance of a C# helper method for Contains
tagline: A IsInList helper method could hurt performance
image: https://richardcocks.github.io/assets/img/1benchmark.png
---
# Performance Pitfalls in C# / .NET

A day ago, reddit user zigs asked on the csharp subreddit:

> [What is the lowest effort, highest impact helper method you've ever written?](https://np.reddit.com/r/csharp/comments/1mkrlcc/what_is_the_lowest_effort_highest_impact_helper/)


This proved a popular post, and one of the [more popular answers from user \_mattmc3\_](https://np.reddit.com/r/csharp/comments/1mkrlcc/what_is_the_lowest_effort_highest_impact_helper/n7kuuii/) was:

> I've written a lot of SQL in my years as a developer, so foo IN(1, 2, 3) is a more intuitive way to express the concept to me than foo == 1 || foo == 2 || foo == 3 or even new int[] {1,2,3}.Contains(foo). Having foo being first just makes more sense, so I have a handy IsIn() extension method so I can write foo.IsIn(1, 2, 3):

``` csharp
    public static bool IsIn<T>(this T obj, params T[] values) {
        foreach (T val in values) {
            if (val.Equals(obj)) return true;
        }
        return false;
    }

    public static bool IsIn<T>(this T obj, IComparer comparer, params T[] values) {
        foreach (T val in values) {
            if (comparer.Compare(obj, val) == 0) return true;
        }
        return false;
    }
```

There was some discussion about this, pointing out that newer versions of C# supports `params ReadOnlySpan<T>` to avoid allocations.

I decided to benchmark a simple scenario where you might use this.

## Benchmark

Let's say we have a list of 10,000 numbers which randomly range from 0 to 63 inclusive. We want to count how many of these are 1, 3 or 7.  That sounds abstract, but it's a fairly common real-world pattern. Although in the real world, this might actually be counting a list of fruits for bananas, strawberries and mangoes. In general this scenario comes up when you have a set of items whose properties are generally known at compile time, but whose domain is open to future expansion so it doesn't fit into a flags enum.

Our setup is therefore straightforward, we create the list of numbers.

```csharp
    [GlobalSetup]
    public void Setup()
    {
        for (int i = 0; i < 10_000; i++)
        {
            keys[i] = Random.Shared.Next(0, 63);
        }
    }
```

As our baseline, we'll compare approaches to perhaps the most natural thing to do: create a list and use `Contains`:

```csharp
    [Benchmark(Baseline = true)]
    public int Contains()
    {
        return keys.Count(key => new int[] { 1, 3, 7 }.Contains(key));
    }
```

We want to compare this to the helper method suggested, as well as the suggested `ReadOnlySpan` version:

```csharp
    [Benchmark]
    public int IsIn()
    {
        return keys.Count(key => key.IsIn(1, 3, 7));
    }

    [Benchmark]
    public int IsInReadOnly()
    {
        return keys.Count(key => key.IsInReadOnly(1, 3, 7));
    }
```

We should also compare it to the simplest approach, `if` or `switch case`:

```csharp
    [Benchmark]
    public int WithIf()
    {
        return keys.Count(key => key == 1 || key == 3 || key == 7);
    }

    [Benchmark]
    public int WithSwitch()
    {
        return keys.Count(key =>
        {
            switch (key)
            {
                case 1:
                case 3:
                case 7:
                    return true;
            }
            return false;
        });
    }
```

## Results

| Method       | Job        | Runtime    | Mean       | Error     | StdDev     | Median     | Ratio | RatioSD | Gen0     | Allocated | Alloc Ratio |
|------------- |----------- |----------- |-----------:|----------:|-----------:|-----------:|------:|--------:|---------:|----------:|------------:|
| IsIn         | .NET 8.0   | .NET 8.0   | 192.533 us | 3.8374 us |  6.8209 us | 193.961 us |  1.87 |    0.08 | 132.3242 | 1107792 B |       2.769 |
| IsIn         | .NET 10.0  | .NET 10.0  | 126.626 us | 2.5270 us |  4.4259 us | 126.874 us |  1.23 |    0.05 | 132.5684 | 1109488 B |       2.773 |
| IsInReadOnly | .NET 8.0   | .NET 8.0   | 146.813 us | 7.2935 us | 21.5051 us | 158.514 us |  1.43 |    0.21 |  84.7168 |  708872 B |       1.772 |
| IsInReadOnly | .NET 10.0  | .NET 10.0  | 105.307 us | 5.0441 us | 14.8725 us | 100.645 us |  1.02 |    0.15 |  84.7168 |  708696 B |       1.772 |
| Contains     | .NET 8.0   | .NET 8.0   | 103.059 us | 2.0413 us |  2.8616 us | 101.683 us |  1.00 |    0.04 |  47.7295 |  400032 B |       1.000 |
| Contains     | .NET 10.0  | .NET 10.0  |  73.218 us | 1.4635 us |  1.6267 us |  72.464 us |  0.71 |    0.02 |  47.7295 |  400000 B |       1.000 |
| WithIf       | .NET 8.0   | .NET 8.0   |  23.081 us | 0.1456 us |  0.1362 us |  23.095 us |  0.22 |    0.01 |        - |      32 B |       0.000 |
| WithIf       | .NET 10.0  | .NET 10.0  |   6.826 us | 0.0714 us |  0.0633 us |   6.792 us |  0.07 |    0.00 |        - |         - |       0.000 |
| WithSwitch   | .NET 8.0   | .NET 8.0   |  22.848 us | 0.4243 us |  0.3969 us |  22.757 us |  0.22 |    0.01 |        - |      32 B |       0.000 |
| WithSwitch   | .NET 10.0  | .NET 10.0  |   9.770 us | 0.1027 us |  0.0960 us |   9.756 us |  0.09 |    0.00 |        - |         - |       0.000 |

![Benchmark results graph](/assets/img/1benchmark.png "Lower is better")

## .NET Framework

I also ran a comparison on .NET Framework:

| Method       | Job                  | Runtime              | Mean       | Error     | StdDev     | Median     | Ratio | RatioSD | Gen0     | Allocated | Alloc Ratio |
|------------- |--------------------- |--------------------- |-----------:|----------:|-----------:|-----------:|------:|--------:|---------:|----------:|------------:|
| IsIn         | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 186.539 us | 1.9634 us |  1.5329 us | 186.937 us |  1.75 |    0.07 | 176.5137 | 1111075 B |       2.777 |
| IsInReadOnly | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 241.478 us | 4.1324 us |  3.6633 us | 242.215 us |  2.27 |    0.09 | 112.7930 |  709897 B |       1.775 |
| Contains     | .NET Framework 4.8.1 | .NET Framework 4.8.1 | 560.785 us | 9.9977 us |  9.3518 us | 565.321 us |  5.26 |    0.21 |  63.4766 |  401204 B |       1.003 |
| WithIf       | .NET Framework 4.8.1 | .NET Framework 4.8.1 |  59.772 us | 0.7011 us |  0.6558 us |  59.798 us |  0.56 |    0.02 |        - |      31 B |       0.000 |
| WithSwitch   | .NET Framework 4.8.1 | .NET Framework 4.8.1 |  64.200 us | 1.1971 us |  1.2294 us |  64.313 us |  0.60 |    0.03 |        - |      31 B |       0.000 |

Without native `ReadOnlySpan<T>` support, that version is much slower than `params T[]`, despite fewer allocations.

With the lack of LINQ optimisation in .NET Framework, `Contains` is by far the worst performing here.


## Conclusion

The biggest surprise for me here was actually the performance difference between .NET 8 and .NET 10 for the naive `if` statement method. A dramatic improvement between .NET 8 and .NET 10 for a simple set of `if` statements suggests JIT improvements have made a big difference.

The `ReadOnlySpan<T>` approach avoided some allocations, but it still allocated more than the `Contains` approach, which was still more than the `switch / case` version.

For such a popular and tempting helper method, this is a real performance trap. Overall the worst performing version was 28x slower than hard-coded `if` statements.

As with any micro-benchmark, it's important to stress that this is only important if profiling your real-world use case demonstrates it. 

Always profile your real-world application and let that guide any optimisation you do. I have seen this pattern impact performance in a real world application, so keep it in mind.

Always profile within the context of your application. Blindly removing the helper method and replacing with `Contains` would be a disaster if you were still on .NET Framework.

## Source Code

The source code to generate these results is available at https://github.com/richardcocks/IsInList .

Pull requests always welcome.
