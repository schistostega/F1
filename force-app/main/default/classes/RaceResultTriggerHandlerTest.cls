@isTest
private class RaceResultTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createDriversAndRacesWithResults(4, 2);
    }

    @isTest
    static void checkPositionAndDriverPostionDuplicityNegativeTest() {
        Race__c race = [
            SELECT Id, Name, (SELECT Position__c FROM Race_Results__r ORDER BY Position__c LIMIT 4)
            FROM Race__c 
            LIMIT 1
        ];

        Race_Result__c[] resultsToInsert = new List<Race_Result__c>();
        for (Integer i = 0; i < 5; i++) {
            resultsToInsert.add(new Race_Result__c(
                Name = 'Test Result ' + i,
                Position__c = 1, // already exists in test setup
                Grand_Prix__c = race.Id
            ));
        }
        
        Race_Result__c[] resultsToUpdate = new List<Race_Result__c>();
        for (Race_Result__c result : race.Race_Results__r) {
            // result with original position 1 will be successfully updated
            if (result.Position__c != 1) {
                result.Position__c = 1;
                resultsToUpdate.add(result);
            }
        }

        Race_Result__c[] resultsToUpsert = new List<Race_Result__c>();
        resultsToUpsert.addAll(resultsToInsert);
        resultsToUpsert.addAll(resultsToUpdate);

        Test.startTest();
        Database.SaveResult[] saveResult = Database.insert(resultsToInsert, false);
        Database.SaveResult[] updateResult = Database.update(resultsToUpdate, false);
        Database.UpsertResult[] upsertResult = Database.upsert(resultsToUpsert, false);
        Test.stopTest();

        String errMessage = 'Duplicaton detected! Position 1 in race ' + race.Name + ' already exists.';
        for (Database.SaveResult dbResult : saveResult) {
            System.assertEquals(false, dbResult.isSuccess());
            System.assert(dbResult.getErrors().size() > 0);
            System.assertEquals(errMessage, dbResult.getErrors()[0].getMessage());
        }

        for (Database.SaveResult dbResult : updateResult) {
            System.assertEquals(false, dbResult.isSuccess());
            System.assert(dbResult.getErrors().size() > 0);
            System.assertEquals(errMessage, dbResult.getErrors()[0].getMessage());
        }

        for (Database.UpsertResult dbResult : upsertResult) {
            System.assertEquals(false, dbResult.isSuccess());
            System.assert(dbResult.getErrors().size() > 0);
            System.assertEquals(errMessage, dbResult.getErrors()[0].getMessage());
        }
    }

    @isTest
    static void updateHatTricksOnRacerTest() {
        Race_Result__c result = [
            SELECT Racer__r.Hat_Tricks__c 
            FROM Race_Result__c
            WHERE Position__c=1 AND Is_Fastest_Lap__c=true
            LIMIT 1
        ];
        Id driverId = result.Racer__r.Id;
        Decimal hatTricks = result.Racer__r.Hat_Tricks__c;

        Test.startTest();
        Database.DeleteResult deleteResult = Database.delete(result, false);
        Test.stopTest();

        System.assert(deleteResult.isSuccess());
        System.assert(deleteResult.getErrors().size() == 0);

        Driver__c driver = [SELECT Hat_Tricks__c FROM Driver__c WHERE Id = :driverId];
        System.assertEquals(hatTricks - 1, driver.Hat_Tricks__c);
    }
}
