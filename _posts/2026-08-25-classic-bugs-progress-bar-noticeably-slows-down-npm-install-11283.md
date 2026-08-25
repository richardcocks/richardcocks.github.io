---
layout: post
title: "Classic Bugs: Progress bar noticeably slows down npm install #11283"
date: 2026-08-25
description: Surely a progress bar can't affect performance that much?
tagline: Surely a progress bar can't affect performance that much?
image: https://opengraph.githubassets.com/b372a452748e1059f4429a3267dd0995eb6c6e8305571ad024e6c08452e791cb/npm/npm/issues/11283
---
# Classic Bugs: Progress bar noticeably slows down npm install #11283

Throwback to 2016, and one of my all-time favourite classic bugs that serves as a cautionary tale to us all.

Raised by [@zakjan](https://github.com/zakjan), bug #[11283](https://github.com/npm/npm/issues/11283) was reported as:

> Compare these runtimes of npm install:
>
> ```
> $ rm -r node_modules
> $ npm set progress=false
> $ time npm install
> npm install  19.91s user 2.66s system 71% cpu 31.667 total
>
> $ rm -r node_modules
> $ npm set progress=true
> $ time npm install
> npm install  33.26s user 3.19s system 74% cpu 48.733 total
> ```
>
> Npm 3.5.2. Both commands were run with already warmed-up cache. Progress bar may be responsible for up to 50% slow down.

This went under the radar for a long time. It was generally assumed that any real work done behind the progress bar would make the bar itself trivial.

It wasn't until a user spotted how much quicker it was when not rendering the progress bar that it was raised and fixed. This was despite it adding [several minutes](https://github.com/npm/npm/issues/11283#issuecomment-175008877) overhead in some cases.

My takeaway: Always be aware of how long things take and try to have a sense of how long they ought to take. That keeps you alert to regressions but also, as in this case, anti-regressions under different conditions.