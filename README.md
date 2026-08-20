# Supply Chain Analysis

![preview](preview.jpg)

5,000 orders, three suppliers, one year. I wanted to know where the delays and
the losses are actually coming from, and whether any one supplier is the cause.

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

Three raw tables: order details, order status, suppliers. `backend/etl.py` loads
them into SQLite and runs the queries for on-time rate, freight, damage and
returns, overall and per supplier. Standard library only, so it runs anywhere
Python does.

Most of the actual work was reconciling the three tables — order status and
order details don't line up one-to-one, and the join has to be right before any
percentage means anything.

## Run it

```bash
python backend/etl.py
```

Prints every number in the table above.

## Files

```
data/         the three raw CSVs
backend/etl.py   loads them into SQLite and prints the results
```

## Tools

Python, SQLite, SQL, Excel

---
Rakan Ahmed Al-Nusayri — [github.com/RaKaN-DaTa](https://github.com/RaKaN-DaTa)
