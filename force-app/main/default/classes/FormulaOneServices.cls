public with sharing class FormulaOneServices {
    public String generateKey(SObject record, List<SObjectField> fields, String separator) {
        List<Object> values = new List<Object>();
        for (SObjectField field: fields) {
            Object value = record.get(field);
            values.add(value);
        }

        return values.toString().replace(', ', separator);
    }

    public Boolean isHatTrick(Race_Result__c raceResult) {
        return raceResult.Position__c == 1 && 
               raceResult.Grid__c == 1 && 
               raceResult.Is_Fastest_Lap__c == true;
    }
}
