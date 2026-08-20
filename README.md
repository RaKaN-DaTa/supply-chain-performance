# Supply Chain Analysis

![preview](preview.jpg)

5,000 orders, three suppliers, three years (2021-2023). I wanted to know where
the delays and the losses are actually coming from, and whether any one supplier
is the cause.

## What I found

| | |
|---|---|
| Orders | 5,000 |
| On time | 80.3% — 983 arrived late |
| Average freight | $100.14 per order |
| Units damaged | 3.61% (22,593 units) |
| Units returned | 1.63% (10,169 units) |

One order in five is late, which is the number people notice first. The more
useful finding is underneath it: damage rates barely move between suppliers —
3.50% for AG group, 3.62% for H7L, 3.72% for Star. Star is the worst of the
three, but the whole spread is a fifth of a percentage point.

All three run the same 4-day lead time on raw material. Same speed, near-identical
damage. That rules out "one bad supplier" and points at something shared —
handling or packaging in transit — which is the cheaper problem to have.

## What I did

Three raw tables: order details, order status, suppliers. Loaded them into
SQLite and wrote the queries for on-time rate, freight, damage and returns —
overall and broken down by supplier.

Most of the actual work was in the joins. The orders table only carries supplier
codes (`S-1`, `S-2`, `S-3`); the names live in a second file, and order status is
a third. Get a join wrong and every percentage after it is wrong too.

## The queries

`queries.sql` has all of them, with a note on each explaining what it answers.
Load the three CSVs as `orders`, `status` and `suppliers` in any SQL tool and
they run as-is.

## Files

```
data/                          the three raw CSVs
queries.sql                    the SQL behind every number here
supply-chain-dashboard.xlsx    an interactive Excel dashboard over the same data
```

## Tools

SQL, SQLite, Excel

---
Rakan Ahmed Al-Nusayri — [github.com/RaKaN-DaTa](https://github.com/RaKaN-DaTa)
