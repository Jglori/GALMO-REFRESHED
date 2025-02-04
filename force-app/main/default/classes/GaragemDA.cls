public with sharing class GaragemDA {
	public static Map<Id, Garagem__c> getGaragens(Set<Id> garagemIds) {
		if(garagemIds.isEmpty()) return new Map<Id, Garagem__c>();

		return new Map<Id, Garagem__c> (
			[SELECT Id, NumeroVagas__c FROM Garagem__c WHERE Id IN :garagemIds]
		);
	}
	
	public static Integer getQuantityVagasGaragem(Id garagemId) {
        List<AggregateResult> result = [SELECT COUNT(Id) numVagas FROM Product2  WHERE Garagem__c = :garagemId WITH SECURITY_ENFORCED];
		return result[0].get('numVagas') == null ? 0 : Integer.valueOf(result[0].get('numVagas') + '');
	}
}