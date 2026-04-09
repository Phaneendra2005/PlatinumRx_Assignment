# Spreadsheet Formulas

## Q1: Lookup ticket_created_at using cms_id

### VLOOKUP
=VLOOKUP(A2, tickets!A:B, 2, FALSE)

### INDEX-MATCH (recommended)
=INDEX(tickets!B:B, MATCH(A2, tickets!A:A, 0))

---

## Q2a: Same-day open & close per outlet

Helper Column (D2):
=IF(DATE(A2)=DATE(B2),1,0)

COUNTIFS:
=COUNTIFS(outlet_range, outlet, helper_col, 1)

---

## Q2b: Same-hour same-day open & close per outlet

Helper Column:
=IF(AND(DATE(A2)=DATE(B2), HOUR(A2)=HOUR(B2)),1,0)

COUNTIFS:
=COUNTIFS(outlet_range, outlet, helper_col, 1)