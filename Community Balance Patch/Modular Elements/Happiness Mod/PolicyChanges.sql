--Monarchy

--UPDATE Policies
--SET CapitalUnhappinessMod = '0'
--WHERE Type = 'POLICY_MONARCHY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--UPDATE Policies
--SET PovertyHappinessModCapital = '-10'
--WHERE Type = 'POLICY_MONARCHY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--UPDATE Policies
--SET DefenseHappinessModCapital = '-10'
--WHERE Type = 'POLICY_MONARCHY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--UPDATE Language_en_US
--SET Text = '[COLOR_POSITIVE_TEXT]Monarchy[ENDCOLOR][NEWLINE]+1 [ICON_GOLD] Gold for every 2 [ICON_CITIZEN] Citizens in the [ICON_CAPITAL] Capital, and reduces [ICON_HAPPINESS_3] Poverty and Disorder thresholds by 10% in the [ICON_CAPITAL] Capital.'
--WHERE Tag = 'TXT_KEY_POLICY_MONARCHY_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_MERITOCRACY

--UPDATE Policies
--SET PovertyHappinessMod = '-10'
--WHERE Type = 'POLICY_MERITOCRACY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--UPDATE Policies
--SET UnhappinessMod = '0'
--WHERE Type = 'POLICY_MERITOCRACY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--UPDATE Language_en_US
--SET Text = '[COLOR_POSITIVE_TEXT]Meritocracy[ENDCOLOR][NEWLINE]+1 [ICON_HAPPINESS_1] Happiness for each City you own [ICON_CONNECTED] connected to the [ICON_CAPITAL] Capital and reduces [ICON_HAPPINESS_3] Poverty threshold by 10% in all Cities.'
--WHERE Tag = 'TXT_KEY_POLICY_MERITOCRACY_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_ARISTOCRACY

--UPDATE Policies
--SET UnculturedHappinessModCapital = '-10'
--WHERE Type = 'POLICY_ARISTOCRACY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--UPDATE Policies
--SET HappinessPerXPopulation = '0'
--WHERE Type = 'POLICY_ARISTOCRACY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--UPDATE Language_en_US
--SET Text = '[COLOR_POSITIVE_TEXT]Aristocracy[ENDCOLOR][NEWLINE]+15% [ICON_PRODUCTION] Production when building Wonders and reduces [ICON_HAPPINESS_3] Boredom threshold by 10% in the [ICON_CAPITAL] Capital.'
--WHERE Tag = 'TXT_KEY_POLICY_ARISTOCRACY_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );


-- POLICY_MILITARY_CASTE

--UPDATE Policies
--SET DefenseHappinessMod = '-10'
--WHERE Type = 'POLICY_MILITARY_CASTE' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--UPDATE Policies
--SET HappinessPerGarrisonedUnit = '0'
--WHERE Type = 'POLICY_MILITARY_CASTE' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--UPDATE Language_en_US
--SET Text = '[COLOR_POSITIVE_TEXT]Military Caste[ENDCOLOR][NEWLINE]Each City with a garrison increases empire [ICON_CULTURE] Culture by 2. Reduces [ICON_HAPPINESS_3] Disorder threshold by 10% in all Cities.'
--WHERE Tag = 'TXT_KEY_POLICY_MILITARY_CASTE_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );


-- POLICY_PROTECTIONISM
UPDATE Policies
SET PovertyHappinessMod = '-10'
WHERE Type = 'POLICY_PROTECTIONISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET PovertyHappinessModCapital = '-10'
WHERE Type = 'POLICY_PROTECTIONISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET ExtraHappinessPerLuxury = '0'
WHERE Type = 'POLICY_PROTECTIONISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Language_en_US
SET Text = '[COLOR_POSITIVE_TEXT]Protectionism[ENDCOLOR][NEWLINE]Reduces [ICON_HAPPINESS_3] Poverty threshold by 10% in all Cities and an additional 10% in [ICON_CAPITAL] Capital.'
WHERE Tag = 'TXT_KEY_POLICY_PROTECTIONISM_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_HONOR_FINISHER

--UPDATE Policies
--SET PuppetUnhappinessModPolicy = '-20'
--WHERE Type = 'POLICY_HONOR_FINISHER' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--UPDATE Language_en_US
--SET Text = '[COLOR_POSITIVE_TEXT]Honor[ENDCOLOR] improves the effectiveness of your army in a variety of ways.[NEWLINE][NEWLINE]Adopting Honor gives a +25% combat bonus VS Barbarians, and notifications will be provided when new Barbarian Encampments spawn in revealed territory. Gain [ICON_CULTURE] Culture for the empire from each barbarian killed.[NEWLINE][NEWLINE]Adopting all policies in the Honor tree will grant [ICON_GOLD] Gold for each enemy unit killed, and [ICON_HAPPINESS_3] Unhappiness generated by [ICON_PUPPET] Puppet Cities will be reduced by 20%.'
--WHERE Tag = 'TXT_KEY_POLICY_BRANCH_HONOR_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_PIETY

UPDATE Policies
SET UnculturedHappinessMod = '-10'
WHERE Type = 'POLICY_PIETY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Language_en_US
SET Text = '[COLOR_POSITIVE_TEXT]Piety[ENDCOLOR] increases the [ICON_PEACE] Faith of empires.[NEWLINE][NEWLINE]Adopting Piety allows you to build Shrines and Temples in half the usual time, and reduces [ICON_HAPPINESS_3] Boredom threshold by 10% in all Cities. Unlocks building the Great Mosque of Djenne.[NEWLINE][NEWLINE]Adopting all Policies in the Piety tree causes a Great Prophet to appear and Holy Sites provide +3 [ICON_CULTURE] Culture.'
WHERE Tag = 'TXT_KEY_POLICY_BRANCH_PIETY_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_CAPITALISM

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_CAPITALISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET NoUnhappfromXSpecialists = '2'
WHERE Type = 'POLICY_CAPITALISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Language_en_US
SET Text = '[COLOR_POSITIVE_TEXT]Capitalism[ENDCOLOR][NEWLINE]2 [ICON_CITIZEN] Specialists in each of your cities no longer cause [ICON_HAPPINESS_3] Unhappiness.'
WHERE Tag = 'TXT_KEY_POLICY_CAPITALISM_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_NAVAL_TRADITION

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_NAVAL_TRADITION' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Language_en_US
SET Text = '[COLOR_POSITIVE_TEXT]Naval Tradition[ENDCOLOR][NEWLINE]Receive a free Seaport in your first four coastal cities.'
WHERE Tag = 'TXT_KEY_POLICY_NAVAL_TRADITION_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_URBANIZATION

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_URBANIZATION' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET NoUnhappfromXSpecialistsCapital = '5'
WHERE Type = 'POLICY_URBANIZATION' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Language_en_US
SET Text = '[COLOR_POSITIVE_TEXT]Urbanization[ENDCOLOR][NEWLINE]5 [ICON_CITIZEN] Specialists in your [ICON_CAPITAL] no longer cause [ICON_HAPPINESS_3] Unhappiness.'
WHERE Tag = 'TXT_KEY_POLICY_URBANIZATION_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_SOCIALIST_REALISM

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_SOCIALIST_REALISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Language_en_US
SET Text = '[COLOR_POSITIVE_TEXT]Socialist Realism[ENDCOLOR][NEWLINE]Receive a free Museum in your first four cities.'
WHERE Tag = 'TXT_KEY_POLICY_SOCIALIST_REALISM_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_ACADEMY_SCIENCES

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_ACADEMY_SCIENCES' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET IlliteracyHappinessMod = '-15'
WHERE Type = 'POLICY_ACADEMY_SCIENCES' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Language_en_US
SET Text = '[COLOR_POSITIVE_TEXT]Academy of Sciences[ENDCOLOR][NEWLINE]Reduces [ICON_HAPPINESS_3] Illiteracy threshold by -15% in all cities.'
WHERE Tag = 'TXT_KEY_POLICY_ACADEMY_SCIENCES_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_YOUNG_PIONEERS

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_YOUNG_PIONEERS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Language_en_US
SET Text = '[COLOR_POSITIVE_TEXT]Young Pioneers[ENDCOLOR][NEWLINE]Receive a free Workshop in every city.'
WHERE Tag = 'TXT_KEY_POLICY_YOUNG_PIONEERS_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_MILITARISM

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_MILITARISM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Language_en_US
SET Text = '[COLOR_POSITIVE_TEXT]Militarism[ENDCOLOR][NEWLINE]Receive a free Military Academy in your first four cities.'
WHERE Tag = 'TXT_KEY_POLICY_MILITARISM_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

-- POLICY_FORTIFIED_BORDERS

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_FORTIFIED_BORDERS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET DefenseHappinessMod = '-20'
WHERE Type = 'POLICY_FORTIFIED_BORDERS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Language_en_US
SET Text = '[COLOR_POSITIVE_TEXT]Fortified Borders[ENDCOLOR][NEWLINE]Reduces [ICON_HAPPINESS_3] Disorder threshold by 20% in every city.'
WHERE Tag = 'TXT_KEY_POLICY_FORTIFIED_BORDERS_HELP' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--POLICY_UNIVERSAL_HEALTHCARE_F

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_UNIVERSAL_HEALTHCARE_F' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET Help = 'TXT_KEY_POLICY_UNIVERSAL_HEALTHCARE_F_HELP'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_F' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET Description = 'TXT_KEY_POLICY_UNIVERSAL_HEALTHCARE_F'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_F' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--POLICY_UNIVERSAL_HEALTHCARE_O

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_UNIVERSAL_HEALTHCARE_O' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET PovertyHappinessMod = '-15'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_O' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET Help = 'TXT_KEY_POLICY_UNIVERSAL_HEALTHCARE_O_HELP'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_O' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET Description = 'TXT_KEY_POLICY_UNIVERSAL_HEALTHCARE_O'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_O' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET Civilopedia = 'TXT_KEY_POLICY_UNIVERSAL_HEALTHCARE_TEXT_O'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_O' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

--POLICY_UNIVERSAL_HEALTHCARE_A

UPDATE Policy_BuildingClassHappiness
SET Happiness = '0'
WHERE PolicyType = 'POLICY_UNIVERSAL_HEALTHCARE_A' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET NoUnhappfromXSpecialistsCapital = '2'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_A' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET NoUnhappfromXSpecialists = '1'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_A' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET Help = 'TXT_KEY_POLICY_UNIVERSAL_HEALTHCARE_A_HELP'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_A' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET Description = 'TXT_KEY_POLICY_UNIVERSAL_HEALTHCARE_A'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_A' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );

UPDATE Policies
SET Civilopedia = 'TXT_KEY_POLICY_UNIVERSAL_HEALTHCARE_TEXT_A'
WHERE Type = 'POLICY_UNIVERSAL_HEALTHCARE_A' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='COMMUNITY_CORE_BALANCE_CITY_HAPPINESS' AND Value= 1 );
