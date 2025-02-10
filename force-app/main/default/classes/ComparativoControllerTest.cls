@isTest
public class ComparativoControllerTest {

    @TestSetup
    static void setup() {
         // Criando e inserindo TabelaVendas__c diretamente
         TabelaVendas__c tabelaVenda = new TabelaVendas__c(
            Name = 'Teste', 
            PeriodicidadeParcelaPos__c = 1, 
            PeriodicidadeParcela__c = 1
        );
        insert tabelaVenda;

        // Criando e inserindo UnidadeTabelaVendas__c diretamente
        UnidadeTabelaVendas__c unidadeTabelaVendaProduto = new UnidadeTabelaVendas__c(
            Name = 'UnidadeVendaTeste',
            TabelaVenda__c = tabelaVenda.Id,
            PrecoLista__c = 300000
        );
        insert unidadeTabelaVendaProduto;

        Empreendimento__c empr = new Empreendimento__c();
        empr.Name = 'Empreendimento de Teste';
        empr.CNPJEmpreendimento__c = '22151181000190';
        empr.TipoEmpreendimento__c = 'Casa';
        empr.StatusObra__c = 'Entregue';
        empr.MetragemPrivativaTotal__c = 5000;
        empr.MetragemTerreno__c = 10000;
        empr.MetragemConstruIdaM__c = 7000; 
        empr.DataHabitase__c = Date.today();
        insert empr;

        // Criando e inserindo Produto2 diretamente
        Product2 produto = new Product2(
            AgenteFinanceiro__c = 'FII',
            Enquadramento__c = 'HIS',
            Andar__c = 10,
            Coeficiente__c = 0,
            NumeroQuartos__c = 2,
            NumeroDeSuites__c = 1,
            NumeroDeVagasIncorporadas__c = 1,
            Name = 'Produto de Teste',
            ProductCode = 'Teste-1',
            isActive = true,
            NumeroDaUnidade__c = 777,
            Status__c = 'Reservada',
            ValorM2__C = 8,
            ExternalId = '10',
            Empreendimento__c = empr.Id
        );
        insert produto;

        // Criando e inserindo SeriePagamentos__c diretamente
        SeriePagamentos__c seriePagamento = new SeriePagamentos__c(
            Name = 'Teste',
            InicioPagamento__c = 1,
            QuantidadeParcelas__c = 1,
            ValorTotal__c = 1,
            TabelaVenda__c = tabelaVenda.Id,
            TipoCondicao__c = 'Ato'
        );
        insert seriePagamento;
    }

    @isTest
    public static void testCalcularComparacao() {
        
        TabelaVendas__c tabelaVenda = [
            SELECT Id FROM TabelaVendas__c
        ];

        List<SeriePagamentos__c> series = [
            SELECT Id, ValorTotal__c, QuantidadeParcelas__c, Periodicidade__c, InicioPagamento__c, AposHabiteSe__c
            FROM SeriePagamentos__c
        ];

        Product2 produto = [
            SELECT Id, MetragemTotal__c, Empreendimento__c FROM Product2 
        ];

        // Criar o Mapa de valoresMatriz
        Map<String, Object> valoresMatriz = new Map<String, Object>();
        valoresMatriz.put('nominalTabela', 10000.0);
        valoresMatriz.put('nominalProposta', 9500.0);

        // Serializar o Produto
        String produtoJson = JSON.serialize(produto);

        // Chamar o método do controlador
        Test.startTest();
        List<Object> resultado = ComparativoController.calcularComparacao(tabelaVenda.Id, series, valoresMatriz, produtoJson);
        Test.stopTest();

        // Verificar o resultado
        System.assertNotEquals(null, resultado, 'O resultado não pode ser nulo');
        System.assertEquals(5, resultado.size(), 'Deve haver dois itens no resultado (valor do m² e captação até metade do prazo)');
    }
}