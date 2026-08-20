"""
Supply Chain Analysis — loads the 3 raw CSVs into SQLite and prints the
headline KPIs. Standard library only, no installs needed.

    python backend/etl.py

Source data (data/): details.csv, order-status.csv, suppliers.csv
5,000 orders across 3 suppliers, 2021.
"""
import csv, os, sqlite3
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "..", "data")
DB   = os.path.join(HERE, "supply_chain.db")


def load_csv(name):
    with open(os.path.join(DATA, name), encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def build():
    details  = load_csv("details.csv")
    statuses = load_csv("order-status.csv")
    suppliers = load_csv("suppliers.csv")
    status_by_order = {r["Order Number"]: r for r in statuses}

    con = sqlite3.connect(DB)
    con.execute("DROP TABLE IF EXISTS orders")
    con.execute("""CREATE TABLE orders(
        order_no TEXT PRIMARY KEY, supplier_id TEXT, order_date TEXT, order_status TEXT,
        freight_cost REAL, mfg_days INTEGER, delivery_days INTEGER,
        units_shipped INTEGER, damaged_units INTEGER, returns INTEGER, lead_time_days INTEGER)""")
    con.execute("DROP TABLE IF EXISTS suppliers")
    con.execute("CREATE TABLE suppliers(id TEXT PRIMARY KEY, name TEXT)")

    for r in suppliers:
        con.execute("INSERT INTO suppliers VALUES(?,?)", (r["Supplier id"], r["Supplier name"]))

    for r in details:
        s = status_by_order.get(r["Order Number"], {})
        con.execute("""INSERT INTO orders VALUES(?,?,?,?,?,?,?,?,?,?,?)""", (
            r["Order Number"], r["Supplier"], s.get("Order Date"), s.get("Order Status"),
            float(s.get("Freight Cost") or 0), int(r["Manufacturing Time (days)"]),
            int(r["Delivery Time (days)"]), int(r["Units Shipped"]), int(r["Damaged Units"]),
            int(r["Returns"]), int(r["Raw Material Lead Time (days)"])))
    con.commit()
    return con


def report(con):
    q = lambda sql: con.execute(sql).fetchone()
    n = q("SELECT COUNT(*) FROM orders")[0]
    on_time = q("SELECT COUNT(*) FROM orders WHERE order_status = 'On Time'")[0]
    units, damaged, returns = q("SELECT SUM(units_shipped), SUM(damaged_units), SUM(returns) FROM orders")
    freight = q("SELECT ROUND(AVG(freight_cost),2), ROUND(SUM(freight_cost)) FROM orders")

    print(f"Orders               : {n:,}")
    print(f"On-time rate         : {on_time/n*100:.1f}%  ({n-on_time:,} late)")
    print(f"Avg freight cost     : ${freight[0]}   Total freight: ${freight[1]:,.0f}")
    print(f"Units shipped        : {units:,}")
    print(f"Damage rate          : {damaged/units*100:.2f}%  ({damaged:,} units)")
    print(f"Return rate          : {returns/units*100:.2f}%  ({returns:,} units)")
    print()
    print("By supplier:")
    for row in con.execute("""
            SELECT s.name, COUNT(*) orders, SUM(o.units_shipped) units,
                   ROUND(100.0*SUM(o.damaged_units)/SUM(o.units_shipped),2) damage_pct,
                   ROUND(AVG(o.lead_time_days),1) avg_lead
            FROM orders o JOIN suppliers s ON s.id = o.supplier_id
            GROUP BY s.name ORDER BY damage_pct"""):
        print(f"  {row[0]:<12} orders={row[1]:,}  units={row[2]:,}  damage={row[3]}%  avg_lead={row[4]}d")


if __name__ == "__main__":
    con = build()
    report(con)
    print("\ndb:", DB)
