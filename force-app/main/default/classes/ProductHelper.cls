public with sharing class ProductHelper {
    public static void validateLimitOfVagas(List<Product2> produtosDeGaragem) {
        Set<Id> garagemIds = new Set<Id>();
        for(Product2 produto : produtosDeGaragem) {
            if(produto.Garagem__c != null) {
                garagemIds.add(produto.Garagem__c);
            }
        }

        Map<Id, Garagem__c> garagensMap = GaragemDA.getGaragens(garagemIds);

        for(Product2 produto : produtosDeGaragem) {
            if(produto.Garagem__c != null && garagensMap.containsKey(produto.Garagem__c)) {
                Garagem__c garagem = garagensMap.get(produto.Garagem__c);
                Integer qtdVagas = GaragemDA.getQuantityVagasGaragem(produto.Garagem__c);

                if(garagem.NumeroVagas__c <= qtdVagas) {
                    produto.addError('O número de vagas excede o limite permitdo para a garagem');
                }
            }
        }
    }
}