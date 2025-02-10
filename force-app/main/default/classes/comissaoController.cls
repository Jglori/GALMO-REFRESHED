public class comissaoController {
    @AuraEnabled
    public static List<Object> analisarProposta(Id tabelaId, List<SeriePagamentos__c> proposta, Map<String, Object> valoresMatriz, ConjuntoCriteriosAnalise__c conjuntoCriterios){
        List<Object> resultado = ExtratoTabelaService.analisarProposta(tabelaId, proposta, valoresMatriz, conjuntoCriterios);
        return resultado;
    }
}