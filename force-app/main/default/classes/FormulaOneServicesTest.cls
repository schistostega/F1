@isTest
private class FormulaOneServicesTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createDriversAndRacesWithResults(4, 2);
    }

    @isTest
    static void generateKeyTest() {
        SObjectType accountType = Schema.getGlobalDescribe().get('Driver__c');
        Map<String, SObjectField> mfields = accountType.getDescribe().fields.getMap();
        String[] fieldNames = new List<String>{
            'Id', 'First_Name__c', 'Last_Name__c', 'Full_Name__c', 'Age__c'
        };
        
        SObjectField[] fields = new List<SObjectField>();
        for (String fieldName: fieldNames) {
            fields.add(mfields.get(fieldName));
        }
        
        Driver__c driver = Database.query(
            'SELECT ' + String.join(fieldNames, ', ')
            + ' FROM Driver__c LIMIT 1'
        );

        List<Object> testValues = new List<Object>();
        for (SObjectField field: fields) {
            Object value = driver.get(field);
            testValues.add(value);
        }
        String testKey = testValues.toString();

        Test.startTest();
        String key = FormulaOneServices.generateKey(driver, fields, ', ');
        Test.stopTest();

        System.assertEquals(testKey, key, 'Wrong key has been received.');
    }

    @isTest
    static void isHatTrickTest() {
        Race_Result__c hatTrickResult = new Race_Result__c(
            Name = 'Test Result',
            Position__c = 1,
            Grid__c = 1,
            Is_Fastest_Lap__c = true
        );
        Race_Result__c notHatTrickResult = new Race_Result__c(
            Name = 'Test Falsy Result',
            Position__c = 2,
            Grid__c = 1,
            Is_Fastest_Lap__c = false
        );

        Test.startTest();
        Boolean isHatTrick = FormulaOneServices.isHatTrick(hatTrickResult);
        Boolean isNotHatTrick = FormulaOneServices.isHatTrick(notHatTrickResult);
        Test.stopTest();

        System.assertEquals(true, isHatTrick);
        System.assertEquals(false, isNotHatTrick);
    }

    @isTest
    static void createDriverTest() {
        String fname = 'TestFirstname';
        String lname = 'TestLastName';
        Integer age = 33;

        Test.startTest();
        FormulaOneServices.createDriver(fname, lname, age);
        Test.stopTest();

        Driver__c driver = [
            SELECT Id, First_Name__c, Last_Name__c, Age__c 
            FROM Driver__c 
            WHERE First_Name__c=:fname AND Last_Name__c=:lname AND Age__c=:age
        ];

        System.assertEquals(fname, driver.First_Name__c);
        System.assertEquals(lname, driver.Last_Name__c);
        System.assertEquals(age, driver.Age__c);
    }

    @isTest
    static void createDriversTest() {
        String fname = 'TestDriver';
        String lname = 'CreatedFromDTO';
        Integer age = 42;

        DriverDTO[] driversDTO = new List<DriverDTO>();
        for (Integer i = 0; i < 5; i++) {
            driversDTO.add(new DriverDTO(fname, lname, age));
        }

        Test.startTest();
        FormulaOneServices.createDrivers(driversDTO);
        Test.stopTest();

        Driver__c[] drivers = [
            SELECT First_Name__c, Last_Name__c, Age__c
            FROM Driver__c
            WHERE First_Name__c=:fname AND Last_Name__c=:lname AND Age__c=:age
        ];

        System.assertEquals(5, drivers.size());
        for (Driver__c driver: drivers) {
            System.assertEquals(fname, driver.First_Name__c);
            System.assertEquals(lname, driver.Last_Name__c);
            System.assertEquals(age, driver.Age__c);
        }
    }

    @isTest
    static void updateDriverNameTest() {
        String fname = 'UpdatedTestDriverName';
        String lname = 'UpdatedTestDriverLastName';
        Driver__c driver = [SELECT First_Name__c, Last_Name__c FROM Driver__c LIMIT 1];

        Test.startTest();
        Driver__c updatedDriver = FormulaOneServices.updateDriverName(driver.Id, fname, lname);
        Test.stopTest();

        System.assertEquals(driver.Id, updatedDriver.Id);
        System.assertEquals(fname, updatedDriver.First_Name__c);
        System.assertEquals(lname, updatedDriver.Last_Name__c);
    }

    @isTest
    static void updateGrandPrixWinnersTest() {
        Race__c[] races = [
            SELECT Id, (SELECT Racer__r.Id, Position__c 
                        FROM Race_Results__r
                        ORDER BY Position__c
                        LIMIT 3) 
            FROM Race__c 
            LIMIT 2
        ];
        Set<Id> raceIds = new Set<Id>();
        for (Race__c race: races) {
            raceIds.add(race.Id);
        }

        Test.startTest();
        Race__c[] updatedRaces = FormulaOneServices.updateGrandPrixWinners(raceIds);
        Test.stopTest();

        Set<Id> checkedIds = new Set<Id>();
        for (Race__c race: races) {
            for (Race__c updatedRace: updatedRaces) {
                if (race.Id == updatedRace.Id) {
                    checkedIds.add(race.Id);
                    System.assertEquals(race.Race_Results__r.get(0).Racer__c, updatedRace.Winner__c);
                    System.assertEquals(race.Race_Results__r.get(1).Racer__c, updatedRace.Podium_Second__c);
                    System.assertEquals(race.Race_Results__r.get(2).Racer__c, updatedRace.Podium_Third__c);
                }
            }
        }

        System.assert(checkedIds.equals(raceIds));
    }
}
