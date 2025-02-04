trigger GaragemTrigger on Garagem__c (before insert, before update) {
	new GaragemTriggerHandler().run();
}