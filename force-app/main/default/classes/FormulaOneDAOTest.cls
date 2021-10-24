@isTest
private class FormulaOneDAOTest {
    @testSetup
    static void dataCreation() {
        TestDataFactory.createDriversAndRacesWithResults(4, 2);
    }

    @isTest
    static void getDriverTest() {
        String[] fields = new List<String>{'First_Name__c', 'Last_Name__c', 'Age__c'};
        Driver__c testDriver = Database.query(
            'SELECT ' + String.join(fields, ', ')
            + ' FROM Driver__c'
            + ' LIMIT 1'
        );

        Test.startTest();
        FormulaOneDAO dao = new FormulaOneDAO();
        Driver__c driver = dao.getDriver(testDriver.Id, fields);
        Test.stopTest();

        System.assertEquals(testDriver.First_Name__c, driver.First_Name__c, 'Wrong First_Name__c attribute value.');
        System.assertEquals(testDriver.Last_Name__c, driver.Last_Name__c, 'Wrong Last_Name__c attribute value.');
        System.assertEquals(testDriver.Age__c, driver.Age__c, 'Wrong Age__c attribute value.');
    }

    @isTest
    static void getRaceResultsTest() {
        Driver__c driver = [
            SELECT Id, (SELECT Name, Grand_Prix__c, Position__c, Is_Fastest_Lap__c, Racer__c
                        FROM Race_Results__r)
            FROM Driver__c
            LIMIT 1
        ];

        Test.startTest();
        FormulaOneDAO dao = new FormulaOneDAO();
        // Racer__c field is obligatory, do not remove it. This filed will be queried in subquery above anyway.
        Race_Result__c[] results = dao.getRaceResults(driver.id, new List<String>{
            'Name', 'Grand_Prix__c', 'Position__c', 'Is_Fastest_Lap__c', 'Racer__c'
        });
        Test.stopTest();

        System.assert(results.equals(driver.Race_Results__r), 'Lists of race results are different.');
    }

    @isTest
    static void getDriverCircuitsTest() {
        Driver__c driver = [
            SELECT Id, (SELECT Name, Grand_Prix__r.Name FROM Race_Results__r)
            FROM Driver__c
            LIMIT 1
        ];
        Set<String> testRaceNames = new Set<String>();
        for (Race_Result__c result: driver.Race_Results__r) {
            testRaceNames.add(result.Grand_Prix__r.Name);
        }

        Test.startTest();
        FormulaOneDAO dao = new FormulaOneDAO();
        Set<String> raceNames = dao.getDriverCircuits(driver.Id);
        Test.stopTest();

        System.assert(raceNames.equals(testRaceNames));
    }

    @isTest
    static void getYoungestDriverOnRaceTest() {
        Race__c race = [
            SELECT Id, (SELECT Racer__r.Age__c
                        FROM Race_Results__r 
                        ORDER BY Racer__r.Age__c) 
            FROM Race__c 
            LIMIT 1
        ];

        Test.startTest();
        FormulaOneDAO dao = new FormulaOneDAO();
        Driver__c driver = dao.getYoungestDriverOnRace(race.Id, new List<String>{
            'Full_Name__c', 'Age__c'
        });
        Test.stopTest();

        System.assert(race.Race_Results__r.get(0).Racer__r.Id == driver.Id, 'Picked wrong yongest driver.');
    }

    @isTest
    static void getAllDriversByCircuitTest() {
        Race__c[] races = [SELECT Name FROM Race__c];

        Test.startTest();
        FormulaOneDAO dao = new FormulaOneDAO();
        Map<String, String[]> raceDriversMap = dao.getAllDriversByCircuit();
        Test.stopTest();

        System.assert(raceDriversMap.size() == races.size(), 'Wrong size of result map.');
        for (Race__c race: races) {
            System.assert(raceDriversMap.containsKey(race.Name), 'Map does not contain key - obligatory race name.');
        }
    }
}
