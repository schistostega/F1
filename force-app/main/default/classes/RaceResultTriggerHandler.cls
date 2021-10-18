public class RaceResultTriggerHandler {
    List<Race_Result__c> resultsNew;

    public RaceResultTriggerHandler(List<Race_Result__c> resultsNew) {
        this.resultsNew = resultsNew;
    }

    public void checkPositionAndDriverDuplicity() {
        Set<Id> raceIds = new Set<Id>();

        for (Race_Result__c result: this.resultsNew) {
            raceIds.add(result.Grand_Prix__c);
        }

        Race_Result__c[] results = [
            SELECT Grand_Prix__r.Name, Racer__r.Full_Name__c, Position__c
            FROM Race_Result__c 
            WHERE Grand_Prix__c IN :raceIds
        ];

        Map<Id, List<Race_Result__c>> resultsPerRace = new Map<Id, List<Race_Result__c>>();
        for(Id raceId: raceIds) {
            resultsPerRace.put(raceId, new List<Race_Result__c>());
        }

        for (Race_Result__c result: results) {
            resultsPerRace.get(result.Grand_Prix__c).add(result);
        }

        for (Race_Result__c resultNew: this.resultsNew) {
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

    public void updateHatTricksOnRacer() {
        Set<Id> racerIds = new Set<Id>();
        for (Race_Result__c result: this.resultsNew) {
            if (result.Racer__c != null) {
                racerIds.add(result.Racer__c);
            }
        }

        Race_Result__c[] results = [
            SELECT Racer__r.Hat_Tricks__c, Is_Fastest_Lap__c, Position__c 
            FROM Race_Result__c 
            WHERE Racer__c IN :racerIds
        ];
        Driver__c[] drivers = [SELECT Id, Hat_Tricks__c FROM Driver__c WHERE Id IN :racerIds];

        Map<Id, List<Race_Result__c>> resultsPerRacer = new Map<Id, List<Race_Result__c>>();
        for (Id racerId: racerIds) {
            resultsPerRacer.put(racerId, new List<Race_Result__c>());
        }

        for (Race_Result__c result: results) {
            resultsPerRacer.get(result.Racer__c).add(result);
        }

        for (Driver__c driver: drivers) {
            Integer hatTricks = 0;

            for (Race_Result__c result: resultsPerRacer.get(driver.Id)) {
                if (result.Is_Fastest_Lap__c == true && result.Position__c == 1) {
                    hatTricks++;
                }
            }

            driver.Hat_Tricks__c = hatTricks;
        }

        update drivers;
    }
}
