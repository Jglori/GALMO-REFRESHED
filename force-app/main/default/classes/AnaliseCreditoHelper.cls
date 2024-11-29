public with sharing class AnaliseCreditoHelper {

    public static void handleOpportunityFase(List<AnaliseCredito__c> analises) {
        if (analises == null || analises.isEmpty()) {
            throw new IllegalArgumentException('A lista de Análises de Crédito não deve ser nula ou vazia.');
        }
        
        Set<Id> opportunityIds = new Set<Id>();
        for (AnaliseCredito__c analise : analises) {
            if (analise.Opportunity__c == null) throw new IllegalArgumentException('Oportunidade não deve ser null.');

            opportunityIds.add(analise.Opportunity__c);
        }

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
            [SELECT Id, Name, StageName FROM Opportunity WHERE Id IN :opportunityIds]
        );

        for (AnaliseCredito__c analise : analises) {
            Opportunity opp = opportunityMap.get(analise.Opportunity__c);
            if (opp.StageName != 'Pré-análise') {
                analise.addError('Análise de Crédito pode ser criada somente na fase de Pré-análise da Oportunidade');
            }
        }
    }

    public static void handleStatusForOpportunity(List<AnaliseCredito__c> analises) {
        if (analises == null || analises.isEmpty()) {
            throw new IllegalArgumentException('A lista de Análises de Crédito não deve ser nula ou vazia.');
        }
        
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, Integer> analisesAprovadas = new Map<Id, Integer>();

        for (AnaliseCredito__c analise : analises) {
            if (analise.Status__c == null) throw new IllegalArgumentException('Status não deve ser null.');
            
            if (analise.Opportunity__c == null) throw new IllegalArgumentException('Oportunidade não deve ser null.');

            if (analise.Status__c == 'Aprovada') {
                opportunityIds.add(analise.Opportunity__c);
            
                if (!analisesAprovadas.containsKey(analise.Opportunity__c)) {
                    analisesAprovadas.put(analise.Opportunity__c, 1);
                } else {
                    analisesAprovadas.put(analise.Opportunity__c, analisesAprovadas.get(analise.Opportunity__c) + 1);
                }
                
                if (analisesAprovadas.get(analise.Opportunity__c) > 1) {
                    analise.addError('Não é permitido ter duas análises de crédito com status aprovada em uma oportunidade');
                }
            }
        }
        
        Map<Id, Integer> opportunityComAnalisesAprovada = new Map<Id, Integer>();
        if (!opportunityIds.isEmpty()) {
            List<AggregateResult> aggregateResults = [
                SELECT COUNT(Id) quantidade, Opportunity__c 
                FROM AnaliseCredito__c
                WHERE Status__c = 'Aprovada' AND Opportunity__c IN :opportunityIds
                GROUP BY Opportunity__c
            ];

            for (AggregateResult ar : aggregateResults) {
                Id opportunityId = (Id) ar.get('Opportunity__c');
                Integer count = (Integer) ar.get('quantidade');
                opportunityComAnalisesAprovada.put(opportunityId, count); 
            }
        }

        for (AnaliseCredito__c analise : analises) {
            if (analise.Status__c == 'Aprovada') {
                Integer quantidade = opportunityComAnalisesAprovada.get(analise.Opportunity__c);

                if (quantidade != null && quantidade > 0) {
                    analise.addError('Não é permitido ter duas análises de crédito com status aprovada em uma oportunidade');
                }
            }
        }   
    }

    public static void handleDataVencimento(List<AnaliseCredito__c> analises) {
        if (analises == null || analises.isEmpty()) {
            throw new IllegalArgumentException('A lista de Análises de Crédito não deve ser nula ou vazia.');
        }

        Date hoje = Date.today();
        for(AnaliseCredito__c analise : analises) {
            if (analise.DataVencimento__c == null) {
                analise.addError('Data Vencimento não deve estar vazia');
                analise.DataVencimento__c.addError('Data Vencimento não deve estar vazia');
            }
            
            if (hoje > analise.DataVencimento__c) {
                analise.Status__c = 'Vencida';
            }
        }
    }

    public static void handleDocumentVerification(List<AnaliseCredito__c> analises) {
        if (analises == null || analises.isEmpty()) {
            throw new IllegalArgumentException('A lista de Análises de Crédito não deve ser nula ou vazia.');
        }

        Set<Id> analiseIds = new Set<Id>();
        Map<Id, AnaliseCredito__c> analisePorOpp = new Map<Id, AnaliseCredito__c>();
        for (AnaliseCredito__c analise : analises) {
            if (analise.Status__c != 'Aprovada') continue;
            if (analise.Status__c == null) throw new IllegalArgumentException('Status da Análise não deve ser null.');
            if (analise.Opportunity__c == null) throw new IllegalArgumentException('Oportunidade da Análise não deve ser null.');

            analiseIds.add(analise.Id);
            analisePorOpp.put(analise.Opportunity__c, analise);
        }

        if (analiseIds.isEmpty() || analisePorOpp.isEmpty()) return;

        // List<Checklist_de_Documentos__c> cklistDocs = ChecklistHelper.getByAnalisesCredito(analiseIds);
        List<Checklist_de_Documentos__c> cklistDocs = new List<Checklist_de_Documentos__c>();
        
        for (Checklist_de_Documentos__c cklistDoc : cklistDocs) {
            if (cklistDoc.Oportunidade__c == null) throw new IllegalArgumentException('Oportunidade de Checklist não deve ser null.');
            if (cklistDoc.Documenta_o__c == null) throw new IllegalArgumentException('Documentacao de Checklist não deve ser null.');
    
            AnaliseCredito__c analise = analisePorOpp.get(cklistDoc.Oportunidade__c);
            if (analise != null && analise.Status__c == 'Aprovada' && !cklistDoc.Documenta_o__r.Validado__c) {
                analise.Status__c = 'Reprovada';
            }
        }
    }   

    public static void handleNotification(List<AnaliseCredito__c> analises) {
        if (analises == null || analises.isEmpty()) {
            throw new IllegalArgumentException('A lista de Análises de Crédito não deve ser nula ou vazia.');
        }

        Set<Id> oppIds = new Set<Id>();
        Map<Id, AnaliseCredito__c> analisePorOpp = new Map<Id, AnaliseCredito__c>();
        for (AnaliseCredito__c analise : analises) {
            if (analise == null || analise.Status__c != 'Aprovada' && analise.Status__c != 'Reprovada') continue;
            if (analise.Opportunity__c == null) throw new IllegalArgumentException('Oportunidade da Análise não deve ser null.');
            if (analise.Status__c == null) throw new IllegalArgumentException('Status da Análise não deve ser null.');

            oppIds.add(analise.Opportunity__c);
            analisePorOpp.put(analise.Opportunity__c, analise);
        }

        if (oppIds.isEmpty() || analisePorOpp.isEmpty()) return;

        // List<Opportunity> opps = OpportunityHelper.getByIds(oppIds);
        List<Opportunity> opps = new List<Opportunity>();
        
        List<FeedItem> feeds = new List<FeedItem>();
        for (Opportunity opp : opps) {
            if (opp.AccountId == null) throw new IllegalArgumentException('AccountId da Oportunidade não deve ser null.');
            if (opp.Corretor__c == null) throw new IllegalArgumentException('Corretor da Oportunidade não deve ser null.');
            if (opp.OwnerId == null) throw new IllegalArgumentException('Owner da Oportunidade não deve ser null.');
            if (opp.Account.PersonEmail == null) throw new IllegalArgumentException('Email de Account da Oportunidade não deve ser null.');
            if (opp.Corretor__r.Email == null) throw new IllegalArgumentException('Email do Corretor da Oportunidade não deve ser null.');
            if (opp.Owner.Email == null) throw new IllegalArgumentException('Email do Owner da Oportunidade não deve ser null.');

            AnaliseCredito__c analise = analisePorOpp.get(opp.Id);
            
            List<String> emails = new List<String> { opp.Account.PersonEmail, opp.Corretor__r.Email, opp.Owner.Email };
            List<Id> parentsId = new List<Id>{ opp.OwnerId, opp.Corretor__c, opp.AccountId };

            String message;
            if (analise.Status__c == 'Aprovada') {
                message = 'A Análise crédito '+analise.Name+' foi aprovada com sucesso!';
            } else if (analise.Status__c == 'Reprovada') {
                message = 'A Análise crédito '+analise.Name+' foi reprovada';
            }

            for (Id parentId : parentsId) {
                feeds.add(
                    new FeedItem(
                        ParentId = parentId, 
                        Body = message
                    )
                );
            }

            for (String email : emails) {
                EmailManager.sendMail(email, 'Status Análise Crédito', message);
            }
        }
        if (!feeds.isEmpty()) {
            insert feeds;            
        }
    }

}