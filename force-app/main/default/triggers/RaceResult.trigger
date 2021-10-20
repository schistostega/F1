trigger RaceResult on Race_Result__c (before insert, before update, after insert, after update, after delete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            RaceResultTriggerHandler.checkPositionAndDriverDuplicity(Trigger.New);
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            RaceResultTriggerHandler.updateHatTricksOnRacer(Trigger.New);
        } else if (Trigger.isDelete) {
            RaceResultTriggerHandler.updateHatTricksOnRacer(Trigger.Old);
        }
    }
}
