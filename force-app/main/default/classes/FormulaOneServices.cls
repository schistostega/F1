public with sharing class FormulaOneServices {
    public static String generateKey(SObject record, List<SObjectField> fields, String separator) {
        List<Object> values = new List<Object>();
        for (SObjectField field: fields) {
            Object value = record.get(field);
            values.add(value);
        }

        return values.toString().replace(', ', separator);
    }

    public static Boolean isHatTrick(Race_Result__c raceResult) {
        return raceResult.Position__c == 1 && 
               raceResult.Grid__c == 1 && 
               raceResult.Is_Fastest_Lap__c == true;
    }

    public static void createDriver(String firstName, String lastName, Integer age) {
        // Create insert driver record, based on input parameters
        Driver__c driver = new Driver__c();
        driver.First_Name__c = firstName;
        driver.Last_Name__c = lastName;
        driver.Age__c = age;

        insert driver;
    }

    public static void createDrivers(List<DriverDTO> driversDTO) {
        // Create and insert list of driver records, based on input parameters
        Driver__c[] drivers = new List<Driver__c>();

        for (DriverDTO dto: driversDTO) {
            Driver__c driver = new Driver__c();
            driver.First_Name__c = dto.firstName;
            driver.Last_Name__c = dto.lastName;
            driver.Age__c = dto.age;
            drivers.add(driver);
        }

        insert drivers;
    }

    public static Driver__c updateDriverName(Id driverId, String firstName, String lastName) {
        // Update driver`s name based on input parameters
        Driver__c driver = [SELECT Id, First_Name__c, Last_Name__c FROM Driver__c WHERE Id = :driverId limit 1];
        driver.First_Name__c = firstName;
        driver.Last_Name__c = lastName;

        update driver;
        return driver;
    }

    public static Race__c[] updateGrandPrixWinners(Set<Id> raceIds) {
        // Get Race__c records based by input params and update Winner__c, Podium_Second__c and Podium_Third__c fields 
        // depending on Position__c field of related Race_Result__c objects
        Race_Result__c[] results = [
            SELECT Grand_Prix__r.Winner__c, Grand_Prix__r.Podium_Second__c, Grand_Prix__r.Podium_Third__c, Position__c, Racer__c
            FROM Race_Result__c
            WHERE Grand_Prix__r.Id IN :raceIds AND Position__c IN :new Set<Integer>{1, 2, 3}
        ];
        
        Map<Id, Race__c> races = new Map<Id, Race__c>();
        for (Race_Result__c result: results) {
            if (result.Position__c == 1) {
                result.Grand_Prix__r.Winner__c = result.Racer__c;
            } 
            else if (result.Position__c == 2) {
                result.Grand_Prix__r.Podium_Second__c = result.Racer__c;
            }
            else if (result.Position__c == 3) {
                result.Grand_Prix__r.Podium_Third__c = result.Racer__c;
            }
            races.put(result.Grand_prix__r.Id, result.Grand_prix__r);
        }

        update races.values();
        return races.values();
    }
}
