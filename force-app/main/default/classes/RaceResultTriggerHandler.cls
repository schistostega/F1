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
                    resultNew.addError(message);
                }

                if (resultNew.Racer__c == result.Racer__c && resultNew.Id != result.Id) {
                    String message = 'Duplicaton detected! Racer ' + result.Racer__r.Full_Name__c + 
                                    ' in race ' + result.Grand_Prix__r.Name + ' already exists.';
                    resultNew.addError(message);
                }
            }
        }
    }
}
