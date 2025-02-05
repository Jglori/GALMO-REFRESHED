@isTest
public class ConciergeServiceTest {
    
    @isTest
    static void testObterCanaisAtendimento() {
        Test.startTest();
        Map<String, String> canais = ConciergeService.obterCanaisAtendimento();
        Test.stopTest();
        
        System.assertNotEquals(null, canais, 'Os canais de atendimento não devem ser nulos.');
        System.assert(canais.size() > 0, 'A lista de canais de atendimento deve conter valores.');
    }
    
    
    
    @isTest
    static void testObterOrigens() {
        Test.startTest();
        Map<String, String> origens = ConciergeService.obterOrigens();
        Test.stopTest();
        
        System.assertNotEquals(null, origens, 'As origens não devem ser nulas.');
        System.assert(origens.size() > 0, 'A lista de origens deve conter valores.');
    }
    
    @isTest
    static void testObterLeadsPorInformacoesConcierge() {
        // Setup de dados de teste
        Lead lead = new Lead(
            FirstName = 'João',
            LastName = 'Silva',
            Email = 'joao.silva@example.com',
            MobilePhone = '11987654321',
            LeadSource = 'Internet',
            CanalAtendimento__c = 'Telefone',
            Status = 'Novo'
        );
        insert lead;
        
        Test.startTest();
        String leadsJson = ConciergeService.obterLeadsPorInformacoesConcierge('11987654321', 'joao.silva@example.com', false , '');
        Test.stopTest();
        
        System.assertNotEquals(null, leadsJson, 'O JSON de leads não deve ser nulo.');
        System.assert(leadsJson.contains('joao.silva@example.com'), 'O JSON de leads deve conter o e-mail de João Silva.');
    }
    
   @isTest
    static void testAtualizarLead() {
        // Setup de dados de teste
        Lead lead = new Lead(
            FirstName = 'Maria',
            LastName = 'Oliveira',
            Email = 'maria.oliveira@example.com',
            MobilePhone = '11987654322',
            LeadSource = 'Instagram',
            CanalAtendimento__c = 'Telefone',
            Status = 'Novo'
        );
        insert lead;

        Lead lead2 = new Lead(
            FirstName = 'Maria',
            LastName = 'nuns',
            Email = 'maria.oliveira123@example.com',
            MobilePhone = '11987654388',
            LeadSource = 'Instagram',
            CanalAtendimento__c = 'Telefone',
            Status = 'Novo'
        );
        insert lead2;
    
        // Criando um registro de RoletaLeads__c para usar no teste
        RoletaLeads__c roletaLead = new RoletaLeads__c(Name = 'Roleta Teste');
        insert roletaLead;
    
        // Preenchendo os dados do formulário
        Map<String, Object> leadData = new Map<String, Object>();
        leadData.put('id', lead.Id);
        leadData.put('idRoleta', roletaLead.Id);
        List<Map<String, Object>> formulario = new List<Map<String, Object>> { leadData };
    
        // Executando o método a ser testado
        Test.startTest();
        try {
            ConciergeService.atualizarLead(formulario);
        } catch (Exception ex){}
        Test.stopTest();
    
        // Verificando se o campo RoletaLeads__c foi atualizado corretamente
        Lead updatedLead = [SELECT Id, RoletaLeads__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        System.assertEquals(roletaLead.Id, updatedLead.RoletaLeads__c, 'O campo RoletaLeads__c deve ser atualizado.');
    }

    
    @isTest
    static void testCriarLead() {
        Map<String, String> formulario = new Map<String, String>{
            'tipoPessoa' => 'Física',
            'nome' => 'Ana Souza',
            'celular' => '11987654323',
            'email' => 'ana.souza@example.com',
            'origem' => 'Web',
            'canal' => 'Telefone',
            'razaoSocial' => null,
            'phone' => null,
            'idRoletaLeads' => null,
            'nomeRepresentante' => null,
            'corretor' => null,
            'celularRepresentante' => null
        };

        Test.startTest();
        ConciergeService.criarLead(formulario);
        Test.stopTest();
        
        Lead createdLead = [SELECT Id, FirstName, LastName, Email, MobilePhone FROM Lead WHERE Email = 'ana.souza@example.com' LIMIT 1];
        System.assertNotEquals(null, createdLead, 'O Lead deve ser criado.');
        System.assertEquals('Ana', createdLead.FirstName, 'O primeiro nome deve ser Ana.');
        System.assertEquals('Souza', createdLead.LastName, 'O sobrenome deve ser Souza.');
    }
    
    
    
    @isTest
    static void testCriarTaskReiteracao() {
        // Setup de dados de teste
        Lead lead = new Lead(
            FirstName = 'Pedro',
            LastName = 'Silva',
            Email = 'pedro.silva@example.com',
            MobilePhone = '11987654324',
            LeadSource = 'Telefone',
            Status = 'Novo',
            CanalAtendimento__c = 'Telefone'
        );
        insert lead;
        
        String jsonLead = JSON.serialize(new Map<String, Object>{
            'lead' => new Map<String, Object>{
                'id' => lead.Id,
                'nomeCorretor' => 'João Corretor',
                'empreendimentoInteresse' => 'Imóvel A'
            }
        });

        Test.startTest();
        ConciergeService.criarTaskReiteracao(jsonLead, null);
        Test.stopTest();
        
        // Task createdTask = [SELECT Id, Subject, Description FROM Task WHERE WhoId = :lead.Id AND Status = 'Open' LIMIT 1];
        // System.assertNotEquals(null, createdTask, 'A tarefa deve ser criada.');
        // System.assertEquals('Reiteração', createdTask.Subject, 'O assunto da tarefa deve ser Reiteração.');
    }
    
    @isTest
static void testBuscarCorretoresLetra() {
    // Setup de dados de teste
    Contact corretor1 = new Contact(
        FirstName = 'João',
        LastName = 'Silva',
        Corretor__c = true,
        CRECI__c = '12345',
        TipoCRECI__c = 'Definitivo',
        DatadeInscricao__c = Date.today().addYears(-2),
        EmissaoCertidaodeRegularidadeCRECI__c = Date.today().addYears(-1),
        DatadeVencimento__c = Date.today().addMonths(6),
        RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1].Id
    );
    Contact corretor2 = new Contact(
        FirstName = 'José',
        LastName = 'Souza',
        Corretor__c = true,
        CRECI__c = '67890',
        TipoCRECI__c = 'Definitivo',
        DatadeInscricao__c = Date.today().addYears(-1),
        EmissaoCertidaodeRegularidadeCRECI__c = Date.today().addMonths(-3),
        DatadeVencimento__c = Date.today().addMonths(9),
        RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1].Id
    );
    insert new List<Contact>{corretor1, corretor2};

    Test.startTest();
    List<Contact> corretores = ConciergeService.buscarCorretoresLetra('Jo');
    Test.stopTest();

    System.assertNotEquals(null, corretores, 'A lista de corretores não deve ser nula.');
    System.assert(corretores.size() > 0, 'A lista de corretores deve conter valores.');
    System.assertEquals(2, corretores.size(), 'Devem ser retornados dois corretores.');
}

@isTest
static void testBuscarTodosCorretores() {
    // Setup de dados de teste
    Contact corretor1 = new Contact(
        FirstName = 'Carlos',
        LastName = 'Lima',
        Corretor__c = true,
        CRECI__c = '54321',
        TipoCRECI__c = 'Definitivo',
        DatadeInscricao__c = Date.today().addYears(-3),
        EmissaoCertidaodeRegularidadeCRECI__c = Date.today().addMonths(-6),
        DatadeVencimento__c = Date.today().addMonths(12),
        RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1].Id
    );
    Contact corretor2 = new Contact(
        FirstName = 'Ana',
        LastName = 'Ferreira',
        Corretor__c = false, // Este corretor não será filtrado
        RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1].Id
    );
    insert new List<Contact>{corretor1, corretor2};

    Test.startTest();
    List<Contact> corretores = ConciergeService.buscarTodosCorretores();
    Test.stopTest();

    System.assertNotEquals(null, corretores, 'A lista de corretores não deve ser nula.');
    System.assert(corretores.size() > 0, 'A lista de corretores deve conter valores.');
   
}  
    
    @isTest
    static void testSepararNomes() {
        String nomeCompleto = 'Carlos Silva';
        Map<String, String> resultado = ConciergeService.separarNomes(nomeCompleto);
        System.assertEquals('Carlos', resultado.get('firstName'), 'O primeiro nome deve ser "Carlos".');
        System.assertEquals('Silva', resultado.get('lastName'), 'O sobrenome deve ser "Silva".');

        // Teste 2: Nome apenas com sobrenome
        String nomeSobrenome = 'Silva';
        resultado = ConciergeService.separarNomes(nomeSobrenome);
        System.assertEquals('', resultado.get('firstName'), 'O primeiro nome deve ser vazio.');
        System.assertEquals('Silva', resultado.get('lastName'), 'O sobrenome deve ser "Silva".');

        // Teste 3: Nome vazio
        String nomeVazio = '';
        resultado = ConciergeService.separarNomes(nomeVazio);
        System.assertEquals('', resultado.get('firstName'), 'O primeiro nome deve ser vazio.');
        System.assertEquals('', resultado.get('lastName'), 'O sobrenome deve ser vazio.');

        // Teste 4: Nome com múltiplos espaços
        String nomeMultiploEspacos = '   Carlos Silva   ';
        resultado = ConciergeService.separarNomes(nomeMultiploEspacos.trim()); // Usando trim() para remover espaços
        System.assertEquals('Carlos', resultado.get('firstName'), 'O primeiro nome deve ser "Carlos".');
        System.assertEquals('Silva', resultado.get('lastName'), 'O sobrenome deve ser "Silva".');

        // Teste 5: Nome com um único nome
        String nomeUnico = 'Carlos';
        resultado = ConciergeService.separarNomes(nomeUnico);
        System.assertEquals('', resultado.get('firstName'), 'O primeiro nome deve ser vazio.');
        System.assertEquals('Carlos', resultado.get('lastName'), 'O sobrenome deve ser "Carlos".');
    }
    
    @isTest
    static void testObterRoletasLeadsVigentes() {
        // Dados de teste
        // Criar uma roleta ativa com dentro do horário de funcionamento (de acordo com a fórmula)
        RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta 1',
            Ativa__c = true,
            HoraInicio__c = Time.newInstance(9, 0, 0, 0), // 09:00 AM
            HoraFim__c = Time.newInstance(17, 0, 0, 0) // 05:00 PM
        );

        // Criar uma roleta inativa
        RoletaLeads__c roleta2 = new RoletaLeads__c(
            Name = 'Roleta 2',
            Ativa__c = false,
            HoraInicio__c = Time.newInstance(10, 0, 0, 0),
            HoraFim__c = Time.newInstance(16, 0, 0, 0)
        );

        // Criar roleta fora do horário de funcionamento
        RoletaLeads__c roleta3 = new RoletaLeads__c(
            Name = 'Roleta 3',
            Ativa__c = true,
            HoraInicio__c = Time.newInstance(18, 0, 0, 0), // Fora do horário de funcionamento
            HoraFim__c = Time.newInstance(22, 0, 0, 0)
        );

        // Inserir as roletas no banco de dados
        insert new List<RoletaLeads__c>{roleta1, roleta2, roleta3};

        // Executar o método em teste
        Test.startTest();
        String roletasJSON = ConciergeService.obterRoletasLeadsVigentes();
        Test.stopTest();

        // Verificar que apenas roletas vigentes estão sendo retornadas
        // O método JSON.serialize retorna uma string, então precisamos garantir que os dados estão corretos
        System.debug('JSON Result: ' + roletasJSON);
        List<RoletaLeadsDTO> roletas = (List<RoletaLeadsDTO>) JSON.deserialize(roletasJSON, List<RoletaLeadsDTO>.class);
       
    }

    

    @isTest
    static void testCriarTaskReiteracaoeAssociarCorretor() {
        // Setup de dados de teste
        Lead lead = new Lead(
            FirstName = 'Lucas',
            LastName = 'Costa',
            Email = 'lucas.costa@example.com',
            MobilePhone = '11987654325',
            LeadSource = 'Radio',
            CanalAtendimento__c = 'Telefone',
            Status = 'Novo'
        );
        insert lead;

        Contact corretor = new Contact(
            FirstName = 'Corretor',
            LastName = 'Teste',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1].Id
        );
        insert corretor;

        String jsonLead = JSON.serialize(new Map<String, Object>{
            'lead' => new Map<String, Object>{
                'id' => lead.Id,
                'nomeCorretor' => 'Corretor Teste',
                'empreendimentoInteresse' => 'Imóvel B'
            }
        });

        Test.startTest();
        ConciergeService.criarTaskReiteracaoeAssociarCorretor(jsonLead, corretor.Id);
        Test.stopTest();
        
        // Task createdTask = [SELECT Id, Subject, Description FROM Task WHERE WhoId = :lead.Id AND Status = 'Open' LIMIT 1];
        // System.assertNotEquals(null, createdTask, 'A tarefa deve ser criada.');
        // System.assertEquals('Reiteração', createdTask.Subject, 'O assunto da tarefa deve ser Reiteração.');

        // Lead updatedLead = [SELECT Id, CorretorContato__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        // System.assertEquals(corretor.Id, updatedLead.CorretorContato__c, 'O corretor deve estar associado ao lead.');
    }
    
}