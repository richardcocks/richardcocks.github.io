---
layout: unlisted
title: SELECT CASE WHEN 1 / 5 * 100.0 = 1 * 100.0 / 5 THEN 1 ELSE 0 END AS Huh
date: 2026-07-20
description: A SQL Engine gotcha
tagline: When true isn't true
---

# SELECT CASE WHEN 1 / 5 * 100.0 = 1 * 100.0 / 5 THEN 1 ELSE 0 END AS Huh

Whether the headline query returns `1` or `0` depends entirely on your SQL engine of choice. The query is entirely valid to the ISO SQL standard, yet perhaps surprisingly, the result is still vendor specific.

I used [codapi.org](https://codapi.org) to run this query against each of their databases.

```
SELECT CASE WHEN 1 / 5 * 100.0 = 1 * 100.0 / 5 THEN 1 ELSE 0 END AS Huh
```
## Vendor Results

| Vendor | Huh |
|-------------------|-----|
|ChDb|1|
|Clickhouse|1|
|DuckDB|1|
|MariaDb|1|
|MySql|1|
|PostgreSQL|0|
|SQLite|0|
|MsSql|0|
|Oracle|1| 

Oracle isn't quite true, it required adding `FROM DUAL` , because it doesn't allow `SELECT <expr>` without a `FROM` clause.

## Migration headaches

The reason behind this is whether `1/5` truncates to `0` or evaluates as `0.2`, and while this might look like an obvious difference, it can get hidden when these aren't literals, but are fields. Whether further multiplication by a float happens inside or outside a subquery can then also make a difference.

Be very wary when porting code between databases, even if you don't use vendor extensions like T-SQL, because this kind of calculation change can go unnoticed, potentially for a long time.