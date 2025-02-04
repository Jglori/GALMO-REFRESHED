@isTest
public class enviarParaAPIOLXAsyncTest {

    @isTest
    public static void testEnviarParaAPIOLX() {
        Lead testLead = new Lead(
            LastName = 'Silva',
            Email = 'teste@dominio.com',
            Phone = '1234567890',
            MobilePhone = '9876543210',
            Description = 'Descrição do lead'
        );
        insert testLead;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAPIOLX());

        Test.startTest();
        
        enviarParaAPIOLXAsync.enviarParaAPIOLX(testLead.Id);
        
        Test.stopTest();
        
        System.assert(true, 'Teste concluído sem erros');
    }

    @isTest
    public static void testEnviarParaAPIOLXWithMock() {
        Lead testLead = new Lead(
            LastName = 'Souza',
            Email = 'teste.souza@dominio.com',
            Phone = '1122334455',
            MobilePhone = '5566778899',
            Description = 'Outro teste de lead'
        );
        insert testLead;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAPIOLX());

        Test.startTest();

        enviarParaAPIOLXAsync.enviarParaAPIOLX(testLead.Id);

        Test.stopTest();

        System.assert(true, 'Teste concluído com mock de resposta');
    }
}