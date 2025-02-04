@isTest
private class ProductHelperTest {

    @TestSetup
    static void makeData(){
        insert TestDataFactory.gerarGaragem('Kit de 3 vagas', 3);
    }

    @IsTest
    static void testInsertProductWithGaragem() {
        Garagem__c garagem = [SELECT Id FROM Garagem__c WHERE Name = 'Kit de 3 vagas' LIMIT 1];

        RecordType rt = [SELECT id FROM RecordType WHERE Name = 'Vaga' AND SObjectType = 'Product2'];
        List<Product2> listProducts = TestDataFactory.gerarVagasParaGaragem(2, garagem.Id, rt);

        Test.startTest();   
            insert listProducts;   
            ProductHelper.validateLimitOfVagas(listProducts);
        Test.stopTest();

        System.assertEquals(2, GaragemDA.getQuantityVagasGaragem(garagem.Id), 'A garagem deveria ter 2 vagas ao relacionadas');
    }

    @IsTest 
    static void testInsertProductWithGaragemError() {
        Garagem__c garagem = [SELECT Id FROM Garagem__c WHERE Name = 'Kit de 3 vagas' LIMIT 1];

        RecordType rt = [SELECT id FROM RecordType WHERE Name = 'Vaga' AND SObjectType = 'Product2'];
        List<Product2> listProducts = TestDataFactory.gerarVagasParaGaragem(4, garagem.Id, rt);

        Test.startTest();   
            try {
                insert listProducts;
                ProductHelper.validateLimitOfVagas(listProducts);
            } catch (Exception e) {
                System.assert(e.getMessage().contains('O número de vagas excede o limite permitdo para a garagem'), 
                'Erro esperado não foi encontrado na mensagem: ' + e.getMessage());
            }
        Test.stopTest();

    }
        
}