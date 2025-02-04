trigger PersonAccountTrigger on Account (before insert, before update) {
    PersonAccountTriggerHandler.validateMaritalStatus(Trigger.new);
}