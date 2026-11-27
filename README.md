# Ukambani Water Shortage: Predicate Calculus + Prolog

## Community need
Ukambani relies on seasonal rivers, water pans and a few boreholes. In the dry season sources dry up, boreholes stay broken, and nobody ranks which village needs help first. This system uses logic to find stressed villages, rank them, and recommend actions.

## Predicate calculus model
**Predicates:** `Village(v,pop)`, `Source(s,type,status,cap)`, `Access(v,s,km)`, `Usable(s)`, `Supply(v,L)`, `Demand(v,L)`, `Adequate(v)`, `WaterStressed(v)`, `Priority(v)`, `NeedsRepair(s)`

| Rule | First-order logic | Prolog |
|------|-------------------|--------|
| Needs repair | ∀s. Source(s,_,broken,_) → NeedsRepair(s) | `needs_repair/1` |
| Usable | ∀s. Source(s,_,working,_) ∧ (¬Seasonal(s) ∨ Wet) → Usable(s) | `usable/1` |
| Adequate | ∀v. Supply(v) ≥ Demand(v) → Adequate(v) | `adequate/1` |
| Stressed | ∀v. Village(v,_) ∧ ¬Adequate(v) → WaterStressed(v) | `water_stressed/1` |
| Priority | ∀v. WaterStressed(v) ∧ (HasClinic(v) ∨ HasSchool(v)) → Priority(v) | `priority/1` |
| Repair first | ∀s. NeedsRepair(s) ∧ ∃v.(Access(v,s,_) ∧ WaterStressed(v)) → RepairPriority(s) | `repair_priority/1` |
| Sand dam | ∀v. WaterStressed(v) ∧ ¬∃s.(Access(v,s,k) ∧ k ≤ 2 ∧ SandDam(s)) → SandDamCandidate(v) | `sand_dam_candidate/1` |

`Demand = population × 20 L/day`. `Supply` = capacity of usable sources within 2 km.

## Run
```bash
cd src
swipl main.pl
?- demo.
?- run_tests.
```
## Sample querries
```bash
% ?- water_stressed(V).
% ?- shortfall(V, Gap).
% ?- priority(V).
% ?- repair_priority(S).
% ?- recommend(V, Action).
```
## Sample result
Kathonzweni ranks most urgent (score 40), then Mbitini (24), then Ngomeni (20). Repair borehole `s3` first, since it serves two stressed villages.


## Assumptions and limits
Sample data is fictional. Supply is not split between villages sharing one source (a real version would add allocation). Months-ago replaces real dates to keep the logic readable.


## Assumptions
Data is fictional. Supply is not split between villages sharing a source. Replace the facts with real Ukambani data.lus models.


## Team
|Name   |REG NO |
|-------|-------|
|1. Hope Mwende      |C026-01-0935/2025
|2. Timothy Njuguna  |C026-01-0955/2025
|3. Felix Otieno     |C026-01-0975/2025
|4. Edmond Kipchumba |C026-01-0965/2025
|5. Edwin Kariuki    |C026-01-0925/2025