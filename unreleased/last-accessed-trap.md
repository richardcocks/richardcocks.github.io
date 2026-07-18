---
layout: unlisted
title: Performance Pitfalls - Stamping a Last Seen Date / Bad Caching
date: 2026-07-18
permalink: /unreleased/last-accessed-trap/
description: Last Accessed Dates, bad caching, a performance trap
tagline: How to overload your SQLite database
---

# Performance Pitfalls - Stamping a Last Seen Date / Bad Caching

## Introduction

A common pitfall when writing an application is to track when a user was last seen or when some content was last viewed by a user.

This sounds useful, but it's a potential performance trap, because it turns all your read only requests into requests that write to your database.

Often, a small write of a single date or counter shouldn't be a big deal, especially if you are happy to let "last write Win", so you can live with the occasional missed increment, or a date being overwritten with a very slightly earlier one, knowing it's likely to be written over again soon anyway.

But if you follow up that with a decision to use SQLite, or another database which serialises all writes at the globl database level, you've forced every page read through a bottleneck.

Even with WAL mode, an underappreciated fact of SQLite is that all writes must be serialised, which is to say they have to be executed one after another, with no overlap.

This is fine if all your writes are genuinely quick, if every single one is a quick write then there are no problems.

However, if you have a longer write, say a statistics sweep that runs aggregation of your last 90 days traffic, then that longer write could hold up all your other writes.

In some architectures, such as Rails running on Puma with a limited number of worker threads, then a handful of authenticated requests waiting for their turn to stamp the database, could exhaust the worker pool, which then holds up anonymous requests which don't even need to write to the database at all.

## But we can cache anonymous traffic to avoid hitting the application entirely

Yes, but be sure to do so carefully. In preparing for writing this blog post, I[1] found that on one popular application, the cache is evicting its entire contents every minute because of a misconfigured cache eviction cron job.

What should have been `-not -mmin -5` was typo'd as `-not -mmin 5`

Instead of keeping everything under 5 minutes, it was keeping only entries exactly 5 minutes old. On a cron job running every minute, that was a full cache eviction every minute.

 With a hard eviction, no refresh-ahead or soft TTL, so there was also [Cache Stampede](https://en.wikipedia.org/wiki/Cache_stampede).

That is to say, after the page cache evicted everything, all users hitting `/` queue up for the puma rails workers, hoping they aren't also stuck behind requests that are waiting for DB writes.

## Mitigations

The glib answer is "don't use SQLite" and "don't roll your own cache", but that isn't entirely fair. SQLite is fine, particularly for the kind of read-heavy work loads you might expect with a website.

### Avoid writing to the database
It sounds obvious, but the temptation to stick in last-seen, last-accessed dates, or view-counts, will have you hitting the database on what ought to be read paths unless you deliberately handle those with intermediate collectors that can aggregate and batch writes.

### Have a separate application or worker pool for true read-only anonymous requests
Make sure your anonymous requests are read-only. They should be to avoid DOS vectors and to improve cacheability, but double check that. If that is the case, then you can have a separate application or worker pool that serves anonymous users. This way, even on cache misses, you won't get any blocking or contention with the logged on users application.

### Integration test your cache eviction strategy
This can be difficult to do in some frameworks, but if you can control time, then do so to make sure your strategy is correct. That utility, `touch`, that you lazily think of meaning "create new file", is actually a utility that _sets timestamps_ to any value you like. If you're using file caches, set up a directory of files, run `touch` across them with different times, and then run your eviction strategy to check you have what you expect left over.


[1] Well, "I" found. Tools helped. If you're offended by that, please be re-assured this post is entirely my own voice.