@RestResource(urlMapping='/drivers/*')
global with sharing class DriverControllerREST {

    @HttpGet
    global static List<Driver__c> getFiveOldestDrivers() {
        return [
            SELECT Id, Full_Name__c, Age__c
            FROM Driver__c
            ORDER BY Age__c DESC
            LIMIT 5
        ];
    }
}
