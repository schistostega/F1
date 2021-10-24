public with sharing class DriverRatingServerController {
    @AuraEnabled
    public static List<Driver__c> getTop5Drivers(){
        return [
            SELECT Full_Name__c, Hat_Tricks__c, Age__c, Is_Qualified__c
            FROM Driver__c
            ORDER BY Hat_Tricks__c DESC
            LIMIT 5
        ];
    }
}