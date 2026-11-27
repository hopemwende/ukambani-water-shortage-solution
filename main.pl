% village(Name, Population)
village(kyamatu,     1200).
village(mbitini,      800).
village(ngomeni,      500).
village(kathonzweni, 1500).

% source(ID, Type, Status, CapacityLitresPerDay)
source(s1, borehole,       working, 30000).
source(s2, sand_dam,       working, 12000).
source(s3, borehole,       broken,  25000).
source(s4, seasonal_river, working, 20000).
source(s5, water_pan,      working,  6000).

% access(Village, Source, DistanceKm)
access(kyamatu,     s1, 1.0).
access(kyamatu,     s4, 3.0).
access(mbitini,     s2, 1.5).
access(mbitini,     s3, 1.0).
access(ngomeni,     s5, 2.0).
access(ngomeni,     s4, 6.0).
access(kathonzweni, s3, 0.5).
access(kathonzweni, s4, 2.0).

% institutions that raise a village's urgency
has_clinic(mbitini).
has_school(ngomeni).
has_school(kathonzweni).

% current season: dry or wet
season(dry).

% policy constants
litres_per_person(20).   % daily minimum per person
max_walk_km(2.0).        % acceptable walking distance

% Seasonal(s): source dries up outside the wet season
seasonal(S) :- source(S, seasonal_river, _, _).
seasonal(S) :- source(S, water_pan, _, _).

% Usable(s): working, and seasonal sources count only in the wet season
% (sand dams store water, so they stay usable in the dry season)
usable(S) :- source(S, _, working, _), \+ seasonal(S).
usable(S) :- source(S, _, working, _), seasonal(S), season(wet).

needs_repair(S) :- source(S, _, broken, _).

% Supply(v,L): total capacity of usable sources within walking distance
supply(V, Total) :-
    village(V, _), max_walk_km(Max),
    findall(Cap, ( access(V, S, Km), Km =< Max, usable(S),
                   source(S, _, _, Cap) ), Caps),
    sum_list(Caps, Total).

% Demand(v,L): population x daily minimum
demand(V, L) :- village(V, P), litres_per_person(Lp), L is P * Lp.

% Adequate(v) <- Supply >= Demand;  WaterStressed(v) <- NOT Adequate(v)
adequate(V)       :- supply(V, Sup), demand(V, Dem), Sup >= Dem.
water_stressed(V) :- village(V, _), \+ adequate(V).

% Shortfall(v,Gap): litres per day missing
shortfall(V, Gap) :-
    water_stressed(V), supply(V, Sup), demand(V, Dem), Gap is Dem - Sup.

% Priority(v): stressed AND has a clinic or school
priority(V) :- water_stressed(V), has_clinic(V).
priority(V) :- water_stressed(V), has_school(V).

% RepairPriority(s): broken source that sits near a stressed village
repair_priority(S) :-
    needs_repair(S), access(V, S, _), water_stressed(V).

% priority_score(v,Score): 1 point per 1000 L shortfall, +20 clinic, +10 school
priority_score(V, Score) :-
    water_stressed(V), shortfall(V, Gap),
    Base is Gap // 1000,
    ( has_clinic(V) -> C = 20 ; C = 0 ),
    ( has_school(V) -> Sc = 10 ; Sc = 0 ),
    Score is Base + C + Sc.

% ranked_villages(List): villages sorted from most to least urgent
ranked_villages(Ranked) :-
    findall(Neg-V, ( priority_score(V, S), Neg is -S ), Pairs),
    keysort(Pairs, Sorted),
    findall(V-S, ( member(N-V, Sorted), S is -N ), Ranked).


% Fix a broken source that the village can walk to
recommend(V, repair(S)) :-
    water_stressed(V), access(V, S, _), needs_repair(S).

% Nothing to repair nearby -> new borehole
recommend(V, drill_borehole) :-
    water_stressed(V), \+ ( access(V, S, _), needs_repair(S) ).

% Clinic/school village: emergency trucking while the fix is underway
recommend(V, truck_water_now) :- priority(V).

% Long-term dry-season fix: a sand dam where none is within walking distance
sand_dam_candidate(V) :-
    water_stressed(V), max_walk_km(Max),
    \+ ( access(V, S, Km), Km =< Max, source(S, sand_dam, _, _) ).

recommend(V, build_sand_dam) :- sand_dam_candidate(V).

% action_plan(v, Actions): all recommendations for one village
action_plan(V, Actions) :-
    water_stressed(V),
    findall(A, recommend(V, A), All),
    sort(All, Actions).



village_report(V) :-
    supply(V, Sup), demand(V, Dem),
    (   adequate(V)
    ->  format('~w: OK (supply ~w L, demand ~w L)~n', [V, Sup, Dem])
    ;   shortfall(V, Gap),
        format('~w: STRESSED, short by ~w L/day~n', [V, Gap])
    ).
demo :-
    writeln('=== UKAMBANI WATER SITUATION ==='),
    forall(village(V, _), village_report(V)),
    writeln('=== PRIORITY RANKING (most urgent first) ==='),
    ranked_villages(R),
    forall(member(V-S, R), format('~w  (score ~w)~n', [V, S])),
    writeln('=== REPAIR FIRST ==='),
    forall(setof(S, repair_priority(S), L), format('~w~n', [L])),
    writeln('=== ACTION PLAN PER VILLAGE ==='),
    forall(action_plan(V, A), format('~w -> ~w~n', [V, A])).
check(Name, Goal) :-
    (   call(Goal) -> format('PASS  ~w~n', [Name])
    ;   format('FAIL  ~w~n', [Name]) ).

run_tests :-
    check('kyamatu has enough water',      adequate(kyamatu)),
    check('kathonzweni is stressed',       water_stressed(kathonzweni)),
    check('mbitini shortfall = 4000',      shortfall(mbitini, 4000)),
    check('broken s3 is not usable',       \+ usable(s3)),
    check('water pan unusable in dry',     \+ usable(s5)),
    check('s3 is repair priority',         repair_priority(s3)),
    check('kathonzweni ranked first',      ( ranked_villages([V-_|_]), V == kathonzweni )),
    check('mbitini: repair s3',            recommend(mbitini, repair(s3))),
    check('ngomeni: drill borehole',       recommend(ngomeni, drill_borehole)),
    check('mbitini needs no sand dam',     \+ sand_dam_candidate(mbitini)),
    check('ngomeni needs sand dam',        sand_dam_candidate(ngomeni)).
