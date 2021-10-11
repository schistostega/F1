public with sharing class FormulaOneDAO {
    public Driver__c getDriver(Id driverId, String[] fields) {
        // return Driver__c object where Id == driverId
        String query = 'SELECT ' + String.join(fields, ', ') + ' FROM Driver__c where Id=:driverId limit 1';
        return Database.query(query);
    }

    public List<Race_Result__c> getRaceResults(Id driverId, String[] raceResultFields) {
        // return List of Race_Result__c objects, where Driver__c equal driverId
        String query = 'SELECT ' + String.join(raceResultFields, ', ') + ' FROM Race_Result__c where Racer__c = :driverId';
        return Database.query(query);
    }

    public Set<String> getDriverCircuits(Id driverId) {
        // return Set of Names for Race__c obects where Driver with Id == driverId participated
        Race_Result__c[] results = [SELECT Grand_Prix__r.Name FROM Race_Result__c WHERE Racer__c = :driverId];
        Set<String> raceNames = new Set<String>();
        
        for (Race_Result__c result: results) {
            raceNames.add(result.Grand_Prix__r.Name);
        }

        return raceNames;
    }

    public Driver__c getYoungestDriverOnRace(Id raceId, String[] fields) {
        // Get youngest drive for specified race
        return Database.query(
            'SELECT ' + String.join(fields, ', ')
            + ' FROM Driver__c'
            + ' WHERE Id IN (SELECT Racer__c FROM Race_Result__c WHERE Grand_Prix__c = :raceId)'
            + ' ORDER BY Age__c'
            + ' LIMIT 1'
        );
    }

    public Map<String, String[]> getAllDriversByCircuit() {
        // return Map where:
        // String - Race__c.Name,
        // List<String> - list of Full Names for drivers that participated the Race
        Map<String, String[]> raceDriversMap = new Map<String, String[]>();
        Race_Result__c[] results = [SELECT Grand_Prix__r.Name, Racer__r.Full_Name__c FROM Race_Result__c];
        
        for (Race_Result__c result: results) {
            if (raceDriversMap.containsKey(result.Grand_Prix__r.Name)) {
                raceDriversMap
                    .get(result.Grand_Prix__r.Name)
                    .add(result.Racer__r.Full_Name__c);
            } else {
                raceDriversMap.put(
                    result.Grand_Prix__r.Name, 
                    new List<String>{result.Racer__r.Full_Name__c}
                );
            }
        }

        return raceDriversMap;
    }
}
