public with sharing class ParametrizarCriteriosSelector {
    
    public static ConjuntoCriteriosAnalise__c getConjuntoCriteriosAnaliseById(Id id) {
        if (id == null) return null;

        List<ConjuntoCriteriosAnalise__c> conjunto = [
            SELECT Id, valorNominal__c, VariacaoLimiteValorNominal__c, ValorVpl__c, VariacaoLimiteValorVPL__c, ValorMetro__c, VariacaoLimiteMetro__c, PrazoFinanciamento__c, VariacaoLimitePrazoFinanciamento__c, CaptacaoVista__c, VariacaoLimiteCaptacaoVista__c, CaptacaoPosHabitaSe__c, VariacaoLimiteCaptacaoPos__c, CaptacaoMensal__c, VariacaoLimiteCaptacaoMensal__c
            FROM ConjuntoCriteriosAnalise__c
            WHERE Id = :id
        ];

        if (conjunto.isEmpty()) return null;
        return conjunto[0];
    }
}