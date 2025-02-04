@isTest
private class UnidadeTabelaTriggerHandlerTest {
    
    @isTest static void testAfterUpdate() {
        // Criando registros de oportunidades e contas
        Opportunity opp1 = new Opportunity(Name = 'Oportunidade 1', StageName = 'Prospecting', CloseDate = Date.today());
        Opportunity opp2 = new Opportunity(Name = 'Oportunidade 2', StageName = 'Prospecting', CloseDate = Date.today());
        insert new List<Opportunity>{opp1, opp2};
        
        // Usando Account como exemplo de objeto em vez de Cotacao__c
        Account conta = new Account(Name = 'Conta Teste');
        insert conta;
        
        UnidadeTabelaVendas__c unidade1 = new UnidadeTabelaVendas__c(Name = 'Unidade 1', PrecoLista__c = 1000);
        UnidadeTabelaVendas__c unidade2 = new UnidadeTabelaVendas__c(Name = 'Unidade 2', PrecoLista__c = 1500);
        insert new List<UnidadeTabelaVendas__c>{unidade1, unidade2};
        
        // Atualizando as unidades
        unidade1.PrecoLista__c = 1100;
        unidade2.PrecoLista__c = 1600;
        update new List<UnidadeTabelaVendas__c>{unidade1, unidade2};
        

        Test.startTest();
        Test.stopTest();


        List<Opportunity> oportunidadesAtualizadas = [SELECT Id, Name FROM Opportunity WHERE Id IN :new List<Id>{opp1.Id, opp2.Id}];
    }
}