public class ChecklistHelper {

    private class DocumentCounts {
        Integer totalMandatory = 0;
        Integer totalOptional = 0;
        Integer deliveredMandatory = 0;
        Integer deliveredOptional = 0;
    }

    public static void updateOpportunityChecklistStatus(List<Checklist_de_Documentos__c> checklists) {
        if (checklists == null || checklists.isEmpty()) {
            return;
        }

        Set<Id> opportunityIds = collectOpportunityIds(checklists);
        if (opportunityIds.isEmpty()) return;

        Map<Id, Opportunity> opportunities = fetchOpportunities(opportunityIds);
        Map<Id, List<String>> oppToRolesMap = fetchOpportunityContactRoles(opportunityIds);
        Map<String, List<Documento__mdt>> roleToDocumentsMap = fetchDocumentMetadataByRole();
        Map<Id, List<Checklist_de_Documentos__c>> oppToChecklistsMap = fetchChecklistsByOpportunity(opportunityIds);

        List<Opportunity> opportunitiesToUpdate = processOpportunities(
            opportunityIds, opportunities, oppToRolesMap, roleToDocumentsMap, oppToChecklistsMap
        );

        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }

    private static Set<Id> collectOpportunityIds(List<Checklist_de_Documentos__c> checklists) {
        Set<Id> opportunityIds = new Set<Id>();
        for (Checklist_de_Documentos__c checklist : checklists) {
            if (checklist.Oportunidade__c != null) {
                opportunityIds.add(checklist.Oportunidade__c);
            }
        }
        return opportunityIds;
    }

    private static Map<Id, Opportunity> fetchOpportunities(Set<Id> opportunityIds) {
        return new Map<Id, Opportunity>([
            SELECT Id, FarolChecklistDocumento__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ]);
    }

    private static Map<Id, List<String>> fetchOpportunityContactRoles(Set<Id> opportunityIds) {
        Map<Id, List<String>> oppToRolesMap = new Map<Id, List<String>>();
        for (OpportunityContactRole role : [
            SELECT OpportunityId, Role 
            FROM OpportunityContactRole 
            WHERE OpportunityId IN :opportunityIds ]) {
                Id oppId = role.OpportunityId;
                if (!oppToRolesMap.containsKey(oppId)) {
                    oppToRolesMap.put(oppId, new List<String>());
                }
                oppToRolesMap.get(oppId).add(role.Role);
            }
            return oppToRolesMap;
    }

    private static Map<String, List<Documento__mdt>> fetchDocumentMetadataByRole() {
        Map<String, List<Documento__mdt>> roleToDocumentsMap = new Map<String, List<Documento__mdt>>();

        for (Documento__mdt doc : [SELECT Papel__c, Obrigatorio__c FROM Documento__mdt]) {
            String role = doc.Papel__c;
            if(!roleToDocumentsMap.containsKey(role)) {
                roleToDocumentsMap.put(role, new List<Documento__mdt>());
            }
            roleToDocumentsMap.get(role).add(doc);
        }
        return roleToDocumentsMap;
    }

    private static Map<Id, List<Checklist_de_Documentos__c>> fetchChecklistsByOpportunity(Set<Id> opportunityIds) {
        Map<Id, List<Checklist_de_Documentos__c>> oppToChecklistsMap = new Map<Id, List<Checklist_de_Documentos__c>>();
        for (Checklist_de_Documentos__c checklist : [
            SELECT Oportunidade__c, Documenta_o__r.Obrigatorio__c, Documenta_o__r.Entregue__c
            FROM Checklist_de_Documentos__c
            WHERE Oportunidade__c IN :opportunityIds
        ]) {
            Id oppId = checklist.Oportunidade__c;
            if (!oppToChecklistsMap.containsKey(oppId)) {
                oppToChecklistsMap.put(oppId, new List<Checklist_de_Documentos__c>());
            }
            oppToChecklistsMap.get(oppId).add(checklist);
        }
        return oppToChecklistsMap;
    }

    private static List<Opportunity> processOpportunities(
        Set<Id> opportunityIds,
        Map<Id, Opportunity> opportunities,
        Map<Id, List<String>> oppToRolesMap,
        Map<String, List<Documento__mdt>> roleToDocumentsMap,
        Map<Id, List<Checklist_de_Documentos__c>> oppToChecklistsMap
    ) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Id oppId : opportunityIds) {
            Opportunity opp = opportunities.get(oppId);
            List<Checklist_de_Documentos__c> checklists = oppToChecklistsMap.get(oppId);
            
            if (opp == null || checklists == null || checklists.isEmpty()) continue;

            DocumentCounts counts = calculateDocumentCounts(
                oppToRolesMap.get(oppId),
                roleToDocumentsMap,
                checklists
            );

            String newStatus = determineStatus(counts);
            if (newStatus != opp.FarolChecklistDocumento__c) {
                opp.FarolChecklistDocumento__c = newStatus;
                opportunitiesToUpdate.add(opp);
            }
        }
        return opportunitiesToUpdate;
    }

    private static DocumentCounts calculateDocumentCounts(
        List<String> roles,
        Map<String, List<Documento__mdt>> roleToDocumentsMap,
        List<Checklist_de_Documentos__c> checklists
    ) {
        DocumentCounts counts = new DocumentCounts();
        if (roles != null) {
            for (String role : roles) {
                List<Documento__mdt> docs = roleToDocumentsMap.get(role);
                if (docs != null) {
                    for (Documento__mdt doc : docs) {
                        if (doc.Obrigatorio__c) {
                            counts.totalMandatory++;
                        } else {
                            counts.totalOptional++;
                        }
                    }
                }
            }
        }

        for (Checklist_de_Documentos__c checklist : checklists) {
            if (checklist.Documenta_o__r == null) continue;

            Boolean isMandatory = checklist.Documenta_o__r.Obrigatorio__c;
            Boolean isDelivered = checklist.Documenta_o__r.Entregue__c;

            if (isMandatory && isDelivered) {
                counts.deliveredMandatory++;
            } else if (!isMandatory && isDelivered) {
                counts.deliveredOptional++;
            }
        }
        return counts;
    }

    private static String determineStatus(DocumentCounts counts) {
        Integer totalDocuments = counts.totalMandatory + counts.totalOptional;
        Integer deliveredDocuments = counts.deliveredMandatory + counts.deliveredOptional;

        if (counts.deliveredMandatory < counts.totalMandatory) {
            return 'Vermelho';
        } else if (deliveredDocuments < totalDocuments) {
            return 'Verde';
        } else {
            return 'Azul';
        }
    }

    public static List<Checklist_de_Documentos__c> getByOpportunityId(Set<Id> opportunitiesId) {        
        List<Checklist_de_Documentos__c> checklists = ChecklistDA.getWithDocumentsByOpportunity( opportunitiesId );
        if (checklists.isEmpty()) throw new IllegalArgumentException('Nenhum Checklist de Documentos encontrada.');

        return checklists;
    }

    public static List<Checklist_de_Documentos__c> getByAnaliseCredito(Id analiseCreditoId) {
        List<Opportunity> opps = OpportunityDA.getByAnaliseCreditoId(analiseCreditoId);
        if (opps.isEmpty()) throw new IllegalArgumentException('Nenhuma Oportunidade relacionada à Análise de Crédito: '+ analiseCreditoId);

        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }

        List<Checklist_de_Documentos__c> checklists = ChecklistDA.getWithDocumentsByOpportunity( oppIds );
        if (checklists.isEmpty()) throw new IllegalArgumentException('Nenhum Checklist de Documentos encontrada.');

        return checklists;
    }
    
    public static Map<Id, List<Documento__mdt>> verifyMissingDocs(List<Opportunity> opps) {
        Set<Id> oppsIds = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE ProcessoAprovacao__c = true]).keySet();
    
        if (oppsIds.isEmpty()) {
            return null;
        }
    
        List<OpportunityContactRole> contactRoles = [
            SELECT ContactId, Role 
            FROM OpportunityContactRole 
            WHERE OpportunityId IN :oppsIds AND Role != null
        ];
        
        Map<Id, Set<String>> crFromOpp = new Map<Id, Set<String>>();
        for (OpportunityContactRole contactRole : contactRoles) {
            if (!crFromOpp.containsKey(contactRole.ContactId)) {
                crFromOpp.put(contactRole.ContactId, new Set<String>());
            } 
            crFromOpp.get(contactRole.ContactId).add(contactRole.Role);
        }
    
        Set<String> allRoles = new Set<String>();
        for (Set<String> roles : crFromOpp.values()) {
            allRoles.addAll(roles);
        }
    
        Map<String, List<Documento__mdt>> docParamsToEachDoc = new Map<String, List<Documento__mdt>>();
        for (Documento__mdt mtdDoc : [SELECT Nome_do_Documento__c, Papel__c FROM Documento__mdt WHERE Papel__c IN :allRoles]) {
            if (!docParamsToEachDoc.containsKey(mtdDoc.Papel__c)) {
                docParamsToEachDoc.put(mtdDoc.Papel__c, new List<Documento__mdt>());
            }
            docParamsToEachDoc.get(mtdDoc.Papel__c).add(mtdDoc);
        }
    
        Map<Id, Set<String>> currentDocsByContact = new Map<Id, Set<String>>();
        List<Checklist_de_Documentos__c> relatedChecklists = [
            SELECT Documenta_o__r.Contato__c, Documenta_o__r.Name 
            FROM Checklist_de_Documentos__c 
            WHERE Oportunidade__c IN :oppsIds
        ];
    
        for (Checklist_de_Documentos__c checklist : relatedChecklists) {
            Id contactId = checklist.Documenta_o__r.Contato__c;
            if (!currentDocsByContact.containsKey(contactId)) {
                currentDocsByContact.put(contactId, new Set<String>());
            }
            currentDocsByContact.get(contactId).add(checklist.Documenta_o__r.Name);
        }
    
        Map<Id, List<Documento__mdt>> missingDocsForEachContact = new Map<Id, List<Documento__mdt>>();
        for (Id contactId : crFromOpp.keySet()) {
            Set<String> roles = crFromOpp.get(contactId);
            Set<String> currentDocs = currentDocsByContact.containsKey(contactId) ? currentDocsByContact.get(contactId) : new Set<String>();
    
            List<Documento__mdt> missingDocs = new List<Documento__mdt>();
            for (String role : roles) {
                if (docParamsToEachDoc.containsKey(role)) {
                    for (Documento__mdt requiredDoc : docParamsToEachDoc.get(role)) {
                        if (!currentDocs.contains(requiredDoc.Nome_do_Documento__c)) {
                            missingDocs.add(requiredDoc);
                        }
                    }
                }
            }
    
            if (!missingDocs.isEmpty()) {
                missingDocsForEachContact.put(contactId, missingDocs);
            }
        }
    
        return missingDocsForEachContact;
    }

}