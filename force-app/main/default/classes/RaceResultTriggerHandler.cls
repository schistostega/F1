public class RaceResultTriggerHandler {
    public static void checkPositionAndDriverDuplicity(List<Race_Result__c> resultsNew) {
        Set<Id> raceIds = new Set<Id>();

        for (Race_Result__c result: resultsNew) {
            raceIds.add(result.Grand_Prix__c);
        }

        Race_Result__c[] results = [
            SELECT Grand_Prix__r.Name, Racer__r.Full_Name__c, Position__c
            FROM Race_Result__c 
            WHERE Grand_Prix__c IN :raceIds
        ];

        Map<Id, List<Race_Result__c>> resultsPerRace = new Map<Id, List<Race_Result__c>>();
        for (Race_Result__c result: results) {
            if (resultsPerRace.containsKey(result.Grand_Prix__c)) {
                resultsPerRace.get(result.Grand_Prix__c).add(result);
            } else {
                resultsPerRace.put(result.Grand_Prix__c, new List<Race_Result__c>{result});
            }
        }

        for (Race_Result__c resultNew: resultsNew) {
            for (Race_Result__c result: resultsPerRace.get(resultNew.Grand_Prix__c)) {
                if (resultNew.Position__c == result.Position__c && resultNew.Id != result.Id) {
                    String message = 'Duplicaton detected! Position ' + result.Position__c.format() + 
                                    ' in race ' + result.Grand_Prix__r.Name + ' already exists.';
                    resultNew.Position__c.addError(message);
                }

                if (resultNew.Racer__c == result.Racer__c && resultNew.Id != result.Id) {
                    String message = 'Duplicaton detected! Racer ' + result.Racer__r.Full_Name__c + 
                                    ' in race ' + result.Grand_Prix__r.Name + ' already exists.';
                    resultNew.Racer__c.addError(message);
                }
            }
        }
    }

    public static void updateHatTricksOnRacer(List<Race_Result__c> resultsAffected) {
        Set<Id> racerIds = new Set<Id>();
        for (Race_Result__c result: resultsAffected) {
            if (result.Racer__c != null) {
                racerIds.add(result.Racer__c);
            }
        }

        Driver__c[] drivers = [
            SELECT Id, Hat_Tricks__c, (SELECT Is_Fastest_Lap__c, Position__c FROM Race_Results__r) 
            FROM Driver__c 
            WHERE Id IN :racerIds
        ];
        Driver__c[] driversToUpdate = new List<Driver__c>();

        for (Driver__c driver: drivers) {
            Integer hatTricks = 0;

            for (Race_Result__c result: driver.Race_Results__r) {
                if (result.Is_Fastest_Lap__c == true && result.Position__c == 1) {
                    hatTricks++;
                }
            }

            if (driver.Hat_Tricks__c != hatTricks) {
                driver.Hat_Tricks__c = hatTricks;
                driversToUpdate.add(driver);
            }
        }

        if (!driversToUpdate.isEmpty()) {
            update driversToUpdate;
        }
    }
}
