public class PersonAccountTriggerHandler {

    public static void validateMaritalStatus(List<Account> accList) {
        Set<String> marriedStatuses = new Set<String>{
            'Casado(a) (União estável)',
            'Casado(a) (Separação total)',
            'Casado(a) (Comunhão total)',
            'Casado(a) (Comunhão parcial)'
        };

        for (Account acc : accList) {
            if (marriedStatuses.contains(acc.EstadoCivil__pc)) {
                Boolean wasPreviouslyMarried = false;

                if (Trigger.isUpdate) {
                    // Fazendo cast explícito para o tipo Account
                    Account oldAcc = (Account) Trigger.oldMap.get(acc.Id);
                    wasPreviouslyMarried = marriedStatuses.contains(oldAcc.EstadoCivil__pc);
                }

                if (!wasPreviouslyMarried) {
                    List<AccountContactRelation> relations = [
                        SELECT Id FROM AccountContactRelation
                        WHERE AccountId = :acc.Id AND Relacionamento__c = 'Cônjuge/Companheiro'
                    ];

                    if (relations.isEmpty()) {
                        acc.EstadoCivil__pc.addError('Para definir o Estado Civil como "Casado", é necessário ter um Contato Relacionado com o campo "Relacionamento" marcado como "Cônjuge/Companheiro".');
                    }
                }
            }
        }
    }
}