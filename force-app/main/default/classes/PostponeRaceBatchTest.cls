@isTest
public class PostponeRaceBatchTest {
    @TestSetup
    static void makeData(){
        List<Race__c> races = new List<Race__c>();
        for (Integer i = 1; i < 5; i++) {
            races.add(new Race__c(
                Name = 'Race_' + i,
                Date__c = Date.newInstance(2021, i, 8),
                Track__c = 'Circuit de Monaco',
                Laps__c = 4
            ));
        }
        insert races;
    }

    @isTest
    static void testBatch() {
        Test.setMock(HttpCalloutMock.class, new MockHttp());

        Test.startTest();
        PostponeRaceBatch batch = new PostponeRaceBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        Race__c[] races = [SELECT Date__c FROM Race__c ORDER BY Date__c];
        System.assertEquals(2, races[0].Date__c.month());
        System.assertEquals(3, races[1].Date__c.month());
        System.assertEquals(4, races[2].Date__c.month());
        System.assertEquals(5, races[3].Date__c.month());
    }
}
