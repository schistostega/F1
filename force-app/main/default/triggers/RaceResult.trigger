trigger RaceResult on Race_Result__c (before insert, before update, after insert, after update) {
    RaceResultTriggerHandler handler = new RaceResultTriggerHandler(Trigger.New);

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            handler.checkPositionAndDriverDuplicity();
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            handler.updateHatTricksOnRacer();
        }
    }
}
