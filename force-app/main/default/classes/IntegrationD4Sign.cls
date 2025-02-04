public with sharing class IntegrationD4Sign {

    public static String getProductionURL() {
        return 'https://secure.d4sign.com.br/api/v1';
    }

    @AuraEnabled(cacheable=true)
    public static String getProductionCreateUrl() {
        return 'https://secure.d4sign.com.br/criar.html';
    }
    
    @AuraEnabled(cacheable=true)
    public static String getSandboxURL() {
        return 'https://sandbox.d4sign.com.br/api/v1';
    }
    
    @AuraEnabled(cacheable=true)
    public static String getSanboxCreateUrl() {
        return 'https://sandbox.d4sign.com.br/criar.html';
    }
}