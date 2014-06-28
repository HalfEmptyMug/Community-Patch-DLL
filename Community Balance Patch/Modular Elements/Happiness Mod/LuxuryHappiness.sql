-- Luxury happiness divisor (City value (Num of owned cities) / 14 = # bonus of luxuries). Game Era affects this (later era = lower potential bonus).

	INSERT INTO Defines (
	Name, Value)
	SELECT 'BALANCE_HAPPINESS_POPULATION_DIVISOR', '0'
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_LUXURY_HAPPINESS' AND Value= 0 );
	
	INSERT INTO Defines (
	Name, Value)
	SELECT 'BALANCE_HAPPINESS_POPULATION_DIVISOR', '14'
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_LUXURY_HAPPINESS' AND Value= 1 );

-- Maximum bonus from luxuries.

	INSERT INTO Defines (
	Name, Value)
	SELECT 'BALANCE_HAPPINESS_LUXURY_MAXIMUM', '0'
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_LUXURY_HAPPINESS' AND Value= 0 );

	INSERT INTO Defines (
	Name, Value)
	SELECT 'BALANCE_HAPPINESS_LUXURY_MAXIMUM', '6'
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_LUXURY_HAPPINESS' AND Value= 1 );

-- Minimum bonus from luxuries.

	INSERT INTO Defines (
	Name, Value)
	SELECT 'BALANCE_HAPPINESS_LUXURY_BASE', '0'
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_LUXURY_HAPPINESS' AND Value= 0 );

	INSERT INTO Defines (
	Name, Value)
	SELECT 'BALANCE_HAPPINESS_LUXURY_BASE', '1'
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_LUXURY_HAPPINESS' AND Value= 1 );