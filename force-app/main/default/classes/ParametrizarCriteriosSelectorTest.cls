@IsTest
public with sharing class ParametrizarCriteriosSelectorTest {
    
    @TestSetup
    static void setup() {
        ConjuntoCriteriosAnalise__c conjuntoCriterios = new ConjuntoCriteriosAnalise__c();
        conjuntoCriterios.valorNominal__c = 12.0;
        conjuntoCriterios.VariacaoLimiteValorNominal__c = 'Acima do limite';
        conjuntoCriterios.ValorVpl__c = 10.0;
        conjuntoCriterios.VariacaoLimiteValorVPL__c = 'Acima do limite';
        conjuntoCriterios.ValorMetro__c = 11.0;
        conjuntoCriterios.VariacaoLimiteMetro__c = 'Abaixo do limite';
        conjuntoCriterios.PrazoFinanciamento__c = 0.0;
        conjuntoCriterios.VariacaoLimitePrazoFinanciamento__c = 'Não for igual';
        conjuntoCriterios.CaptacaoVista__c = 11.0;
        conjuntoCriterios.VariacaoLimiteCaptacaoVista__c = 'Acima do limite';
        conjuntoCriterios.CaptacaoPosHabitaSe__c = 0.0;
        conjuntoCriterios.VariacaoLimiteCaptacaoPos__c = 'Não for igual';
        conjuntoCriterios.CaptacaoMensal__c = 0.0;
        conjuntoCriterios.VariacaoLimiteCaptacaoMensal__c = 'Não for igual';
        insert conjuntoCriterios;
    }

    @IsTest
    public static void testGetConjuntoCriteriosAnaliseById() {
        ConjuntoCriteriosAnalise__c conjunto = [
            SELECT Id FROM ConjuntoCriteriosAnalise__c LIMIT 1
        ];

        Test.startTest();
        ConjuntoCriteriosAnalise__c result = ParametrizarCriteriosSelector.getConjuntoCriteriosAnaliseById(conjunto.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Não deveria ser null');
    }

    @IsTest
    public static void testGetConjuntoCriteriosAnaliseById_Invalid() {
        ConjuntoCriteriosAnalise__c conjunto = [
            SELECT Id FROM ConjuntoCriteriosAnalise__c LIMIT 1
        ];
        String conjuntoId = String.valueOf(conjunto.Id).substring(0, 2) + 3 + String.valueOf(conjunto.Id).substring(3);

        Test.startTest();
        ConjuntoCriteriosAnalise__c result = ParametrizarCriteriosSelector.getConjuntoCriteriosAnaliseById(conjuntoId);
        Test.stopTest();

        System.assertEquals(null, result, 'Deveria ser null');
    }
}