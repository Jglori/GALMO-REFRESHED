@IsTest
public class ExtratoTabelaServiceTest {
    
    @TestSetup
    static void makeData(){
        TabelaVendas__c tabela = new TabelaVendas__c();
        tabela.Name = 'Teste'; 
        tabela.PeriodicidadeParcelaPos__c = 1;
        tabela.PeriodicidadeParcela__c = 1;
        insert tabela;

        SeriePagamentos__c serie =  new SeriePagamentos__c(); 
        serie.Name = 'Teste'; 
        serie.InicioPagamento__c = 1; 
        serie.QuantidadeParcelas__c = 1; 
        serie.ValorTotal__c = 1;
        serie.TabelaVenda__c = tabela.Id; 
        serie.TipoCondicao__c = 'Ato'; 
        serie.AposHabiteSe__c = false;
        insert serie;

        SeriePagamentos__c serie2 = new SeriePagamentos__c();
        serie2.Name = 'Teste'; 
        serie2.InicioPagamento__c = 1; 
        serie2.QuantidadeParcelas__c = 1; 
        serie2.ValorTotal__c = 1;
        serie2.TabelaVenda__c = tabela.Id; 
        serie2.AposHabiteSe__c = false;
        serie2.TipoCondicao__c = 'Mensais';
        insert serie2;

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
    public static void testAnalisarProposta(){

        List<SeriePagamentos__c> series = [SELECT Id, Name,InicioPagamento__c, QuantidadeParcelas__c, ValorTotal__c, TabelaVenda__c, TipoCondicao__c, AposHabiteSe__c FROM SeriePagamentos__c];
        TabelaVendas__c tabela = [SELECT Id,Name FROM TabelaVendas__c LIMIT 1];
        Map<String, Object> valoresMatriz = new Map<String, Object>{
            'nominalProposta' => 100000, 
            'nominalTabela' => 200000, 
            'vplProposta' => 80000, 
            'valorVplTabela' => 160000
        };
        ConjuntoCriteriosAnalise__c conjuntoCriterios = [
            SELECT Id, valorNominal__c, VariacaoLimiteValorNominal__c, ValorVpl__c, VariacaoLimiteValorVPL__c, ValorMetro__c, VariacaoLimiteMetro__c, PrazoFinanciamento__c, VariacaoLimitePrazoFinanciamento__c, CaptacaoVista__c, VariacaoLimiteCaptacaoVista__c, CaptacaoPosHabitaSe__c, VariacaoLimiteCaptacaoPos__c, CaptacaoMensal__c, VariacaoLimiteCaptacaoMensal__c
            FROM ConjuntoCriteriosAnalise__c
            LIMIT 1
        ];

        Test.startTest();
        List<Object> retorno = ExtratoTabelaService.analisarProposta(tabela.id, series, valoresMatriz, conjuntoCriterios);
        Test.stopTest();

        Assert.areEqual(true, (retorno.size() > 0), 'A lista não pode estar vazia');
    }

    @IsTest
    public static void testHandleCriterios() {
        Test.startTest();
        Boolean result = ExtratoTabelaService.handleCriterios((Double) 600.0, (Double) 500.0, (Double) 60.0, 'Abaixo do limite');
        Test.stopTest();

        // True pois não deve bloquear com base nos criterios. se não for abaixo do limite não deve bloquear
        Boolean expected = true;

        System.assertEquals(expected, result, 'Deveria ter retonado true');
    }

    @IsTest
    public static void testHandleCriteriosPorcentagem() {
        Test.startTest();
        Boolean result = ExtratoTabelaService.handleCriteriosPorcentagem((Double) 10000.0, (Double) 5000.0, (Double) 60.0, 'Abaixo do limite');
        Test.stopTest();

        // False pois deve bloquear com base nos criterios. se for abaixo do limite deve bloquear
        Boolean expected = false;

        System.assertEquals(expected, result, 'Deveria ter retonado false');
    }



}