@isTest
public class ValidarCNPJFromTriggerTest {

    @isTest
    static void testTriggerCNPJValido() {
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Lead';
        lead.CNPJ__c = '11084433000199';
        insert Lead;
        System.assertNotEquals(null, lead.Id);
    }

    @isTest
    static void testTriggerCPFInvalido() {
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Lead';
        lead.CNPJ__c = '1234567890123';
        Test.startTest();
        try {
            insert lead;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('CNPJ inválido'));
        }
        Test.stopTest();
        System.assertEquals(null, lead.Id);
    }

}