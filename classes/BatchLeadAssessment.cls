public with sharing class BatchLeadAssessment implements Database.Batchable<SObject>, Database.AllowsCallouts{
    public Iterable<SObject> start(Database.BatchableContext info) {
        try{
            List<Lead_Assessment_Rule__c> rules = LeadAssessmentService.getAllAssessmentRules();
            return (Iterable<SObject>)LeadAssessmentService.getSimpleQueryLeadsMap(rules)?.values();
        }catch(Exception e){
            LeadAssessmentService.insertBasicErrorLog(e.getMessage());
            return null;
        }
    }

    public void execute(Database.BatchableContext info, List<Lead> leadScope) {
        List<LeadAssessmentService.RuleWrapper> ruleWrappers = LeadAssessmentService.generateRuleWrappers(leadScope);
        List<LeadAssessmentService.PostAssessmentWrapper> assessmentWrappers = LeadAssessmentService.generatePostAssessmentWrappers(ruleWrappers, leadScope);
        LeadAssessmentService.executePostAssessmentLogic(assessmentWrappers);
    }

    public void finish(Database.BatchableContext info) {
        System.abortJob([SELECT Id
                         FROM CronTrigger
                         WHERE CronJobDetail.Name = :Utils.BATCH_LEAD_ASSESSMENT_SCHEDULER]?.Id);
        System.schedule(
                Utils.BATCH_LEAD_ASSESSMENT_SCHEDULER,
                LeadAssessmentService.getNextScheduleExecutionTime(),
                new BatchLeadAssessmentScheduler());
    }
}