public with sharing class ParametrizarCriteriosController {
    @AuraEnabled(cacheable=true)
    public static List<String> getVariacoesLimite(){
        return ParametrizarCriteriosService.getVariacoesLimite();
    }

    @AuraEnabled
    public static void criarConjuntoCriterios(Object conjunto){
        System.debug('conjunto' + conjunto);
        ParametrizarCriteriosService.criarConjuntoCriterios(conjunto);
    }

    @AuraEnabled
    public static List<Decimal> testarConjuntoCriterios(Decimal valorTabela, Decimal valorProposta){
        return ParametrizarCriteriosService.testarConjuntoCriterios(valorTabela, valorProposta);
    }

    @AuraEnabled
    public static ConjuntoCriteriosAnalise__c getConjuntoCriteriosAnaliseById(Id id){
        try {
            return ParametrizarCriteriosService.getConjuntoCriteriosAnaliseById(id);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}