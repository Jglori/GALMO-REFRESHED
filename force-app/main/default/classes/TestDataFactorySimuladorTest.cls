@isTest
private class TestDataFactorySimuladorTest {
    @isTest
    static void testGerarConta() {
        Account conta = TestDataFactorySimulador.gerarConta();
        System.assertNotEquals(null, conta, 'Conta não deve ser nula');
        System.assertEquals('Conta de Teste', conta.Name, 'Nome da conta incorreto');
    }

    @isTest
    static void testGerarContaComTipo() {
        String tipo = 'Cliente';
        Account conta = TestDataFactorySimulador.gerarConta(tipo);
        System.assertNotEquals(null, conta, 'Conta não deve ser nula');
        System.assertEquals(tipo, conta.Type, 'Tipo da conta incorreto');
    }

    @isTest
    static void testGerarContato() {
        Account conta = TestDataFactorySimulador.gerarConta();
        Contact contato = TestDataFactorySimulador.gerarContato(conta);
        System.assertNotEquals(null, contato, 'Contato não deve ser nulo');
        System.assertEquals(conta.Id, contato.AccountId, 'Conta associada incorretamente');
    }

    @isTest
    static void testGerarCotacao() {
        Account conta = TestDataFactorySimulador.gerarConta();
        Opportunity oportunidade = TestDataFactorySimulador.gerarOportunidade(conta, null);
        Quote cotacao = TestDataFactorySimulador.gerarCotacao(oportunidade);
        System.assertNotEquals(null, cotacao, 'Cotação não deve ser nula');
        System.assertEquals(oportunidade.Id, cotacao.OpportunityId, 'Oportunidade associada incorretamente');
    }

    @isTest
    static void testGerarProduto() {
        Product2 produto = TestDataFactorySimulador.gerarProduto();
        System.assertNotEquals(null, produto, 'Produto não deve ser nulo');
        System.assertEquals('Produto de Teste', produto.Name, 'Nome do produto incorreto');
    }

    @isTest
    static void testGerarEmpreendimento() {
        Empreendimento__c empreendimento = TestDataFactorySimulador.gerarEmpreendimento();
        System.assertNotEquals(null, empreendimento, 'Empreendimento não deve ser nulo');
        System.assertEquals('22151181000190', empreendimento.CNPJEmpreendimento__c, 'CNPJ incorreto');
    }

    @isTest
    static void testGerarTabelaVendas() {
        TabelaVendas__c tabela = TestDataFactorySimulador.gerarTabelaVendas();
        System.assertNotEquals(null, tabela, 'Tabela de Vendas não deve ser nula');
    }

    @isTest
    static void testGerarSeriePagamento() {
        TabelaVendas__c tabela = TestDataFactorySimulador.gerarTabelaVendas();
        SeriePagamentos__c serie = TestDataFactorySimulador.gerarSeriePagamento(tabela.Id);
        System.assertNotEquals(null, serie, 'Série de Pagamento não deve ser nula');
        System.assertEquals(tabela.Id, serie.TabelaVenda__c, 'Tabela de Venda incorreta');
    }

    @isTest
    static void testGerarUnidadeTabelaVendas() {
        TabelaVendas__c tabela = TestDataFactorySimulador.gerarTabelaVendas();
        UnidadeTabelaVendas__c unidade = TestDataFactorySimulador.gerarUnidadeTabelaVendas(tabela.Id);
        System.assertNotEquals(null, unidade, 'Unidade de Tabela de Vendas não deve ser nula');
        System.assertEquals(tabela.Id, unidade.TabelaVenda__c, 'Tabela de Venda incorreta');
    }

    @isTest
    static void testGerarBloco() {
        Empreendimento__c empreendimento = TestDataFactorySimulador.gerarEmpreendimento();
        Bloco__c bloco = TestDataFactorySimulador.gerarBloco(empreendimento.Id);
        System.assertNotEquals(null, bloco, 'Bloco não deve ser nulo');
        System.assertEquals(empreendimento.Id, bloco.Empreendimento__c, 'Empreendimento incorreto');
    }
}