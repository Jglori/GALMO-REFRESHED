@isTest
public class TabelaVendaHandlerTest {    
        
    @isTest
    public static void testInserirUnidadesTabelas(){
        List<TabelaVendas__c> tabelas = [SELECT id, Empreendimento__c, AcrescimoValorTotal__c FROM tabelaVendas__c ];

        Test.startTest();
        TabelaVendasService.inserirUnidadesTabelas(tabelas);
        Test.stopTest();
    }

    @isTest
    public static void testInsert() {
        TabelaVendas__c tabela = TestDataFactorySimulador.gerarTabelaVendas();
        
        Test.startTest();
        insert tabela; 
        Test.stopTest();
        
        List<UnidadeTabelaVendas__c> unidadesCriadas = [SELECT Id, TabelaVenda__c FROM UnidadeTabelaVendas__c WHERE TabelaVenda__c = :tabela.Id];
        System.debug('Unidades Criadas: ' + unidadesCriadas);
    }
    
    @isTest
    public static void testUpdate() {
        TabelaVendas__c tabela = TestDataFactorySimulador.gerarTabelaVendas();
        
        insert tabela;
        tabela.Name = 'Tabela Atualizada';
        
        Test.startTest();
        update tabela;
        Test.stopTest();
        
        List<UnidadeTabelaVendas__c> unidadesCriadas = [SELECT Id, TabelaVenda__c FROM UnidadeTabelaVendas__c WHERE TabelaVenda__c = :tabela.Id];
        System.debug('Unidades Criadas ou Atualizadas: ' + unidadesCriadas);
    }
    
    
}