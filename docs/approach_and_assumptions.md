# Approach & Assumptions

## SQL
- Used window functions (ROW_NUMBER, RANK, DENSE_RANK)
- CTEs to simplify complex transformations
- Guarded joins to avoid revenue/expense duplication

## Spreadsheet
- Helper columns for transparent logic
- INDEX-MATCH for scalable lookups
- COUNTIFS for conditional aggregation

## Python
- Explicit loops (no shortcuts) to demonstrate logic
- Edge cases handled (0 minutes, exact hours, empty strings)

## Assumptions
- Clean relational integrity
- Dates are valid and consistent
- Expenses align with corresponding months