public with sharing class OpportunityDA {
    
    public static Map<Id, Opportunity> getOpportunitiesWithQuote(Set<Id> opportunityIds) {
        return new Map<Id, Opportunity>([
            SELECT Id, Pricebook2Id, SyncedQuoteId
            FROM Opportunity
            WHERE Id IN :opportunityIds AND Pricebook2Id != null
        ]);
    }
    
    public static Boolean hasSyncedQuote(Id opportunityId) {
        Opportunity opp;
        try {
            opp = [
                SELECT SyncedQuoteId
                FROM Opportunity
                WHERE Id = :opportunityId
            ];
        } catch (QueryException e) {
            System.debug('Erro ao consultar oportunidade: ' + e.getMessage());
            return false;
        }
        
        return !String.isBlank(opp.SyncedQuoteId);
    }
    
    public static List<OpportunityLineItem> getOpportunityLineItems(Id opportunityId) {
        return [
            SELECT Id, OpportunityId, Product2Id
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ];
    }
    
    public static List<OpportunityContactRole> getOpportunityContactRoles(Id opportunityId) {
        return [
            SELECT Id, OpportunityId, ContactId
            FROM OpportunityContactRole
            WHERE OpportunityId = :opportunityId
        ];
    }
    
    public static List<OpportunityContactRole> getOpportunityContactRolesPercent(Id opportunityId) {
        return [
            SELECT Id, OpportunityId, ContactId, PorcentagemParticipacao__c 
            FROM OpportunityContactRole
            WHERE OpportunityId = :opportunityId
        ];
    }
    
    public static List<AccountContactRelation> getAccountsWithSpouse(Set<Id> accountIds) {
        if (accountIds.isEmpty()) {
            return new List<AccountContactRelation>();
        }

        return [
            SELECT AccountId 
            FROM AccountContactRelation 
            WHERE AccountId IN :accountIds AND Relacionamento__c = 'Cônjuge/Companheiro'
        ];
    }
    
    // public static List<Opportunity> obterOportunidadePorIdProduto(Set<Id> idProduto) {
    //     return [
    //         SELECT  
    //             id, name, AccountId, Account.name, Account.PersonEmail, Contato__c, Contato__r.name, Contato__r.OwnerId, 
    //             Contato__r.Owner.name, Contato__r.Email, Contato__r.Owner.Reportase__c, Contato__r.Owner.Reportase__r.Name,
    //             Produto__c, Produto__r.name, Produto__r.Status__c
    //         FROM Opportunity 
    //         WHERE Produto__c = :idProduto
    //     ];
        
    // }
    
    // Método para obter o mapa de contagem de análises de crédito por oportunidade
    public static Map<Id, Integer> getAnaliseCreditoCountByOpportunity(Set<Id> opportunityIds) {
        Map<Id, Integer> mapAnalisesRelacionadas = new Map<Id, Integer>();
        
        List<AggregateResult> aggregateResults = [
        SELECT COUNT(Id) quantidade, Opportunity__c
        FROM AnaliseCredito__c
        WHERE Opportunity__c IN :opportunityIds
        GROUP BY Opportunity__c
    ];
        
        for (AggregateResult ag : aggregateResults) {
            Id oppId = (Id) ag.get('Opportunity__c');
            Integer quantidade = (Integer) ag.get('quantidade');
            mapAnalisesRelacionadas.put(oppId, quantidade);
        }
        
        return mapAnalisesRelacionadas;
    }
    
    public static Boolean getOpportunityWithChecklistApproval(Id opportunityId) {
        List<ProcessInstance> processInstances = [
        SELECT Id, 
            ProcessDefinition.DeveloperName, 
            Status 
        FROM ProcessInstance 
        WHERE TargetObjectId = :opportunityId 
        AND ProcessDefinition.DeveloperName = 'ProcessoAprovacaoChecklist'
        AND Status = 'Approved' 
    ];
        
        return !processInstances.isEmpty();
    }
    
    public static List<Opportunity> getAllByAnaliseCreditoId(Set<Id> idsAnalise) {
        if (idsAnalise == null) {
            return new List<Opportunity>();
        }
        
        return [
            SELECT Id, Name, AccountId, Corretor__c, StageName, Type
            FROM Opportunity
            WHERE Id IN (
                SELECT Opportunity__c
                FROM AnaliseCredito__c
                WHERE Id IN :idsAnalise 
            )
        ];
    }
    
    public static List<Opportunity> getByAnaliseCreditoId(Id idAnalise) {
        if (idAnalise == null) {
            return new List<Opportunity>();
        }
        
        return [
            SELECT Id, Name, AccountId, Corretor__c, StageName, Type
            FROM Opportunity
            WHERE Id IN (
                SELECT Opportunity__c
                FROM AnaliseCredito__c
                WHERE Id = :idAnalise
            )
        ];
    }
    
    public static List<Opportunity> getAllById(Set<Id> ids) {
        if (ids == null) {
            return new List<Opportunity>();
        }
        
        return [
            SELECT Id, 
                Name, 
                AccountId, 
                Account.PersonEmail, 
                Account.EmailJuridico__c, 
                Corretor__c, 
                Corretor__r.Email,
                Empreendimento__c, 
                OwnerId, 
                Owner.Email 
            FROM Opportunity
            WHERE Id IN :ids
        ];
    }
    
    public static Opportunity getById(Id id) {
        try {
            return [
                SELECT Id, 
                    Name, 
                    AccountId, 
                    Account.PersonEmail, 
                    Account.EmailJuridico__c, 
                    Corretor__c, 
                    Corretor__r.Email,
                    Empreendimento__c, 
                    OwnerId, 
                    Owner.Email 
                FROM Opportunity
                WHERE Id = :id
            ];
        } catch (Exception e) {
            return null;
        }
    }
    
}