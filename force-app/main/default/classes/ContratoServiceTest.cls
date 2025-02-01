@isTest
public class ContratoServiceTest {
    @TestSetup
    static void makeData(){
        Empreendimento__c emp = new Empreendimento__c(Name = 'Empreendimento Teste');
        insert emp;

        TemplateDocumento__c template = new TemplateDocumento__c(
            Name = 'Template Teste', 
            Empreendimento__c = emp.Id, 
            TipoTemplate__c = 'Contrato', 
            ConteudoTemplate__c = 'Teste Opportunity.Name, OpportunityContactRole.Role', 
            Ativo__c = true
        );
        insert template;

        Account acc = new Account(Name = 'Conta Teste');
        insert acc;

        Contact cont = new Contact(FirstName = 'Contato', LastName = 'Teste', AccountId = acc.Id);
        insert cont;

        Bloco__c bloco = new Bloco__c(Name = 'Bloco Teste');
        insert bloco;

        Product2 prd = new Product2(Name = 'Produto Teste', Bloco__c = bloco.Id);
        insert prd;

        Pricebook2 pricebook = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
        insert pricebook;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id, 
            Name = 'Oportunidade Teste', 
            Unidade__c = prd.Id, 
            Empreendimento__c = emp.Id, 
            StageName = 'Negociação', 
            CloseDate = Date.today(),
            Pricebook2Id = pricebook.Id
        );
        insert opp;

        OpportunityContactRole role = new OpportunityContactRole(
            Role = 'Fiador', ContactId = cont.Id, OpportunityId = opp.Id
        );
        insert role;

        Contract contrato = new Contract(Name = 'Contrato Teste', AccountId = acc.Id, Status = 'Em Assinatura', Oportunidade__c = opp.Id);
        insert contrato;
    }

    @isTest
    static void testContratoText(){
        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        TemplateDocumento__c template = [SELECT Id, ConteudoTemplate__c FROM TemplateDocumento__c LIMIT 1];
        OpportunityContactRole role = [SELECT Id, Role, ContactId FROM OpportunityContactRole WHERE OpportunityId = :opp.Id LIMIT 1];
        Contact cont = [SELECT Id, Name FROM Contact WHERE Id = :role.ContactId LIMIT 1];

        String text = ContratoService.contratoText(opp, template);
        System.assertNotEquals(null, text);
        System.assertEquals('Teste ' + opp.Name + ', ' + cont.Name + ' - ' + role.Role, text);
    }

    @isTest
    static void testAtualizarPrazoAssinatura(){
        Contract contrato = [SELECT Id, Status, PrazoAssinatura__c FROM Contract WHERE Status = 'Em Assinatura' LIMIT 1];
        Test.startTest();
        ContratoService.atualizarPrazoAssinatura(new List<Contract>{ contrato });
        Test.stopTest();

        contrato = [SELECT Id, PrazoAssinatura__c FROM Contract WHERE Id = :contrato.Id];
        System.assertNotEquals(null, contrato.PrazoAssinatura__c);
    }

    @isTest
    static void testEvitarGeracaoMultipla() {
        Contract contrato = [SELECT Id, Status, Oportunidade__c FROM Contract LIMIT 1];
        contrato.Status = 'Contrato Gerado';
        update contrato;
        Test.startTest();
        ContratoService.evitarGeracaoMultipla(new List<Contract>{ contrato });
        Test.stopTest();
    }

    @isTest
    static void testVerificaPrazoAssinatura() {
        Contract contrato = [SELECT Id, Status, PrazoAssinatura__c FROM Contract WHERE Status = 'Em Assinatura' LIMIT 1];
        contrato.PrazoAssinatura__c = Date.today().addDays(-1);
        update contrato;
        
        Test.startTest();
        ContratoService.verificaPrazoAssinatura(new List<Contract>{ contrato });
        Test.stopTest();
    }
}