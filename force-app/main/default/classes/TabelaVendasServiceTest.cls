@isTest
public class TabelaVendasServiceTest {
    @TestSetup
    static void makeData(){
        Account contaParaContato = TestDataFactorySimulador.gerarConta('HouseImobiliaria');
        insert contaParaContato;
        
        Account contaParaOportunidade = TestDataFactorySimulador.gerarConta();
        insert contaParaOportunidade;

        Id recordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Corretor').getRecordTypeId();
        Contact contato = TestDataFactorySimulador.gerarContato(contaParaContato, recordTypeId);
        insert contato;

        Opportunity oportunidade = TestDataFactorySimulador.gerarOportunidade(contaParaOportunidade, contato);
        insert oportunidade;

        Quote cotacao = TestDataFactorySimulador.gerarCotacao(oportunidade);
        insert cotacao;

        Empreendimento__c empreendimento = TestDataFactorySimulador.gerarEmpreendimento();
        insert empreendimento;

        TabelaVendas__c tabela = TestDataFactorySimulador.gerarTabelaVendasCotacao(cotacao);
        tabela.Empreendimento__c = empreendimento.id;
        insert tabela;

        SeriePagamentos__c seriesTabela = TestDataFactorySimulador.gerarSeriePagamento(tabela.Id);
        insert seriesTabela;

        Product2 produto = TestDataFactorySimulador.gerarProduto();
        produto.Empreendimento__c = empreendimento.id;
        insert produto;

        UnidadeTabelaVendas__c unidadeTabela = TestDataFactorySimulador.gerarUnidadeTabelaVendas(tabela.id);
        unidadeTabela.Unidade__c = produto.id;
        insert unidadeTabela;
    }

    @isTest
    public static void testCriarTabelaDaSimulacao(){
        
        Quote cotacao = [SELECT Id, Name FROM Quote LIMIT 1];
        TabelaVendas__c tabelaSelecionada = [SELECT id, PeriodicidadeParcelaPos__c, PeriodicidadeParcela__c FROM TabelaVendas__c LIMIT 1];
        Product2 unidade = [SELECT id FROM Product2 LIMIT 1];
        List<SeriePagamentos__c> seriesProposta = new List<SeriePagamentos__c>();
        SeriePagamentos__c serie = TestDataFactorySimulador.gerarSeriePagamento(tabelaSelecionada.Id);
        seriesProposta.add(serie);
        Test.startTest();
        Id resultado = TabelaVendasService.criarTabelaDaSimulacao(seriesProposta, cotacao.Id, cotacao.Name, tabelaSelecionada, unidade.Id, 3000.00);
        Test.stopTest();

        Assert.areEqual(false, resultado == null, 'A id não pode ser null');
    }

    
    @isTest
    public static void testInserirUnidadesTabelas(){
        List<TabelaVendas__c> tabelas = [SELECT id, Empreendimento__c, AcrescimoValorTotal__c FROM tabelaVendas__c ];

        Test.startTest();
        TabelaVendasService.inserirUnidadesTabelas(tabelas);
        Test.stopTest();
    }
}