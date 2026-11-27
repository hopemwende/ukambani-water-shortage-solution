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
