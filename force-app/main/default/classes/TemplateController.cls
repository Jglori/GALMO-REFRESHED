public with sharing class TemplateController {
    
    @AuraEnabled(cacheable=true)
    public static List<TemplateDocumento__c> getTemplates(String oppId) {
        Opportunity opp = OpportunityDA.getById(oppId);
        if (opp == null) throw new IllegalArgumentException('Oportunidade não encontrado com esse ID');
        List<TemplateDocumento__c> templates = TemplateSelector.getTemplatesByEmpId(opp.Empreendimento__c);
        
        return templates;
    }
    
}