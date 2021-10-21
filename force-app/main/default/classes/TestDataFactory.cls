@isTest
public class TestDataFactory {
    public static void createDriversAndRacesWithResults(Integer numDrivers, Integer numRaces) {
        List<Driver__c> drivers = new List<Driver__c>();
        for (Integer i = 0; i < numDrivers; i++) {
            drivers.add(new Driver__c(
                First_Name__c = 'Test_' + i,
                Last_Name__c = 'Driver',
                Age__c = TestDataFactory.getRandomInteger(18, 50)
            ));
        }
        insert drivers;

        List<Race__c> races = new List<Race__c>();
        for (Integer i = 0; i < numRaces; i++) {
            races.add(new Race__c(
                Name = 'Race_' + i,
                Date__c = TestDataFactory.getRandomDate(),
                Track__c = TestDataFactory.getRandomTrack(),
                Laps__c = TestDataFactory.getRandomInteger(1, 6)
            ));
        }
        insert races;

        List<Race_Result__c> results = new List<Race_Result__c>();
        for (Integer raceIndex = 0; raceIndex < numRaces; raceIndex++) {
            for (Integer driverIndex = 0; driverIndex < numDrivers; driverIndex++) {
                results.add(new Race_Result__c(
                    Name = 'Result ' + drivers.get(driverIndex).Full_Name__c,
                    Grand_Prix__c = races.get(raceIndex).Id,
                    Racer__c = drivers.get(driverIndex).Id,
                    Position__c = driverIndex + 1,
                    Grid__c = driverIndex + 1,
                    Is_Fastest_Lap__c = driverIndex + 1 == 1 ? true : false
                ));
            }
        }
        insert results;
    }

    private static String getRandomTrack() {
        List<String> tracks = new List<String> {
            'AVUS', 'Circuit de Monaco', 'Mosport Park'
        };
        return tracks.get(getRandomInteger(0, tracks.size() - 1));
    }

    private static Date getRandomDate() {
        Date minDate = date.newInstance(2015, 1, 1);
        Date maxDate = date.newInstance(2021, 1, 1);
        Integer rangeSize = minDate.daysBetween(maxDate) + 1;
        Decimal daysToAdd = rangeSize * math.Random();
        Date result = minDate.addDays(daysToAdd.intValue());
        return result;
    }

    private static Integer getRandomInteger(Integer min, Integer max) {
        return Integer.valueOf(Math.random() * (max + 1 - min) + min);
    }
}
