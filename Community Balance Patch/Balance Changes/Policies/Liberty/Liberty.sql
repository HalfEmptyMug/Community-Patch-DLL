-- Great Writers come from Liberty

INSERT INTO Policy_FaithPurchaseUnitClasses (PolicyType, UnitClassType)
SELECT 'POLICY_LIBERTY_FINISHER' , 'UNITCLASS_WRITER'
WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Change Liberty Arrangement

UPDATE Policies
SET GridX = '4'
WHERE Type = 'POLICY_COLLECTIVE_RULE' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET GridY = '1'
WHERE Type = 'POLICY_COLLECTIVE_RULE' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET GridX = '1'
WHERE Type = 'POLICY_CITIZENSHIP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET GridY = '2'
WHERE Type = 'POLICY_CITIZENSHIP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

DELETE FROM Policy_PrereqPolicies
WHERE PrereqPolicy = 'POLICY_CITIZENSHIP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

DELETE FROM Policy_PrereqPolicies
WHERE PrereqPolicy = 'POLICY_COLLECTIVE_RULE' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

DELETE FROM Policy_PrereqPolicies
WHERE PrereqPolicy = 'POLICY_REPRESENTATION' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

DELETE FROM Policy_PrereqPolicies
WHERE PrereqPolicy = 'POLICY_MERITOCRACY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

DELETE FROM Policy_PrereqPolicies
WHERE PrereqPolicy = 'POLICY_REPUBLIC' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Liberty Opener
UPDATE Policies
SET CulturePerCity = '0'
WHERE Type = 'POLICY_LIBERTY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET BuildingProductionModifier = '5'
WHERE Type = 'POLICY_LIBERTY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Collective Rule (Now City Planning)
UPDATE Policies
SET CapitalSettlerProductionModifier = '0'
WHERE Type = 'POLICY_COLLECTIVE_RULE' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

DELETE FROM Policy_FreeUnitClasses
WHERE PolicyType = 'POLICY_COLLECTIVE_RULE' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET BuildingProductionModifier = '2'
WHERE Type = 'POLICY_COLLECTIVE_RULE' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Citizenship (Now Free Labor)
UPDATE Policies
SET BuildingProductionModifier = '2'
WHERE Type = 'POLICY_CITIZENSHIP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Republic (Now Civil Engineers)
UPDATE Policies
SET BuildingProductionModifier = '2'
WHERE Type = 'POLICY_REPUBLIC' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET RouteGoldMaintenanceMod = '-50'
WHERE Type = 'POLICY_REPUBLIC' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policy_CityYieldChanges
SET Yield = '1'
WHERE PolicyType = 'POLICY_REPUBLIC' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Representation 
UPDATE Policies
SET GoldenAgeTurns = '0'
WHERE Type = 'POLICY_REPRESENTATION' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET NumCitiesPolicyCostDiscount = '0'
WHERE Type = 'POLICY_REPRESENTATION' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET BuildingProductionModifier = '2'
WHERE Type = 'POLICY_REPRESENTATION' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET HappinessPerXPopulationGlobal = '10'
WHERE Type = 'POLICY_REPRESENTATION' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Meritocracy
UPDATE Policies
SET HappinessPerTradeRoute = '0'
WHERE Type = 'POLICY_MERITOCRACY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET ExtraMoves = '1'
WHERE Type = 'POLICY_MERITOCRACY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET UnhappinessMod = '0'
WHERE Type = 'POLICY_MERITOCRACY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

UPDATE Policies
SET BuildingProductionModifier = '2'
WHERE Type = 'POLICY_MERITOCRACY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Finisher

UPDATE Policies
SET UnlocksPolicyBranchEra = 'ERA_MEDIEVAL'
WHERE Type = 'POLICY_LIBERTY_FINISHER' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );

-- Finisher
UPDATE Policies
SET IdeologyPoint = '1'
WHERE Type = 'POLICY_LIBERTY_FINISHER' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_POLICIES' AND Value= 1 );
