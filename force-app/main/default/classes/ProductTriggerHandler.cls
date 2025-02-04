public with sharing class ProductTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        ProductHelper.validateLimitOfVagas((List<Product2>) Trigger.new); 
    }
    
    public override void beforeUpdate() {
        ProductHelper.validateLimitOfVagas((List<Product2>) Trigger.new);
    }

    public override void afterInsert() {
        
        NotificacaoHelper.notificacaoEquipeVendas((List<Product2>)Trigger.new);
    }

    public override void afterUpdate() {
        for (Product2 produto : (List<Product2>) Trigger.new) {
            Product2 oldProduto = (Product2) Trigger.oldMap.get(produto.Id); 

            if (produto.Status__c != oldProduto.Status__c) {

                NotificacaoHelper.notificacaoEquipeVendas((List<Product2>)Trigger.new);
                NotificacaoHelper.notificacaoCliente((List<Product2>)Trigger.new);
            }
        }
        
    }
}