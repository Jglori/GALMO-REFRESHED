trigger AccountContactRelationTrigger on AccountContactRelation (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            AccountContactRelationTriggerHandler.validateSpouseRelationship(Trigger.new);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            AccountContactRelationTriggerHandler.ensureReciprocalRelationships(Trigger.new);
        }
    }
}