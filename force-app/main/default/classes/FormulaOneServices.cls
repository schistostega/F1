public with sharing class FormulaOneServices {
    public static String generateKey(SObject record, List<SObjectField> fields, String separator) {
        List<Object> values = new List<Object>();
        for (SObjectField field: fields) {
            Object value = record.get(field);
            values.add(value);
        }

        String key = values.toString().replace(', ', separator);
        return key.substring(1, key.length() - 1); // strip '(' and ')'
    }

    public static Boolean isHatTrick(Race_Result__c raceResult) {
        return raceResult.Position__c == 1 && 
               raceResult.Grid__c == 1 && 
               raceResult.Is_Fastest_Lap__c == true;
    }

    public static void createDriver(String firstName, String lastName, Integer age) {
        Driver__c driver = new Driver__c();
        driver.First_Name__c = firstName;
        driver.Last_Name__c = lastName;
        driver.Age__c = age;

        insert driver;
    }

    public static void createDrivers(List<DriverDTO> driversDTO) {
        Driver__c[] drivers = new List<Driver__c>();

        for (DriverDTO dto: driversDTO) {
            Driver__c driver = new Driver__c();
            driver.First_Name__c = dto.firstName;
            driver.Last_Name__c = dto.lastName;
            driver.Age__c = dto.age;
            drivers.add(driver);
        }

        if (!drivers.isEmpty()) {
            insert drivers;
        }
    }

    public static Driver__c updateDriverName(Id driverId, String firstName, String lastName) {
        if (driverId == null) {
            throw new IllegalArgumentException('driverId must not be Null');
        }

        Driver__c driver = [SELECT Id, First_Name__c, Last_Name__c FROM Driver__c WHERE Id = :driverId LIMIT 1];
        driver.First_Name__c = firstName;
        driver.Last_Name__c = lastName;

        update driver;
        return driver;
    }

    public static Race__c[] updateGrandPrixWinners(Set<Id> raceIds) {
        Race_Result__c[] results = [
            SELECT Grand_Prix__r.Winner__c, Grand_Prix__r.Podium_Second__c, Grand_Prix__r.Podium_Third__c, Position__c, Racer__c
            FROM Race_Result__c
            WHERE Grand_Prix__r.Id IN :raceIds AND Position__c IN :new Set<Integer>{1, 2, 3}
        ];
        
        Map<Id, Race__c> races = new Map<Id, Race__c>();
        for (Race_Result__c result: results) {
            if (result.Position__c == 1) {
                result.Grand_Prix__r.Winner__c = result.Racer__c;
            } 
            else if (result.Position__c == 2) {
                result.Grand_Prix__r.Podium_Second__c = result.Racer__c;
            }
            else if (result.Position__c == 3) {
                result.Grand_Prix__r.Podium_Third__c = result.Racer__c;
            }
            races.put(result.Grand_prix__r.Id, result.Grand_prix__r);
        }

        update races.values();
        return races.values();
    }

    @AuraEnabled
    public static Race_Result__c[] getWinsOfDriver(Id driverId) {
        return [
            SELECT Id, Name, Position__c, Is_Fastest_Lap__c, Grand_Prix__r.Id, Grand_Prix__r.Name
            FROM Race_Result__c 
            WHERE Racer__c = :driverId AND Position__c = 1
            LIMIT 10
        ];
    }

    @AuraEnabled
    public static String getWeatherOnTrack(Id raceId) {
        Race__c race = [SELECT Track__c FROM Race__c WHERE Id = :raceId];

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://avenga-school.herokuapp.com/weather');
        req.setMethod('GET');
        req.setHeader('trackName', race.Track__c);

        HttpResponse resp = new Http().send(req);

        if (resp.getStatusCode() == 200) {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
            m.put('status', 'OK');
            m.put('statusCode', 200);

            return JSON.serialize(m);
        } else {
            return '{"status":"Network Error", "statusCode":502, "message": "Network error occurred. Try again later."}';
        }
        
    }
}
