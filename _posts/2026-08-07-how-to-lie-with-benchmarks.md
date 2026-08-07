---
layout: post
title: "How to lie with benchmarks"
date: 2026-08-07
description: A look at bad benchmarking
tagline: Microbenchmarks aren't always what they seem
image: https://blog.eterm.uk/assets/img/fibbench.png
---
# How to lie with benchmarks

## Naive double-recursion

A recent hacker news post[^1] alerted me to the idea of testing the speed of function calls in different languages by implementing naive recursive fibonacci.

You know, the kind you get by implementing:

```
int fib(int n) {
    if (n < 2) return n;
    return fib(n - 1) + fib(n - 2);
}
```

This is the sort of algorithm you might implement on day one of a programming course, with no regards to optimisation.

In fact, it's so unoptimised, we can calculate how many function calls are required. I'll leave the maths for another day, but it's a fibonacci sequence too, and ends up at `2·fib(n+1) − 1`. 

For fib(32) which we'll be benchmarking with, that's 7,049,155 function calls.

This is of course a slow algorithm, but now we have a slow algorithm, we can run our naive algorithm in different languages, to give ourselves a list of _top performing languages_.

![Results of recursive fibonacci](/assets/img/fibbench.png "Recursive Fibonacci runtime (lower is better)")


<details markdown="1">

<summary> fib(32), best of 15 timed runs after 15 warm-up runs (click to expand results table) </summary>

| | Runtime | best | mean |
|---|---|---:|---:|
| **AOT** | C / gcc 12.2 `-O2` | **3.58 ms** | 3.67 ms |
| | Rust 1.97.1 `-O` | 6.64 ms | 6.96 ms |
| | C / clang 14.0 `-O2` | 6.84 ms | 6.92 ms |
| | Java 25 (GraalVM native-image) | 9.53 ms | 9.83 ms |
| | Go 1.26.5 | 10.42 ms | 10.59 ms |
| | C# / .NET NativeAOT | 10.62 ms | 10.69 ms |
| **JIT** | F# / .NET 10 | 7.11 ms | 7.22 ms |
| | C# / .NET 10 | 7.15 ms | 7.40 ms |
| | Java 25 (HotSpot C2) | 11.32 ms | 11.78 ms |
| | Julia 1.12.6 | 11.42 ms | 12.03 ms |
| | Node 26.5.1 / V8 14.6 | 22.13 ms | 23.37 ms |
| | LuaJIT 2.1 | 25.95 ms | 26.24 ms |
| | PyPy 3.9.16 | 26.68 ms | 31.81 ms |
| **Interpreted** | LuaJIT `-joff` | 100.62 ms | 101.49 ms |
| | Lua 5.4 | 156.66 ms | 160.97 ms |
| | Lua 5.1 | 239.58 ms | 244.23 ms |
| | CPython 3.11 | 294.85 ms | 303.02 ms |

</details>

These results have a few surprises: 

 - Gcc beating Clang by some distance. 
 - C# / .NET JIT beating Ahead of Time (AOT) compilation. 
 - Java beating Go.

The devil is of course in the details, to understand what these benchmarks tell us we have to understand what we're comparing.

We deliberately implemented a naive algorithm, with double-recursion and one unsuitable for tail call optimisation, but the compilers have no reason to respect that.

Clang for instance, compiles our algorithm down to a single recursive function:

```c
int fib(int n) {
    int acc = 0;
    while (n >= 2) {
        acc += fib(n - 1);   // the only real recursive call left
        n -= 2;
    }
    return acc + n;          // n has decayed to 1 or 0, i.e. fib(1) or fib(0)
}
```

Now gcc goes further than clang by inlining and nesting function calls, so that instead of a single recursion each n, it only has to recurse in batches of 8:

```
function fib(n)
    if n < 2 then return n

    acc0 ← 0
    while n > 2 do
        n1 ← n − 1
        acc1 ← 0
        while n1 > 2 do
            n2 ← n1 − 1
            acc2 ← 0
            while n2 > 2 do
                n3 ← n2 − 1
                acc3 ← 0
                while n3 > 2 do
                    n4 ← n3 − 1
                    acc4 ← 0
                    while n4 > 2 do
                        n5 ← n4 − 1
                        acc5 ← 0
                        while n5 > 2 do
                            n6 ← n5 − 1
                            acc6 ← 0
                            while n6 > 2 do
                                n7 ← n6 − 1
                                acc7 ← 0
                                while n7 > 2 do
                                    n8 ← n7 − 1
                                    acc8 ← 0
                                    while n8 > 1 do
                                        acc8 ← acc8 + fib(n8 − 1)
                                        n8 ← n8 − 2
                                    acc7 ← acc7 + acc8 + n8
                                    n7 ← n7 − 2
                                acc6 ← acc6 + acc7 + 1
                                n6 ← n6 − 2
                            acc5 ← acc5 + acc6 + 1
                            n5 ← n5 − 2
                        acc4 ← acc4 + acc5 + 1
                        n4 ← n4 − 2
                    acc3 ← acc3 + acc4 + 1
                    n3 ← n3 − 2
                acc2 ← acc2 + acc3 + 1
                n2 ← n2 − 2
            acc1 ← acc1 + acc2 + 1
            n1 ← n1 − 2
        acc0 ← acc0 + acc1 + 1
        n ← n − 2
    return acc0 + 1
```

This still explodes into a tree of recursion, but it takes us down from over 7M function calls to ~300k.

If we hand this implementation over to C# and LuaJIT, then we see a speed-up there too:

```
C# naive recursive         mean  7.23 ms ± 0.19 ms
C# gcc-shaped              mean  2.70 ms ± 0.10 ms
LuaJIT gcc-shaped          mean  3.39 ms ± 0.25 ms
```

In fact the "gcc-shaped" code ends up *faster than gcc*. This doesn't mean much, as we'll see later.

## Iteration

We're not done. Let's not use recursion to do something we can do in a single loop.

```
function fib(n) {
    if (n == 0) return 0;
     a = 0, b = 1;
    while (--n) {  t = a + b; a = b; b = t; }
    return b;
}
```

There's another algorithm that's even quicker, because you can jump your index by a factor of two each time, using the identities:

```
fib(2k)   = fib(k) · (2·fib(k+1) − fib(k))
fib(2k+1) = fib(k)² + fib(k+1)²
```

This takes us from microbenchmarking to nanobenchmarking, so to get accurate measurements we have to use a real benchmarking harness such as Criterion or BenchmarkDotNet.

Calculated iteratively, we find:

| implementation | time |
|---|---:|
| iterative loop — C, clang 14 | 4.30 ns |
| fast doubling — C# / .NET 10 | 5.49 ns |
| fast doubling — C, gcc 12.2 | 6.39 ns |
| fast doubling — C, clang 14 | 8.17 ns |
| iterative loop — C, gcc 12.2 | 9.58 ns |
| iterative loop — C# / .NET 10 | 13.37 ns |
| *naive recursive — C, gcc ( best case, from the previous table )* | *3,580,000 ns* |

So we find ourselves almost a million times quicker. The interesting thing here is that this time Clang optimises the iterative loop better than gcc does, but that it even optimises the iterative loop to be faster than the "fast doubling" approach, this time due to loop unrolling by clang:

The tight loop becomes:

```asm
add %esi,%edx      ; b += a    →  (a,b) advance one step
add %edx,%esi      ; a += b    →  another step
add %esi,%edx
add %edx,%esi
add %esi,%edx
add %edx,%esi
add %esi,%edx
add %edx,%esi
add $0xfffffff8,%edi   ; n -= 8
jne 30
```

We're now at the kind of micro-optimisation that wastes anyone's time, we're already within an order of magnitude of a look-up table of the results. The complete range of fibonacci numbers whose results fit into a 64-bit number can be stored in less space than most of the code to run an algorithm.

But let's take a step back and examine what happens if we go back to a recursive algorithm, but having learned about Tail Call Optimisation.

## Tail Call Optimisation ( TCO )

Early on in a functional language course, you'll learn that some recursive approaches lend themselves to being optimised. This can happen more easily when the recursion is a "tail call", i.e. the last thing to happen semantically.

It's easiest to achieve this by introducing an accumulator into the recursive function.

```
function fib(n)
    return fib_acc(n, 0, 1)

function fib_acc(n, a, b)
    if n = 0 then
        return a
    return fib_acc(n − 1, b, a + b)
```

Before we talk about Tail call optimisation (TCO), I should note that this version has a much bigger performance difference by way of the algorithm itself. It has a single recursion, so fib(n) will make roughly n recursive calls, i.e.

```
fib(6) = fib_acc(6, 0, 1)
fib_acc(6, 0, 1) = fib_acc(5, 1, 1)
fib_acc(5, 1, 1) = fib_acc(4, 1, 2)
fib_acc(4, 1, 2) = fib_acc(3, 2, 3)
fib_acc(3, 2, 3) = fib_acc(2, 3, 5)
fib_acc(2, 3, 5) = fib_acc(1, 5, 8)
fib_acc(1, 5, 8) = fib_acc(0, 8, 13)
fib_acc(0, 8, 13) = 8
```

### Side quests

You might notice that we inadvertently calculate fib(n+1) as an argument we never use here, however, chasing this micro-optimisation can lead you down a blind alley. You could re-write the algorithm as:

```
function fib(n)
    if n < 2 then 
        return n;
    return fib_acc(n, 0, 1)

function fib_acc(n, a, b)
    if n = 1 then
        return b
    return fib_acc(n − 1, b, a + b)
```
This is now into the territory firmly of, "you won't notice this", for the cost of a comparison at the start, we save one recursion later. However, we're also now comparing to 1, not 0.

And that has consequences too, when comparing to zero we can just check the zero flag without executing `cmp`, but when comparing to one, we actually have to execute the `cmp` instruction.

But at this point, we aren't even talking about a single CPU cycle, superscalar execution means that going from 6 instructions to 5 instructions doesn't save us even one whole clock cycle, and CPUs have special optimisations for CMP+JNZ. Counting instructions doesn't always paint an accurate picture any more.

We can safely ignore this kind of optimisation, it's the kind of false optimisation that is more academic than actual, so let's get back to talking about how compilers actually handle our new functional recursive approach.

### Returning to our optimised recursive algorithm 

Tail call optimisation comes from realising we don't need to add tail calls to the stack. Instead of writing our stack frame to the stack and entering fib_acc again, we can replace our current stack frame with the new call, essentially erasing our intermediate function call.

This is important not just for performance, but specifically it avoids us overflowing the stack. A stack overflow happens when you run out of stack space after tens or hundreds of thousands of recursive calls.

Some languages purposefully do not do Tail Call Optimisation, other languages guarantee it, while others leave it up to the compiler. To see which languages do which, we can call our function with an absurdly large 5_000_000.


| runtime | fib_acc(32) | 5,000,000 deep ( TCO detection attempt ) |
|---|---:|---|
| C / clang | 4.4 ns | ✅ |
| Rust | 4.6 ns | ✅ |
| C# / .NET 10 | 11.3 ns | It's complicated |
| F# / .NET 10 | 12.4 ns | ✅ |
| C / gcc | 12.3 ns | ✅ |
| Go | 23.3 ns | It's also complicated |
| LuaJIT | 27.1 ns | ✅ |
| Java 25 | 28.8 ns | ❌ StackOverflowError |
| Julia | 42.5 ns | ❌ StackOverflowError |
| Node / V8 | 130.9 ns | ❌ RangeError |
| PyPy | 175.8 ns | ❌ RecursionError |
| Lua 5.4 | 612.7 ns | ✅ |
| Lua 5.1 | 1057.8 ns | ✅ |
| CPython | 1686.5 ns | ❌ RecursionError |

And now we see C is back to the same performance as our hand written iterative loop, and there's a good reason for that: the compiler turns it back into a loop.

Having attempted to calculate fib(5M), we can see here the languages that do TCO and those that don't.

Java, Julia, V8, PyPy and CPython fail to transform the tail call into iteration.

C# is a more complex case, because if you warm up the JIT first, it will tail call, but a cold run means it executes without optimisation and it hits a stack overflow. If you compile with AOT compilation then it eliminates the tail call and doesn't overflow.

F# as a functional language, guarantees tail-call optimisation, and so doesn't suffer from a cold start crash.

Go is also an odd one, since Go doesn't do tail-call optimisation, but it also doesn't hit a stackoverflow here, but that is because Go will dynamically increase the stack allocation to accommodate, compared to the fixed stack sizes that are able to overflow.

Also consider that even without the tail call optimisation, this method is still at least 100,000 times faster than the original double-recursion. The speed-up comes from a single level of recursion, approximately 30 calls in the case of fib(32), rather than the tail-call optimisation itself.

Looking at this list, you might be wondering why Go ends up slower, and that's because of two factors:

1. It doesn't unroll the loop
2. It has to bounds-check the stack and resize it

Ultimately, Clang and Rust benefit from the compiler effectively turning the algorithm back into our iteration, and then unrolling that loop to get us back to ~4.5ns.

GCC and the CLR languages don't unroll the loop, the CLR RyuJIT gets us to ~11ns going to tier 1 and that's good enough for it.

## It's always the algorithm

With a small change in algorithm CPython went down from over 300ms, a meaningful wait, to 1,686ns, approximately ~170,000 times faster.

Even the fastest attempt at the double-recursive algorithm, gcc-optimised and passed back to C# for RyuJIT's best attempt at execution, only got us down to 2,696,000 ns.

gcc's approach with RyuJIT or LuaJIT executing are both comfortably beaten by CPython making 30 recursive function calls.

## You just can't compare languages this way

If you believed the headline image, you'd be swearing that the LLVM folks are heretics, that gcc is best and has the fastest function calls.

And in a way, you'd be right, because it found a way to eliminate most of the function calls from an algorithm that was written to deliberately call a lot of functions in a hard to optimise way.

It wasn't however actually proving it can call functions faster, it had just found a trick to eliminate a lot of them entirely.

## What good is benchmarking then

Benchmarking is useful when you have a known problem and want to compare approaches to solving the same problem in the same environment. It's fair to compare the 3,580,000ns double-recursive approach with the 4ns single recursion.

Taking a bad approach and running it in different environments to compare the environments however is a much less worthwhile endeavour, unless you take the time to look into the detail of the differences. You can leverage those differences to sell whatever picture you like.

Through the various charts today I could sell the benefits of JITting ( C# JIT outperformed AoT on the naive benchmark ). I could sell the benefits of AOT ( C# can stack-overflow in cases where AOT wouldn't! ). 

I could sell gcc as being "better than Clang!" or sell Clang as "better than gcc!", because each out-performed each other in different circumstances.

If you add more factors, such as compiled binary size, compilation time, you can paint almost any picture you like.

[^1]: [Cyberscript](https://news.ycombinator.com/item?id=34553236)