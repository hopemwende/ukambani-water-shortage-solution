# Community Logic Project: Vaccination Tracking and Ukambani Water Access
**Predicate Calculus (First-Order Logic) + Prolog**

## 1. Community needs
| # | Problem | Why it matters |
|---|---------|----------------|
|  | Ukambani water shortage | Seasonal rivers dry up, boreholes break and stay broken, and nobody ranks which village needs help first |

## 2. Why logic fits
Both are **rule-based decision problems**: facts (animals, villages, sources) plus rules (what is overdue, who is stressed) from which new facts are derived. This is exactly what Horn clauses in Prolog do.

## 3. Predicate calculus models

### Problem: Ukambani water
**Predicates:** `Village(v,pop)`, `Source(s,type,status,cap)`, `Access(v,s,km)`, `Usable(s)`, `Adequate(v)`, `WaterStressed(v)`, `Priority(v)`, `NeedsRepair(s)`

| Rule | First-order logic | Prolog |
|------|-------------------|--------|
| Needs repair | ∀s. Source(s,_,broken,_) → NeedsRepair(s) | `needs_repair/1` |
| Adequate | ∀v. Supply(v) ≥ Demand(v) → Adequate(v) | `adequate/1` |
| Stressed | ∀v. Village(v,_) ∧ ¬Adequate(v) → WaterStressed(v) | `water_stressed/1` |
| Priority | ∀v. WaterStressed(v) ∧ (HasClinic(v) ∨ HasSchool(v)) → Priority(v) | `priority/1` |
| Repair first | ∀s. NeedsRepair(s) ∧ (∃v. Access(v,s,_) ∧ WaterStressed(v)) → RepairPriority(s) | `repair_priority/1` |

`Demand(v) = population × 20 L/day`. `Supply(v)` = sum of capacities of usable sources within 2 km.

## 4. Technology integration (real-world delivery)
`movement_permit/1` is checked at markets and checkpoints.
- **Water:** county water office keeps the facts updated from field reports; `recommend/2` produces the weekly repair and trucking list.

## 5. How to run
```bash
swipl src/water.pl         # ?- recommend(V,Action).
```

## 6. Sample output
```
shortfall: mbitini 4000 | ngomeni 10000 | kathonzweni 30000 L/day
repair first: s3
```

## 7. Assumptions and limits
Sample data is fictional. Supply is not split between villages sharing one source (a real version would add allocation). Months-ago replaces real dates to keep the logic readable.

## 9. AI Usage
AI was used to generate the predicate calculus models.

## 8. Team
|Name   |REG NO |
|-------|-------|
|1. Hope Mwende      |C026-01-0935/2025
|2. Timothy Njuguna  |C026-01-0955/2025
|3. Felix Otieno     |C026-01-0975/2025
|4. Edmond Kipchumba |C026-01-0965/2025
|5. Edwin Kariuki    |C026-01-0925/2025
