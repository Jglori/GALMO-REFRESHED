@isTest
public class ComparativoServiceTest {
    
    @TestSetup
    static void makeData() {
        // Criação de um empreendimento de teste
        Empreendimento__c empreendimento = TestDataFactorySimulador.gerarEmpreendimento();
        empreendimento.MetragemPrivativaTotal__c = 100;
        insert empreendimento;

        // Criação de uma tabela de vendas associada ao empreendimento
        TabelaVendas__c tabela = TestDataFactorySimulador.gerarTabelaVendas();
        tabela.Empreendimento__c = empreendimento.Id;
        insert tabela;

        // Criação de uma série de pagamentos associada à tabela de vendas
        SeriePagamentos__c serie = TestDataFactorySimulador.gerarSeriePagamento(tabela.Id);
        serie.QuantidadeParcelas__c = 10;
        serie.ValorTotal__c = 100000;
        //serie.TipoCondicao__c = 'Padrão';
        insert serie;
    }
    
    @isTest
    public static void testCalcularComparacao() {
        // Verifica se há registros antes de executar o teste
        List<TabelaVendas__c> tabelas = [SELECT Id, Name FROM TabelaVendas__c];
        System.assert(!tabelas.isEmpty(), 'Nenhuma Tabela de Vendas encontrada. Certifique-se de que os dados de teste foram inseridos.');
        
        TabelaVendas__c tabela = tabelas[0];
        
        List<SeriePagamentos__c> series = [SELECT Id, Name, InicioPagamento__c, QuantidadeParcelas__c, ValorTotal__c, TabelaVenda__c, TipoCondicao__c, AposHabiteSe__c FROM SeriePagamentos__c];
        System.assert(!series.isEmpty(), 'Nenhuma Série de Pagamento encontrada. Certifique-se de que os dados de teste foram inseridos.');
        
        Map<String, Object> valoresMatriz = new Map<String, Object>{
            'nominalProposta' => 100000, 
            'nominalTabela' => 200000, 
            'valorVplProposta' => 80000
        };
        
        Test.startTest();
        List<ComparativoService.ComparacaoResultado> comparativo = ComparativoService.calcularComparacao(tabela.Id, series, valoresMatriz);
        Test.stopTest();
    
        // Validação do resultado
        System.assert(comparativo.size() > 0, 'O comparativo não pode estar vazio.');
    }
}