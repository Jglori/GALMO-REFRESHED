@IsTest
public class TemplateDocumentoDATest {

    @TestSetup
    static void setupData() {
        // Criação de Account para teste
        Account acc = new Account(Name = 'Conta Teste', CNPJ__c = '11084433000199');
        insert acc;

        // Criação de Empreendimento para teste
        Empreendimento__c emp = new Empreendimento__c();
        emp.Name = 'Empreendimento de Teste';
        emp.CNPJEmpreendimento__c = '11084433000199';
        insert emp;

        // Criando Template Ativo
        TemplateDocumento__c activeTemplate = new TemplateDocumento__c(
            Name = 'Template Ativo',
            TipoTemplate__c = 'Contrato',
            ConteudoTemplate__c = 'Conteúdo Ativo',
            Empreendimento__c = emp.Id,
            Ativo__c = true
        );

        // Criando Template Inativo
        TemplateDocumento__c inactiveTemplate = new TemplateDocumento__c(
            Name = 'Template Inativo',
            TipoTemplate__c = 'Outro Documento',
            ConteudoTemplate__c = 'Conteúdo Inativo',
            Empreendimento__c = emp.Id,
            Ativo__c = false
        );

        insert new List<TemplateDocumento__c>{ activeTemplate, inactiveTemplate };

        // Criando uma Opportunity associada ao Empreendimento
        Opportunity opp = new Opportunity(
            Name = 'Oportunidade de Teste',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            Empreendimento__c = emp.Id  // Associando o Empreendimento à Opportunity via campo Empreendimento__c
        );
        insert opp;
    }

    @IsTest
    static void testGetTemplatesByEmpId() {
        // Obtém o ID do Empreendimento para testar
        String empId = [SELECT Id FROM Empreendimento__c LIMIT 1].Id;

        Test.startTest();
        
        // Chama o método de teste
        List<TemplateDocumento__c> templates = TemplateDocumentoDA.getTemplatesByEmpId(empId);
        
        Test.stopTest();
        
        // Verificação do resultado
        System.assertEquals(1, templates.size(), 'Deveria retornar apenas o template ativo.');
        System.assertEquals('Template Ativo', templates[0].Name, 'Deveria retornar o template ativo com nome "Template Ativo".');
    }

    @IsTest
    static void testGetById() {
        // Obtém o ID do Template Ativo
        Id templateId = [SELECT Id FROM TemplateDocumento__c WHERE Name = 'Template Ativo' LIMIT 1].Id;

        Test.startTest();
        
        // Chama o método para obter o template pelo ID
        TemplateDocumento__c template = TemplateDocumentoDA.getById(templateId);
        
        Test.stopTest();
        
        // Verificação do resultado
        System.assertNotEquals(null, template, 'Deveria retornar o template ativo.');
        System.assertEquals('Template Ativo', template.Name, 'Deveria retornar o template com nome "Template Ativo".');
        System.assertEquals('Conteúdo Ativo', template.ConteudoTemplate__c, 'O conteúdo do template deve ser "Conteúdo Ativo".');
    }

    @IsTest
    static void testGetByOpportunityId() {
        // Obtém o ID da Opportunity
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        
        // Chama o método para obter templates relacionados à Opportunity
        List<TemplateDocumento__c> templates = TemplateDocumentoDA.getByOpportunityId(opp.Id);
        
        Test.stopTest();
        
        // Verificação do resultado
        System.assertNotEquals(null, templates, 'Deveria retornar os templates relacionados à Opportunity.');
       // System.assertEquals(1, templates.size(), 'Deveria retornar o template ativo.');
        System.assertEquals('Template Ativo', templates[0].Name, 'Deveria retornar o template ativo com nome "Template Ativo".');
    }
}