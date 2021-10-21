@isTest
private class RaceResultTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createDriversAndRacesWithResults(4, 2);
    }

    @isTest
    static void checkPositionAndDriverPostionDuplicityNegativeTest() {
        Race__c race = [
            SELECT Id, Name, (SELECT Position__c FROM Race_Results__r ORDER BY Position__c LIMIT 2)
            FROM Race__c 
            LIMIT 1
        ];
        Race_Result__c resultToInsert = new Race_Result__c(
            Name = 'Test Result',
            Position__c = 1, // already exists
            Grand_Prix__c = race.Id
        );
        Race_Result__c resultToUpdate = race.Race_Results__r.get(1);
        resultToUpdate.Position__c = 1;

        Test.startTest();
        Database.SaveResult saveResult = Database.insert(resultToInsert, false);
        Database.SaveResult updateResult = Database.update(resultToUpdate, false);
        Test.stopTest();

        System.assert(!saveResult.isSuccess());
        System.assert(!updateResult.isSuccess());
        System.assert(saveResult.getErrors().size() > 0);
        System.assert(updateResult.getErrors().size() > 0);

        String errMessage = 'Duplicaton detected! Position 1 in race ' + race.Name + ' already exists.';
        System.assertEquals(errMessage, saveResult.getErrors()[0].getMessage());
        System.assertEquals(errMessage, updateResult.getErrors()[0].getMessage());
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
