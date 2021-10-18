trigger RaceResult on Race_Result__c (before insert, before update) {
    RaceResultTriggerHandler handler = new RaceResultTriggerHandler(Trigger.New);

    handler.checkPositionAndDriverDuplicity();
}
