:- discontiguous village/2, source/4, access/3.

%% -------- FACTS ----------
% village(Name, Population)
village(kyamatu,  1200).
village(mbitini,   800).
village(ngomeni,   500).
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

has_clinic(mbitini).
has_school(ngomeni).
has_school(kathonzweni).

% season(dry) or season(wet)
season(dry).

% policy constants
litres_per_person(20).     % daily minimum per person
max_walk_km(2.0).          % acceptable walking distance
%% ---------- RULES ----------
seasonal(S) :- source(S, seasonal_river, _, _).
seasonal(S) :- source(S, sand_dam, _, _).
seasonal(S) :- source(S, water_pan, _, _).

% usable now: working, and seasonal sources only count in the wet season
usable(S) :- source(S, _, working, _), \+ seasonal(S).
usable(S) :- source(S, _, working, _), seasonal(S), season(wet).
% sand dams hold water into the dry season, so treat them as usable
usable(S) :- source(S, sand_dam, working, _).

needs_repair(S) :- source(S, _, broken, _).