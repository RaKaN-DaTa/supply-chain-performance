-- ============================================================
-- Supply Chain Analysis
-- تحليل أداء سلسلة التوريد -- 5,000 طلب، 3 موردين، 2021-2023
--
-- الجداول محمّلة من ملفات data/ كالتالي:
--   orders    <- details.csv
--   status    <- order-status.csv       (مربوط بـ orders على Order Number)
--   suppliers <- suppliers.csv          (مربوط بـ orders على Supplier / Supplier id)
-- ============================================================


-- ── 1. حجم العمل: كم طلبًا في المجموع؟
SELECT COUNT(*) AS orders
FROM orders;
-- 5,000


-- ── 2. نسبة التسليم في الموعد
-- أقسم الطلبات "On Time" على الإجمالي. ضربت في 100.0 مو 100
-- عشان تطلع نسبة عشرية بدل ما تُقرّب لعدد صحيح.
SELECT
    COUNT(*)                                                    AS total_orders,
    SUM(CASE WHEN order_status = 'On Time' THEN 1 ELSE 0 END)   AS on_time,
    SUM(CASE WHEN order_status = 'Late'    THEN 1 ELSE 0 END)   AS late,
    ROUND(SUM(CASE WHEN order_status = 'On Time' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 1)                                        AS on_time_pct
FROM status;
-- 5,000 | 4,017 | 983 | 80.3%


-- ── 3. تكلفة الشحن
SELECT
    ROUND(AVG(freight_cost), 2) AS avg_freight_per_order,
    ROUND(SUM(freight_cost))    AS total_freight
FROM status;
-- $100.14 | $500,687


-- ── 4. التلف والمرتجعات كنسبة من الوحدات المشحونة
SELECT
    SUM(units_shipped)                                        AS units_shipped,
    SUM(damaged_units)                                        AS damaged,
    SUM(returns)                                              AS returned,
    ROUND(SUM(damaged_units) * 100.0 / SUM(units_shipped), 2) AS damage_pct,
    ROUND(SUM(returns)       * 100.0 / SUM(units_shipped), 2) AS return_pct
FROM orders;
-- 625,099 | 22,593 | 10,169 | 3.61% | 1.63%


-- ── 5. السؤال الأهم: هل في مورّد أسوأ من الباقين؟
-- هنا احتجت JOIN لأن جدول الطلبات فيه رموز الموردين فقط (S-1, S-2, S-3)
-- والأسماء الحقيقية في جدول ثانٍ.
SELECT
    s.supplier_name,
    COUNT(*)                                                    AS orders,
    SUM(o.units_shipped)                                        AS units,
    ROUND(SUM(o.damaged_units) * 100.0 / SUM(o.units_shipped), 2) AS damage_pct,
    ROUND(AVG(o.raw_material_lead_time), 1)                     AS avg_lead_days
FROM orders o
JOIN suppliers s ON s.supplier_id = o.supplier
GROUP BY s.supplier_name
ORDER BY damage_pct;
-- AG group   | 1,616 | 203,620 | 3.50% | 4.0
-- H7L group  | 1,719 | 213,939 | 3.62% | 4.0
-- Star group | 1,665 | 207,540 | 3.72% | 4.0


-- ── 6. هل التأخير يختلف بين الموردين، أو هي مشكلة عامة؟
SELECT
    s.supplier_name,
    ROUND(SUM(CASE WHEN st.order_status = 'Late' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 1) AS late_pct
FROM orders o
JOIN status    st ON st.order_number = o.order_number
JOIN suppliers s  ON s.supplier_id   = o.supplier
GROUP BY s.supplier_name
ORDER BY late_pct DESC;


-- ============================================================
-- الخلاصة
--
-- الفرق في التلف بين أفضل مورّد وأسوأه 0.22 نقطة فقط، ومهلة
-- المواد الخام 4 أيام عند الثلاثة. يعني المشكلة مو في مورّد
-- معيّن -- هي في شي مشترك بينهم، غالبًا التغليف أو المناولة
-- أثناء النقل. وهذا أرخص في الإصلاح من تغيير مورّد.
-- ============================================================
