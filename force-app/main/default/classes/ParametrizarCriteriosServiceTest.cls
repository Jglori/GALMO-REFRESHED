@isTest
public with sharing class ParametrizarCriteriosServiceTest {
    
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

    @isTest
    public static void testGetVariacoesLimite(){

        Test.startTest();
        List<String> retorno = ParametrizarCriteriosService.getVariacoesLimite();
        Test.stopTest();

        Assert.areEqual(true, retorno.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }

    @isTest
    public static void testCriarConjuntoCriterios(){
        String objectJson = '{"nominal":10, "nominalVariacao":"Abaixo do limite"}';

        Object obj = JSON.deserializeUntyped(objectJson);

        test.startTest();
        ParametrizarCriteriosService.criarConjuntoCriterios(obj);
        test.stopTest();

        ConjuntoCriteriosAnalise__c criterio = [SELECT Id, valorNominal__c FROM ConjuntoCriteriosAnalise__c LIMIT 1];

        Assert.areEqual(10, criterio.valorNominal__c, 'O valores nominais devem ser iguais.');
    }

    @isTest
    public static void testTestarConjuntoCriterios(){
        Decimal valorTabela = 100;
        Decimal valorProposta = 80;

        Test.startTest();
        List<Double> retorno = ParametrizarCriteriosService.testarConjuntoCriterios(valorTabela, valorProposta);
        Test.stopTest();

        Assert.areEqual(20, retorno[0], 'A diferença entre os valores deve ser 20.');
    }

    @isTest
    public static void testGetConjuntoCriteriosAnaliseById() {
        ConjuntoCriteriosAnalise__c conjunto = [
            SELECT Id FROM ConjuntoCriteriosAnalise__c LIMIT 1
        ];

        Test.startTest();
        ConjuntoCriteriosAnalise__c result = ParametrizarCriteriosService.getConjuntoCriteriosAnaliseById(conjunto.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Não deveria retornar null');
    }
}