public class PostponeRaceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Date__c FROM Race__c WHERE Status__c = \'Active\''
        );
    }

    public void execute(Database.BatchableContext cd, List<Race__c> scope) {
        for (Race__c race : scope) {
            race.Date__c = race.Date__c.addMonths(1);
        }

        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];
        
        TelegramUtils.sendMessage('Batch task complete. Details:\n\n' + JSON.serializePretty(job));
    }
}
