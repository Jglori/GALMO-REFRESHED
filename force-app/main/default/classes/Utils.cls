public with sharing class Utils {

    @AuraEnabled(cacheable=true)
    public static List<PicklistValueDto> getPicklistValues(String objName, String fieldApi) {

        List<PicklistValueDto> pvd = new List<PicklistValueDto>();

        SObject instance = (SObject) Type.forName('Schema.' + objName).newInstance();

        Schema.DescribeFieldResult fieldResult = instance.getSObjectType().getDescribe().fields.getMap().get(fieldApi).getDescribe();


        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry f : ple) {
            pvd.add(new PicklistValueDto(f.getLabel(), f.getValue()));
        }
 
        return pvd;
    }

    public class PicklistValueDto {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public PicklistValueDto(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}