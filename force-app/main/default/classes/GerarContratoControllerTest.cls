@IsTest
public with sharing class GerarContratoControllerTest {
    
    @TestSetup
    static void setup() {
        Account conta = new Account();
        conta.Name = 'Conta de Teste';
        conta.CNPJ__c = '34138415000148';
        conta.Type = 'HouseImobiliaria';
        insert conta;

        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJEmpreendimento__c = '22151181000190';
        empreendimento.TipoEmpreendimento__c = 'Casa';
        empreendimento.StatusObra__c = 'Entregue';
        empreendimento.MetragemPrivativaTotal__c = 5000;
        empreendimento.MetragemTerreno__c = 10000;
        empreendimento.MetragemConstruIdaM__c = 7000;
        insert empreendimento;
        
        Contact contato = new Contact();
        contato.FirstName = 'Elera';
        contato.LastName = 'Teste';
        contato.Email = 'thiagovieirab2b@gmail.com';
        contato.AccountId = conta.Id;
        insert contato;
        
        
        Bloco__c bloco = new Bloco__c(Name = 'Bloco Teste');
        insert bloco;
        
        Product2 prd = new Product2(Name = 'Produto Teste', Bloco__c = bloco.Id, Status__c = 'Reservada', NumeroDaUnidade__c = 101);
        insert prd;
        
        Pricebook2 pricebook = new Pricebook2(
            Name = 'test',
            isActive = true
        );
        insert pricebook;

        Opportunity oportunidade = new Opportunity();
        oportunidade.Name = 'Teste';
        oportunidade.AccountId = conta.Id; 
        oportunidade.Amount = 1000;
        oportunidade.CanalAtendimento__c = 'WhatsApp';
        oportunidade.Probability = 20;
        oportunidade.TipoVenda__c = 'Negócio novo';
        oportunidade.StageName = 'Negociação';
        oportunidade.CloseDate = System.today().addDays(15);
        oportunidade.Empreendimento__c = empreendimento.Id; 
        oportunidade.Unidade__c = prd.Id; 
        oportunidade.Pricebook2Id = pricebook.Id;
        insert oportunidade;

        TemplateDocumento__c template = new TemplateDocumento__c();
        template.Name = 'Template Test';
        template.TipoTemplate__c = 'Contrato';
        template.Empreendimento__c = oportunidade.Empreendimento__c;
        template.Ativo__c = true;
        insert template;

        Contract contract = new Contract(
            AccountId = conta.Id,
            Oportunidade__c = oportunidade.Id,
            DataInicioContrato__c = Date.today(),
            Status = 'Rascunho',
            Name = 'Contrato Test',
            DataEnvioAssinatura__c = Date.today(),
            DataAssinaturaClienteD4Sign__c = Date.today(),
            Template__c = template.Id
        );
        insert contract;

        ContractContactRole ccr = new ContractContactRole(
            ContactId = contato.Id,
            ContractId = contract.Id,
            Role = 'Comprador'
        );
        insert ccr;
            
        String ctrName = 'Contract: '+ contract.Id;
        ContentVersion contVersion = new ContentVersion();
        contVersion.ContentLocation = 'S'; // Indíca que será armazenado diretamente no Salesforce 
        contVersion.Title = ctrName;
        contVersion.PathOnClient = ctrName + '.pdf';
        contVersion.VersionData = Blob.valueOf('TEXT');
        insert contVersion;

        ContentVersion contentVersion_1 = [SELECT Id,  ContentDocumentId, Title FROM ContentVersion WHERE Id = :contVersion.Id LIMIT 1];
        ContentDocumentLink contDocumentLink = new ContentDocumentLink();
        contDocumentLink.ContentDocumentId = contentVersion_1.ContentDocumentId;
        contDocumentLink.LinkedEntityId = contract.Id;
        contDocumentLink.shareType = 'V';
        insert contDocumentLink;
        
        PricebookEntry pricebookStandard = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prd.Id,
            UnitPrice = 100,
            IsActive = true
        );

        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebook.Id,
            Product2Id = prd.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert new List<PricebookEntry> { pricebookStandard, pricebookEntry };

        OpportunityContactRole role = new OpportunityContactRole(
            Role = 'Fiador', 
            ContactId = contato.Id, 
            OpportunityId = oportunidade.Id
        );
        insert role;

        OpportunityLineItem opli = new OpportunityLineItem(
            OpportunityId = oportunidade.Id,
            Product2Id = prd.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 3,
            TotalPrice = 12
        );
        insert opli;

    }

    @IsTest
    public static void testGerarContratoController() {
        Opportunity opp = [
            SELECT Id FROM Opportunity LIMIT 1
        ];

        System.debug([
            SELECT Id, OpportunityId, Product2Id 
            FROM OpportunityLineItem
            WHERE OpportunityId = :opp.Id
        ]);
    

        TemplateDocumento__c template = [
            SELECT Id FROM TemplateDocumento__c LIMIT 1
        ];


        
        Test.startTest();

        Test.setCurrentPageReference(Page.ContratoPDF);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        ApexPages.currentPage().getParameters().put('templateId', template.Id);
        
        GerarContratoController controller = new GerarContratoController();
        
        Test.stopTest();

        System.assertNotEquals(controller.conteudo, null, 'O conteúdo do contrato não deveria ser nulo.');
    }
}