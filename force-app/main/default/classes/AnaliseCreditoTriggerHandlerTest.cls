@IsTest
public with sharing class AnaliseCreditoTriggerHandlerTest {
    
    @TestSetup
    static void setup() {
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Account' AND Name = 'Conta'
        ];
        
        Account accTest = TestDataFactory.gerarConta();
        accTest.EmailJuridico__c = 'teste.@elera.io'; 
        insert accTest;
        
        Opportunity opp1 = TestDataFactory.gerarOportunidade();
        opp1.StageName = 'Pré-análise';
        opp1.AccountId = accTest.Id;
        insert opp1;

        Documentacao__c doc = TestDataFactory.gerarDocumentacao();
        insert doc;

        Checklist_de_Documentos__c checklists = TestDataFactory.gerarChecklistDocumentos(opp1, doc);
        insert checklists;
    }
    
    @IsTest
    static void testBeforeInsert() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        
        AnaliseCredito__c analise1 = TestDataFactory.gerarAnaliseCredito(oppTest);
        AnaliseCredito__c analise2 = TestDataFactory.gerarAnaliseCredito(oppTest);
        analise2.Status__c = 'Aprovada';
        
        Test.startTest();
        insert new List<AnaliseCredito__c> { analise1, analise2 };
        Test.stopTest();
    }

    @IsTest
    static void testBeforeUpdate() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        
        AnaliseCredito__c analise1 = TestDataFactory.gerarAnaliseCredito(oppTest);
        AnaliseCredito__c analise2 = TestDataFactory.gerarAnaliseCredito(oppTest);
        insert new List<AnaliseCredito__c> { analise1, analise2 };

        analise1.Status__c = 'Aprovada';
        analise2.Name = 'SIRRRRR';

        Test.startTest();
        update new List<AnaliseCredito__c> { analise1, analise2 };
        Test.stopTest();
    }

    @IsTest
    static void testAfterInsert() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        
        AnaliseCredito__c analise1 = TestDataFactory.gerarAnaliseCredito(oppTest);
        AnaliseCredito__c analise2 = TestDataFactory.gerarAnaliseCredito(oppTest);
        
        Test.startTest();
        insert new List<AnaliseCredito__c> { analise1, analise2 };
        Test.stopTest();
    }

    @IsTest
    static void testAfterUpdate() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        
        AnaliseCredito__c analise1 = TestDataFactory.gerarAnaliseCredito(oppTest);
        AnaliseCredito__c analise2 = TestDataFactory.gerarAnaliseCredito(oppTest);
        insert new List<AnaliseCredito__c> { analise1, analise2 };

        analise1.Status__c = 'Aprovada';
        analise2.Name = 'SIRRRRR';

        Test.startTest();
        update new List<AnaliseCredito__c> { analise1, analise2 };
        Test.stopTest();
    }

}