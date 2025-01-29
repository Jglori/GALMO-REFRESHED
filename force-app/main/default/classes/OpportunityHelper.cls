public with sharing class OpportunityHelper {

    private static Map<String, String> mandatoryFields = new Map<String, String>{
        'Amount' => 'Valor da Oportunidade',
        'AccountId' => 'Conta',
        'Name' => 'Nome da Oportunidade',
        'Probability' => 'Probabilidade',
        'CanalAtendimento__c' => 'Canal de Atendimento',
        'TipoVenda__c' => 'Tipo de Venda'
    };

    private static Set<String> validStagesAfterFichaCadastral = new Set<String>{
        'Pré-análise',
        'Geração de Contrato',
        'Conferência',
        'Pagadoria',
        'Fechado Ganho/Desistência'
    };

    public static List<Opportunity> getByIds(Set<Id> ids) {
        if (ids == null) throw new IllegalArgumentException('A lista de ids não deve null.');

        List<Opportunity> opps = OpportunityDA.getAllById(ids);
        
        if (opps == null || opps.isEmpty()) throw new IllegalArgumentException('Nenhum registro de opportunidade encontrado.');
        
        return opps;
    }


    public static void addDaysToCloseDateOnCreation(List<Opportunity> newOpps) {
            for (Opportunity opp : newOpps) {
                opp.CloseDate = Date.today().addDays(5);
            }
        }


    public static void validateTransitionToFichaCadastral(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
        for (Opportunity newOpp : newOpportunities) {
            Opportunity oldOpp = oldOpportunitiesMap.get(newOpp.Id);
            
            if (oldOpp.StageName != 'Negociação' || newOpp.StageName != 'Ficha Cadastral') continue;

            boolean hasSyncedQuote = OpportunityDA.hasSyncedQuote(newOpp.Id);
            boolean hasProducts = hasProducts(newOpp.Id);
            boolean hasBuyers = hasBuyers(newOpp.Id);

            for (String fieldName : mandatoryFields.keySet()) {
                if (newOpp.get(fieldName) == null || String.isBlank(String.valueOf(newOpp.get(fieldName)))) {
                    newOpp.addError(mandatoryFields.get(fieldName) + ' é um campo obrigatório.');
                }
            }

            if (!hasSyncedQuote || !hasProducts || !hasBuyers) {
                String errorMessage = 'Não é possível avançar para a Ficha Cadastral:';
                if (!hasSyncedQuote) {
                    errorMessage += '\n- Favor sincronizar uma cotação com a oportunidade.';
                }
                if (!hasProducts) {
                    errorMessage += '\n- Pelo menos um produto da oportunidade deve ser adicionado.';
                }
                if (!hasBuyers) {
                    errorMessage += '\n- Pelo menos um comprador (papel de contato) deve ser especificado.';
                }
                newOpp.addError(errorMessage);
            }
        }
    }

    @TestVisible
    private static boolean hasProducts(Id opportunityId) {
        try {
            List<OpportunityLineItem> lineItems = OpportunityDA.getOpportunityLineItems(opportunityId);
            return !lineItems.isEmpty();
        } catch (Exception e) {
            return false;
        }
    }

    @TestVisible
    private static boolean hasBuyers(Id opportunityId) {
        try {
            List<OpportunityContactRole> contactRoles = OpportunityDA.getOpportunityContactRoles(opportunityId);
            return !contactRoles.isEmpty();
        } catch (Exception e) {
            return false;
        }
    }

    public static void handleBeforeUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOpps.get(newOpp.Id);

            if (!String.isBlank(newOpp.SyncedQuoteId)) {
                Boolean isEmpreendimentoChanged = newOpp.Empreendimento__c != oldOpp.Empreendimento__c;

                if (isEmpreendimentoChanged) {
                    newOpp.addError('Não é possível editar o campo Empreendimento enquanto a oportunidade está sincronizada com uma cotação. Desative a sincronização para editar.');
                }
            }
        }
        
    }
    
    public static void handleStageFichaCadastralChangeFarolColor(
        List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap
    ) {
        if (newOpps == null || newOpps.isEmpty() || oldOppMap == null || oldOppMap.isEmpty()) {
            throw new IllegalArgumentException('A lista de Oportunidades não deve ser nula ou vazia.');
        }

        Set<Id> oppIdsToProcess = new Set<Id>();
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            if (oldOpp != null && 'Ficha Cadastral'.equals(oldOpp.StageName)) {
                oppIdsToProcess.add(newOpp.Id);
            }
        }
        if (oppIdsToProcess.isEmpty()) return;

        Map<Id, List<String>> oppToRolesMap = new Map<Id, List<String>>();
        for (OpportunityContactRole cr : [
            SELECT OpportunityId, Role FROM OpportunityContactRole 
            WHERE OpportunityId IN :oppIdsToProcess AND Role != null
        ]) {
            if (!oppToRolesMap.containsKey(cr.OpportunityId)) {
                oppToRolesMap.put(cr.OpportunityId, new List<String>());
            }
            oppToRolesMap.get(cr.OpportunityId).add(cr.Role);
        }

        if(oppToRolesMap.isEmpty()) {
            for (Opportunity opp : newOpps) {
                opp.FarolChecklistDocumento__c = 'Vermelho';
            }
        }


        Map<String, List<Documento__mdt>> roleToDocumentsMap = new Map<String, List<Documento__mdt>>();
        for (Documento__mdt doc : [
            SELECT Nome_do_Documento__c, Obrigatorio__c, Papel__c FROM Documento__mdt
        ]) {
            if (!roleToDocumentsMap.containsKey(doc.Papel__c)) {
                roleToDocumentsMap.put(doc.Papel__c, new List<Documento__mdt>());
            }
            roleToDocumentsMap.get(doc.Papel__c).add(doc);
        }

        Map<Id, List<Checklist_de_Documentos__c>> oppToDocumentsMap = new Map<Id, List<Checklist_de_Documentos__c>>();
        for (Checklist_de_Documentos__c checklistDoc : ChecklistDA.getWithDocumentsByOpportunity(oppIdsToProcess)) {
            if (!oppToDocumentsMap.containsKey(checklistDoc.Oportunidade__c)) {
                oppToDocumentsMap.put(checklistDoc.Oportunidade__c, new List<Checklist_de_Documentos__c>());
            }
            oppToDocumentsMap.get(checklistDoc.Oportunidade__c).add(checklistDoc);
        }
    
        for (Opportunity newOpp : newOpps) {
            if (!oppIdsToProcess.contains(newOpp.Id)) continue;
    
            Integer totalMandatoryCount = 0;
            Integer totalOptionalCount = 0;
    
            List<String> roles = oppToRolesMap.get(newOpp.Id);
            if (roles != null) {
                for (String role : roles) {
                    List<Documento__mdt> documents = roleToDocumentsMap.get(role);
                    if (documents != null) {
                        for (Documento__mdt doc : documents) {
                            if (doc.Obrigatorio__c) {
                                totalMandatoryCount++;
                            } else {
                                totalOptionalCount++;
                            }
                        }
                    }
                }
            }
    
            Integer deliveredMandatoryCount = 0;
            Integer deliveredOptionalCount = 0;
    
            List<Checklist_de_Documentos__c> documents = oppToDocumentsMap.get(newOpp.Id);
            if (documents != null) {
                for (Checklist_de_Documentos__c checklistDoc : documents) {
                    Documentacao__c doc = checklistDoc.Documenta_o__r;
                    if (doc != null && doc.Entregue__c) {
                        if (doc.Obrigatorio__c) {
                            deliveredMandatoryCount++;
                        } else {
                            deliveredOptionalCount++;
                        }
                    }
                }
            }
    
            if (deliveredMandatoryCount < totalMandatoryCount) {
                newOpp.FarolChecklistDocumento__c = 'Vermelho';
            } else if (deliveredMandatoryCount == totalMandatoryCount &&
                       deliveredMandatoryCount + deliveredOptionalCount < totalMandatoryCount + totalOptionalCount) {
                newOpp.FarolChecklistDocumento__c = 'Verde';
            } else if (deliveredMandatoryCount + deliveredOptionalCount == totalMandatoryCount + totalOptionalCount) {
                newOpp.FarolChecklistDocumento__c = 'Azul';
            }
        }
    }    

    public static void setDefaultChecklistStatus(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            opp.FarolChecklistDocumento__c = 'Vermelho';
        }
    }

    
    public static void handleStageFichaCadastral(List<Opportunity> newOpps) {
        if (newOpps == null || newOpps.isEmpty()) throw new IllegalArgumentException('A lista de Opportunidade não deve ser nula ou vazia.');

        Set<Id> setOppsId = new Set<Id>();
        for (Opportunity opp : newOpps) {
            if (opp.StageName == null ) throw new IllegalArgumentException('Stage de Oportunidade não deve ser null.');
            if (opp.StageName == 'Pré-análise' && opp.FarolChecklistDocumento__c == 'Vermelho') {
                opp.addError('Na fase de Ficha cadastral, precisamos preencher todos os documentos obrigatório no Checklist de documentos!');
            }
        }
    }

    public static List<Opportunity> getByAnaliseCreditoId(Set<Id> analisesCreditoId ) {
        List<Opportunity> opps = OpportunityDA.getAllByAnaliseCreditoId(analisesCreditoId);
        if (opps.isEmpty()) {
            throw new IllegalArgumentException('Nenhuma Oportunidade encontrada! Ids inválidos.');
        }
        return opps;
    }


    public static void handleOpportunityCancelation(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {
        List<Opportunity> opportunitiesToNotify = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();
    
        for (Opportunity opp : newOpps) {
            Opportunity oldOpp = oldOpps.get(opp.Id);
    
            if (opp.StageName == 'Cancelado' && (oldOpp == null || oldOpp.StageName != 'Cancelado')) {
                if (String.isBlank(opp.MotivoCancelamento__c)) {
                    opp.addError('O campo Motivo de Cancelamento é obrigatório.');
                } else if (opp.MotivoCancelamento__c == 'Outros' && String.isBlank(opp.Observacao__c)) {
                    opp.addError('O campo Observação é obrigatório quando o motivo de cancelamento for "Outros".');
                } else {
                    opportunitiesToNotify.add(opp);
                    oppIds.add(opp.Id);
                }
            }
        }
    
        if (!opportunitiesToNotify.isEmpty()) {
            List<Opportunity> oppsWithDetails = [
                SELECT Id, Name, MotivoCancelamento__c, Produto__c, Produto__r.Name,
                       Contato__r.Name, Contato__r.Email, Contato__r.UsuarioCorretor__r.Name,
                       Contato__r.UsuarioCorretor__r.Email
                FROM Opportunity
                WHERE Id IN :oppIds
            ];
    
            Map<Id, Opportunity> oppDetailsMap = new Map<Id, Opportunity>(oppsWithDetails);
    
            for (Opportunity opp : opportunitiesToNotify) {
                if (oppDetailsMap.containsKey(opp.Id)) {
                    Opportunity detailedOpp = oppDetailsMap.get(opp.Id);
                    opp.Produto__c = detailedOpp.Produto__c;
                    opp.Produto__r = detailedOpp.Produto__r;
                    opp.Contato__r = detailedOpp.Contato__r;
                }
            }
    
            sendCancelNotification(opportunitiesToNotify);
        }
    }
    
    
    private static void sendCancelNotification(List<Opportunity> opportunitiesToNotify) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<FeedItem> chatterFeedItems = new List<FeedItem>();
    
       
        EmailTemplate emailTemplate = [SELECT Id, Name, HtmlValue FROM EmailTemplate WHERE Name = 'Template Cancelamento da Oportunidade' LIMIT 1];
    
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity opp : opportunitiesToNotify) {
            if (opp.OwnerId != null) {
                ownerIds.add(opp.OwnerId);
            }
        }
    
        Map<Id, User> ownersMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id IN :ownerIds]);
    
        for (Opportunity opp : opportunitiesToNotify) {
            String subject = 'Notificação de Cancelamento da Oportunidade: ' + opp.Name;
    
           
            FeedItem feedItem = new FeedItem();
            feedItem.ParentId = opp.Id;
            feedItem.Body = 'A Oportunidade ' + opp.Name + ' desistiu do produto '
                            + (opp.Produto__r != null ? opp.Produto__r.Name : 'N/A')
                            + ' pelo motivo ' + opp.MotivoCancelamento__c
                            + '. Observação: ' + (opp.Observacao__c != null ? opp.Observacao__c : 'N/A') + '.';
            chatterFeedItems.add(feedItem);
    
           
            String htmlBody = emailTemplate.HtmlValue;
            if (htmlBody != null) {
                htmlBody = htmlBody.replace('{{{Opportunity.Name}}}', opp.Name != null ? opp.Name : 'N/A');
                htmlBody = htmlBody.replace('{{{Product2.Name}}}', opp.Produto__r != null ? opp.Produto__r.Name : 'N/A');
                htmlBody = htmlBody.replace('{{{Opportunity.MotivoCancelamento__c}}}', opp.MotivoCancelamento__c != null ? opp.MotivoCancelamento__c : 'N/A');
                htmlBody = htmlBody.replace('{{{Opportunity.Observacao__c}}}', opp.Observacao__c != null ? opp.Observacao__c : 'N/A');
            }
     
            
            if (opp.OwnerId != null && ownersMap.containsKey(opp.OwnerId)) {
                User owner = ownersMap.get(opp.OwnerId);
                if (owner.Email != null) {
                    Messaging.SingleEmailMessage emailToOwner = new Messaging.SingleEmailMessage();
                    emailToOwner.setToAddresses(new String[] {owner.Email});
                    emailToOwner.setSubject(subject);
                    emailToOwner.setHtmlBody(htmlBody); 
                    emailsToSend.add(emailToOwner);
                }
            }
    
      
            if (opp.Contato__r != null && opp.Contato__r.Email != null) {
                Messaging.SingleEmailMessage emailToContact = new Messaging.SingleEmailMessage();
                emailToContact.setToAddresses(new String[] {opp.Contato__r.Email});
                emailToContact.setSubject(subject);
                emailToContact.setHtmlBody(htmlBody); 
                emailsToSend.add(emailToContact);
            }
        }
    
        
        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend);
            } catch (Exception e) {
                System.debug('Erro ao enviar e-mails: ' + e.getMessage());
            }
        }
    
       
        if (!chatterFeedItems.isEmpty()) {
            try {
                insert chatterFeedItems;
            } catch (Exception e) {
                System.debug('Erro ao inserir mensagens no Chatter: ' + e.getMessage());
            }
        }
    }
    
    
    

 
    public static void handleOpportunityUpdate(List<Opportunity> updatedOpportunities) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Date today = System.today();
    
        for (Opportunity opp : updatedOpportunities) {
            if (opp.StageName == 'Conferência') {
                if (opp.Data_Assinatura_Contrato__c != null && opp.Dias_Apos_Assinatura__c != null) {
                    Date assinaturaData = opp.Data_Assinatura_Contrato__c;
                    Integer diasAposAssinatura = Integer.valueOf(opp.Dias_Apos_Assinatura__c);  
                    Date dataLimite = assinaturaData.addDays(diasAposAssinatura);
    
                    if (dataLimite <= today) {
                        Opportunity oppToUpdate = new Opportunity(Id = opp.Id, StageName = 'Ganho');
                        opportunitiesToUpdate.add(oppToUpdate);
                    }
                }
            }
        }
    
        
        if (!opportunitiesToUpdate.isEmpty()) {
            try {
                update opportunitiesToUpdate;
                System.debug('Oportunidades movidas para "Ganho".');
                sendVictoryNotification(opportunitiesToUpdate);
            } catch (Exception e) {
                System.debug('Erro ao atualizar oportunidades: ' + e.getMessage());
            }
        }
    }
    
    private static void sendVictoryNotification(List<Opportunity> opportunitiesToNotify) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<FeedItem> chatterFeedItems = new List<FeedItem>();
    
      
        EmailTemplate emailTemplate = [SELECT Id, Name, HtmlValue FROM EmailTemplate WHERE Name = 'Template Vitoria da Oportunidade' LIMIT 1];
    
        if (emailTemplate == null) {
            System.debug('Template de E-mail não encontrado.');
            return; 
        }
    
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity opp : opportunitiesToNotify) {
            opportunityIds.add(opp.Id);
        }
    
      
        List<Opportunity> opportunitiesWithDetails = [
            SELECT Id, Name, Produto__r.Name, Observacao__c, OwnerId, Contato__r.Email 
            FROM Opportunity 
            WHERE Id IN :opportunityIds
        ];
    
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity opp : opportunitiesWithDetails) {
            if (opp.OwnerId != null) {
                ownerIds.add(opp.OwnerId);
            }
        }
    
        Map<Id, User> ownersMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id IN :ownerIds]);
    
        for (Opportunity opp : opportunitiesWithDetails) {
            String subject = 'Notificação de Vitória da Oportunidade: ' + opp.Name;
    
           
            FeedItem feedItem = new FeedItem();
            feedItem.ParentId = opp.Id;
            feedItem.Body = 'A Oportunidade ' + opp.Name + ' foi vencida com o produto '
                            + (opp.Produto__r != null ? opp.Produto__r.Name : 'N/A')
                            + '. Observação: ' + (opp.Observacao__c != null ? opp.Observacao__c : 'N/A') + '.';
            chatterFeedItems.add(feedItem);
    
          
            String htmlBody = emailTemplate.HtmlValue;
            if (htmlBody != null) {
                htmlBody = htmlBody.replace('{{{Opportunity.Name}}}', opp.Name != null ? opp.Name : 'N/A');
                htmlBody = htmlBody.replace('{{{Product2.Name}}}', opp.Produto__r != null ? opp.Produto__r.Name : 'N/A');
                htmlBody = htmlBody.replace('{{{Opportunity.Observacao__c}}}', opp.Observacao__c != null ? opp.Observacao__c : 'N/A');
            }
    
         
            if (opp.OwnerId != null && ownersMap.containsKey(opp.OwnerId)) {
                User owner = ownersMap.get(opp.OwnerId);
                if (owner.Email != null) {
                    Messaging.SingleEmailMessage emailToOwner = new Messaging.SingleEmailMessage();
                    emailToOwner.setToAddresses(new String[] {owner.Email});
                    emailToOwner.setSubject(subject);
                    emailToOwner.setHtmlBody(htmlBody); 
                    emailsToSend.add(emailToOwner);
                }
            }
    
          
            if (opp.Contato__r != null && opp.Contato__r.Email != null) {
                Messaging.SingleEmailMessage emailToContact = new Messaging.SingleEmailMessage();
                emailToContact.setToAddresses(new String[] {opp.Contato__r.Email});
                emailToContact.setSubject(subject);
                emailToContact.setHtmlBody(htmlBody); 
                emailsToSend.add(emailToContact);
            }
        }
    
    
        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend);
                System.debug('E-mails enviados com sucesso.');
            } catch (Exception e) {
                System.debug('Erro ao enviar e-mails: ' + e.getMessage());
            }
        }
    
        
        if (!chatterFeedItems.isEmpty()) {
            try {
                insert chatterFeedItems;
                System.debug('Mensagens no Chatter inseridas com sucesso.');
            } catch (Exception e) {
                System.debug('Erro ao inserir mensagens no Chatter: ' + e.getMessage());
            }
        }
    }
}