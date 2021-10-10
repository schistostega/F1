public with sharing class FormulaOneDAO {
    public Driver__c getDriver(Id driverId) {
        // return Driver__c object where Id == driverId
        String allFields = ApexUtility.getAllFieldsOfObject('Driver__c');
        String query = 'SELECT ' + allFields + ' FROM Driver__c where Id=:driverId limit 1';
        return Database.query(query);
    }

    public List<Race_Result__c> getRaceResults(Id driverId) {
        // return List of Race_Result__c objects, where Driver__c equal driverId
        String allFields = ApexUtility.getAllFieldsOfObject('Race_Result__c');
        String query = 'SELECT ' + allFields + ' FROM Race_Result__c where Racer__c = :driverId';
        return Database.query(query);
    }

    public Set<String> getDriverCircuits(Id driverId) {
        // return Set of Names for Race__c obects where Driver with Id == driverId participated
        Race__c[] races = [SELECT Name 
                           FROM Race__c 
                           WHERE Id IN (SELECT Grand_Prix__c 
                                        FROM Race_Result__c 
                                        WHERE Racer__c = :driverId)];

        Set<String> names = new Set<String>();
        for (Race__c race: races) {
            names.add(race.Name);
        }
        return names;
    }

    public Driver__c getYoungestDriverOnRace(Id raceId) {
        // Get youngest drive for specified race
        String allFields = ApexUtility.getAllFieldsOfObject('Driver__c');
        String query = 'SELECT ' + allFields + ' FROM Driver__c WHERE Id IN (SELECT Racer__c FROM Race_Result__c WHERE Grand_Prix__c = :raceId) ORDER BY Age__c limit 1';
        return Database.query(query);
    }

    public Map<String, String[]> getAllDriversByCircuit() {
        // return Map where:
        // String - Race__c.Name,
        // List<String> - list of Full Names for drivers that participated the Race
        Race__c[] races = [SELECT Id FROM Race__c];
        Map<String, String[]> raceDriversMap = new Map<String, String[]>();

        for (Race__c race: [SELECT Id, Name FROM Race__c]) {
            Driver__c[] drivers = [SELECT Full_Name__c 
                                   FROM Driver__c 
                                   WHERE Id IN (SELECT Racer__c 
                                                FROM Race_Result__c 
                                                WHERE Grand_Prix__c = :race.Id)];
                                                
            String[] fullNames = new List<String>();
            for (Driver__c driver: drivers) {
                fullNames.add(driver.Full_Name__c);
            }

            raceDriversMap.put(race.Name, fullNames);
        }

        return raceDriversMap;
    }
}
