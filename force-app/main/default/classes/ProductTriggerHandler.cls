public with sharing class ProductTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        ProductHelper.validateLimitOfVagas((List<Product2>) Trigger.new); 
    }
    
    public override void beforeUpdate() {
        ProductHelper.validateLimitOfVagas((List<Product2>) Trigger.new);
    }
}