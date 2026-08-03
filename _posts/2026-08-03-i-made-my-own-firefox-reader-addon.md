---
layout: post
title: "I made my own Firefox Readability Addon"
date: 2026-08-03
description: I'd rather write my own than trust a random
tagline: I built a Firefox Addon
image: https://blog.eterm.uk/assets/img/ff_addon.png
---
# I made my own Firefox Readability Addon

There are a plethora of existing readability addons, but they each prompt the scary warning:

> This addon requires: Access your data for all websites

And that's a scary thing to accept from an addon controlled by unknown users and groups, and which even in the most optimistic circumstances, could later be sold on to those less scrupulous.

I also wanted a reader that would only kick in when sites have particularly low readability, and wanted something that would nudge readability in-line, not force a set structure like the full "reader mode".

So "I" wrote my own, to my taste.

![Soft Reader settings widget](/assets/img/ff_addon.png "Soft Reader settings")

It runs a quick script to check the current contrast, line spacing and font size. Then if it fails those checks, only then it kicks in.

It's a bit janky on dynamic pages, but it gets the job done and I don't need to hand over the keys to my browser to a random unknown on the internet.

The [source is on GitHub](https://github.com/richardcocks/soft-reader) but I don't expect anyone to use it, I wouldn't want them to, because it doesn't solve the trust problem for anyone else.

This was one-shot with a single prompt:

> I'd like to build myself my own firefox addon, which implements as "soft reader" mode. Instead of completely restructuring the page like traditional reader-mode, it should just apply some basic minimum font sizes, minimum contrast and serif'd fonts

Our Friend The Machine did the rest, including features such as per-site enable/disable, line-height sliders, the works.

One prompt and 39 minutes later I had an add-on that solves my needs.
