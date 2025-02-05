public class AccountContactRelationTriggerHandler {
    public static void validateSpouseRelationship(List<SObject> sObjectList) {
        // Realiza o cast para AccountContactRelation
        List<AccountContactRelation> acrList = (List<AccountContactRelation>) sObjectList;

        Map<Id, Integer> accountSpouseCount = new Map<Id, Integer>();

        // Conta o número de registros existentes por conta com relacionamento marcado como "Cônjuge/Companheiro"
        for (AccountContactRelation acr : [
            SELECT AccountId, Relacionamento__c 
            FROM AccountContactRelation 
            WHERE Relacionamento__c = 'Cônjuge/Companheiro'
        ]) {
            if (!accountSpouseCount.containsKey(acr.AccountId)) {
                accountSpouseCount.put(acr.AccountId, 0);
            }
            accountSpouseCount.put(acr.AccountId, accountSpouseCount.get(acr.AccountId) + 1);
        }

        // Verifica os registros sendo processados no Trigger
        for (AccountContactRelation acr : acrList) {
            if (acr.Relacionamento__c == 'Cônjuge/Companheiro') {
                Integer existingCount = accountSpouseCount.get(acr.AccountId);
                if (existingCount == null) {
                    existingCount = 0;
                }

                if (existingCount >= 1) {
                    acr.Relacionamento__c.addError('Apenas um contato relacionado pode ter o relacionamento "Cônjuge/Companheiro" por conta.');
                } else {
                    accountSpouseCount.put(acr.AccountId, existingCount + 1);
                }
            }
        }
    }

    public static void ensureReciprocalRelationships(List<AccountContactRelation> acrList) {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, AccountContactRelation> existingReciprocalRelations = new Map<Id, AccountContactRelation>();

        // Coleta ContactIds para verificar relacionamentos recíprocos existentes
        for (AccountContactRelation acr : acrList) {
            if (acr.ContactId != null) {
                contactIds.add(acr.ContactId);
            }
        }

        // Busca relacionamentos recíprocos existentes
        if (!contactIds.isEmpty()) {
            for (AccountContactRelation existingRelation : [
                SELECT Id, AccountId, ContactId, Relacionamento__c
                FROM AccountContactRelation
                WHERE ContactId IN :contactIds
                  AND Relacionamento__c = 'Cônjuge/Companheiro'
            ]) {
                existingReciprocalRelations.put(existingRelation.ContactId, existingRelation);
            }
        }

        List<AccountContactRelation> recordsToInsert = new List<AccountContactRelation>();

        // Cria relacionamentos recíprocos
        for (AccountContactRelation acr : acrList) {
            if (acr.Relacionamento__c == 'Cônjuge/Companheiro' && acr.ContactId != null) {
                // Obtém o relacionamento recíproco para o contato relacionado
                AccountContactRelation reciprocal = existingReciprocalRelations.get(acr.ContactId);

                if (reciprocal == null) {
                    // Se o relacionamento recíproco não existir, cria um novo relacionamento
                    recordsToInsert.add(new AccountContactRelation(
                        AccountId = acr.ContactId,    // A Conta da pessoa com quem o contato é relacionado
                        ContactId = acr.AccountId,    // A Conta atual
                        Relacionamento__c = 'Cônjuge/Companheiro'
                    ));
                }
            }
        }

        // Insere os relacionamentos recíprocos
        if (!recordsToInsert.isEmpty()) {
            try {
                insert recordsToInsert;
            } catch (Exception e) {
                System.debug('Erro ao inserir relacionamentos recíprocos: ' + e.getMessage());
            }
        }
    }
}