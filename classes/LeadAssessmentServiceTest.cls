@IsTest
public with sharing class LeadAssessmentServiceTest {
    @TestSetup
    public static void setup(){
        Lead_Assessment_Type__c type = new Lead_Assessment_Type__c();
        type.Record_Type__c = 'B2C Housing Sales';
        insert type;

        Lead_Assessment_Rule__c rule = new Lead_Assessment_Rule__c();
        rule.Lead_Assessment_Type__c = type.Id;

        insert rule;

        Lead_Assessment_Query__c query = new Lead_Assessment_Query__c();
        query.Query_Piece__c = 'Name';
        query.Condition_Name__c = 'test condition';
        insert query;

        Lead_Assessment_Condition__c condition = new Lead_Assessment_Condition__c();
        condition.Lead_Assessment_Rule__c = rule.Id;
        condition.Lead_Assessment_Query__c = query.Id;
        condition.Condition_Filter__c = '=';
        condition.Condition_Value__c = 'Ryszard';
        insert condition;

    }
    @IsTest
    public static void verifyQueriesTest(){
        Lead_Assessment_Rule__c rule = [SELECT Id FROM Lead_Assessment_Rule__c];
        System.assert(LeadAssessmentService.verifyQueriesAndActions(rule.Id) != null);
    }
}