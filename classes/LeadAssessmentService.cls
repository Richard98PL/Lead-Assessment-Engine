public without sharing class LeadAssessmentService {
    public final static String LOG_TYPE_ERROR = 'Error';
    public final static String LOG_TYPE_SUCCESS = 'Success';
    private final static String LWC_DATATABLE_SUCCESS_COLOR = 'slds-text-color_success';
    private final static String LWC_DATATABLE_ERROR_COLOR = 'slds-text-color_error';
    private final static String VALID_QUERY_MESSAGE = 'Query is valid';
    private final static String VALID_ACTION_MESSAGE = 'Action is valid';
    private final static String BASIC_QUERY = 'SELECT Id FROM Lead \n WHERE RecordType.Name IN ';
    private final static String WRAPPER_TYPE_QUERY = 'Query';
    private final static String WRAPPER_TYPE_ACTION = 'Action';
    private final static Set<String> BOOLEAN_RELATED_VALUES = new Set<String>{'true', 'false'};
    private static Set<String> LEAD_FIELDS_VALUES = Lead.getSobjectType().getDescribe().fields.getMap().keySet();

    @AuraEnabled(Cacheable=false)
    public static String verifyQueriesAndActions(Id recordId){
        if(recordId == null) return null;
        Lead_Assessment_Rule__c rule = [SELECT Id,
                                               Lead_Assessment_Type__r.Record_Type__c,
                                        (SELECT Id,
                                                Name,
                                                Lead_Assessment_Query__r.Query_Piece__c,
                                                Lead_Assessment_Rule__r.Lead_Assessment_Type__r.Record_Type__c,
                                                Condition_Filter__c,
                                                Condition_Value__c
                                        FROM Lead_Assessment_Conditions__r),
                                        (SELECT Id,
                                                Name,
                                                Lead_Field__c,
                                                Lead_Field_Value__c
                                        FROM Lead_Assessment_Actions__r)
                                        FROM Lead_Assessment_Rule__c WHERE Id = :recordId];

        return JSON.serialize(getWrappers(rule));
    }

    private static List<LWCWrapper> getWrappers(Lead_Assessment_Rule__c rule) {
        List<LWCWrapper> wrappers = new List<LWCWrapper>();
        List<Lead_Assessment_Condition__c> simpleConditions = getSimpleConditions(rule.Lead_Assessment_Conditions__r);
        List<Lead_Assessment_Condition__c> complexConditions = getComplexConditions(rule.Lead_Assessment_Conditions__r);
        String recordTypes = rule.Lead_Assessment_Type__r.Record_Type__c;

        wrappers.add(getSimpleWrapper(simpleConditions, recordTypes));
        wrappers.addAll(getComplexWrappers(complexConditions));
        wrappers.addAll(getActionWrappers(rule.Lead_Assessment_Actions__r));

        return wrappers;
    }

    private static List<LWCWrapper> getActionWrappers(List<Lead_Assessment_Action__c> leadAssessmentActions) {
        List<LWCWrapper> actionWrappers = new List<LWCWrapper>();
        for(Lead_Assessment_Action__c action : leadAssessmentActions){
            actionWrappers.add(generateActionWrapper(action));
        }
        return actionWrappers;
    }

    private static LWCWrapper generateActionWrapper(Lead_Assessment_Action__c action) {
        LWCWrapper wrapper = new LWCWrapper();
        wrapper.type = WRAPPER_TYPE_ACTION;
        wrapper.validation = VALID_ACTION_MESSAGE;
        wrapper.isValid = true;
        wrapper.isSimple = true;
        wrapper.recordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + action.Id;
        wrapper.actionName = action.Name;

        Lead lead = new Lead();
        try {
            lead.put(action.Lead_Field__c, getActionValue(action));
        } catch (Exception e) {
            wrapper.validation = e.getMessage();
            wrapper.isValid = false;
        }

        wrapper.styleFormat = wrapper.isValid ? LWC_DATATABLE_SUCCESS_COLOR : LWC_DATATABLE_ERROR_COLOR;
        return wrapper;
    }

    private static List<LWCWrapper> getComplexWrappers(List<Lead_Assessment_Condition__c> conditions) {
        List<LWCWrapper> complexWrappers = new List<LWCWrapper>();
        for(Lead_Assessment_Condition__c condition : conditions){
            complexWrappers.add(generateComplexConditionWrapper(condition));
        }
        return complexWrappers;
    }

    private static LWCWrapper generateComplexConditionWrapper(Lead_Assessment_Condition__c condition) {
        LWCWrapper wrapper = new LWCWrapper();
        wrapper.type = WRAPPER_TYPE_QUERY;
        wrapper.isSimple = false;
        wrapper.validation = VALID_QUERY_MESSAGE;
        wrapper.isValid = true;
        wrapper.recordLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + condition.Id;
        wrapper.conditionName = condition.Name;
        Integer size = 0;
        wrapper.query = getQuerySize(condition.Lead_Assessment_Query__r.Query_Piece__c, condition);
        try{
            size = Database.countQuery(generateLeadQueryFromCondition(condition));
            validateComplexQuerySize(size, condition);
        }catch(Exception e){
            wrapper.query = generateLeadQueryFromCondition(condition);
            wrapper.validation = e.getMessage();
            wrapper.isValid = false;
        }

        wrapper.rowsReturned = String.valueOf(size);
        wrapper.styleFormat = wrapper.isValid ? LWC_DATATABLE_SUCCESS_COLOR : LWC_DATATABLE_ERROR_COLOR;
        return wrapper;
    }

    private static String getQuerySize(String query, Lead_Assessment_Condition__c leadAssessmentCondition) {
        return '(' + query + ').size() ' +
                leadAssessmentCondition.Condition_Filter__c +
                ' ' +
                leadAssessmentCondition.Condition_Value__c;
    }

    public static Boolean validateComplexQuerySize(Integer listSize, Lead_Assessment_Condition__c leadAssessmentCondition) {
        String filter = leadAssessmentCondition.Condition_Filter__c;
        Integer value = Integer.valueOf(leadAssessmentCondition.Condition_Value__c);
        Boolean checkCondition = false;
        if(filter == Utils.FILTER_EQUALS){
            checkCondition = listSize == value;
        }else if(filter == Utils.FILTERS_NOT_EQUALS){
            checkCondition = listSize != value;
        }else if(filter == Utils.FILTER_GREATER_THAN){
            checkCondition = listSize > value;
        }else if(filter == Utils.FILTER_GREATER_OR_EQUAL_THAN){
            checkCondition = listSize >= value;
        }else if(filter == Utils.FILTER_LESSER_THAN){
            checkCondition = listSize < value;
        }else if(filter == Utils.FILTER_LESSER_OR_EQUAL_THAN){
            checkCondition = listSize <= value;
        }

        return checkCondition;
    }

    private static String generateLeadQueryFromCondition(Lead_Assessment_Condition__c condition) {
        String queryPiece = condition.Lead_Assessment_Query__r.Query_Piece__c;
        List<String> leadFields = getALlLeadKeyFieldsFromQuery(queryPiece);
        Lead lead = new Lead();
        for(String leadKeyField : leadFields){
            lead.put(leadKeyField, '');
            queryPiece = queryPiece.replace('[' + leadKeyField + ']', '\'' + lead.get(leadKeyField) + '\'');
        }
        return queryPiece.replaceFirst('Id', 'COUNT()');
    }

    private static LWCWrapper getSimpleWrapper(List<Lead_Assessment_Condition__c> conditions, String recordTypes) {
        LWCWrapper wrapper = new LWCWrapper();
        wrapper.type = WRAPPER_TYPE_QUERY;
        wrapper.validation = VALID_QUERY_MESSAGE;
        wrapper.isValid = true;
        wrapper.isSimple = true;

        List<SObject> sObjects = new List<SObject>();
        wrapper.query = generateLeadQueryFromConditions(conditions, recordTypes);
        try {
            sObjects = Database.query(wrapper.query);
        } catch (Exception e) {
            wrapper.validation = e.getMessage();
            wrapper.isValid = false;
        }

        wrapper.rowsReturned = String.valueOf(sObjects.size());
        wrapper.styleFormat = wrapper.isValid ? LWC_DATATABLE_SUCCESS_COLOR : LWC_DATATABLE_ERROR_COLOR;
        return wrapper;
    }

    public static List<Lead_Assessment_Condition__c> getComplexConditions(List<Lead_Assessment_Condition__c> conditions) {
        List<Lead_Assessment_Condition__c> complexConditions = new List<Lead_Assessment_Condition__c>();
        for(Lead_Assessment_Condition__c condition : conditions){
            if(condition.Lead_Assessment_Query__r.Query_Piece__c?.contains('SELECT')){
                complexConditions.add(condition);
            }
        }
        return complexConditions;
    }

    public static List<Lead_Assessment_Condition__c> getSimpleConditions(List<Lead_Assessment_Condition__c> conditions) {
        List<Lead_Assessment_Condition__c> simpleConditions = new List<Lead_Assessment_Condition__c>();
        for(Lead_Assessment_Condition__c condition : conditions){
            if(!condition.Lead_Assessment_Query__r.Query_Piece__c?.contains('SELECT')){
                simpleConditions.add(condition);
            }
        }
        return simpleConditions;
    }

    private static String generateLeadQueryFromConditions(List<Lead_Assessment_Condition__c> conditions, String recordTypes) {
        return  BASIC_QUERY +
                getFormattedRecordTypes(recordTypes) +
                generateWhereClauseConditions(conditions);
    }

    private static String getFormattedRecordTypes(String recordTypes) {
        String recordTypesMultiPicklist = recordTypes;
        List<String> eachRecordType = recordTypesMultiPicklist.split(';');
        String parsedRecordTypes = '(';
        for (String recordType : eachRecordType) {
            parsedRecordTypes += ('\'' + recordType + '\',');
        }
        parsedRecordTypes = parsedRecordTypes.removeEnd(',');
        parsedRecordTypes += ')';
        return parsedRecordTypes;
    }

    private static String generateWhereClauseConditions(List<Lead_Assessment_Condition__c> leadAssessmentConditions) {
        if(leadAssessmentConditions != null){
            List<WhereClauseWrapper> whereClauseWrappers = new List<WhereClauseWrapper>();
            String whereClauseConditions = '';
            for(Lead_Assessment_Condition__c condition : leadAssessmentConditions){
                WhereClauseWrapper wrapper = new WhereClauseWrapper();
                wrapper.filter = condition.Condition_Filter__c;
                wrapper.value = condition.Condition_Value__c;
                wrapper.field = condition.Lead_Assessment_Query__r.Query_Piece__c;
                whereClauseWrappers.add(wrapper);
            }

            for(WhereClauseWrapper wrapper : whereClauseWrappers){
                whereClauseConditions += getWhereClauseFromWrapper(wrapper);
            }

            return whereClauseConditions;
        }else{
            return '';
        }
    }

    private static String getWhereClauseFromWrapper(WhereClauseWrapper wrapper) {
        return ' AND \n' + wrapper.field + ' ' + parseFilter(wrapper.filter, wrapper.value);
    }


    private static List<String> getALlLeadKeyFieldsFromQuery(String query) {
        if(query != null){
            List<String> allLeadKeyFieldsFromQuery = new List<String>();
            List<String> characters = query.split('');
            String tmpWord = '';
            Boolean addToTmpWord = false;
            for(String character : characters){
                if(addToTmpWord && character != ']'){
                    tmpWord += character;
                }
                if(character == '['){
                    addToTmpWord = true;
                }
                if(character == ']'){
                    addToTmpWord = false;
                    allLeadKeyFieldsFromQuery.add(tmpWord);
                    tmpWord = '';
                }
            }
            return allLeadKeyFieldsFromQuery;
        }else{
            return new List<String>();
        }
    }

    private static String parseFilter(String filter, String filterValue) {
        if(filter == 'IN'){
            List<String> inValues = filterValue.split(',');
            filterValue = '(';
            for(String value :  inValues){
                filterValue += ('\'' + value + '\',');
            }
            filterValue = filterValue.removeEnd(',');
            filterValue += ')';
        }

        return filter + ' ' + filterValue;
    }

    public static void executePostAssessmentLogic(List<PostAssessmentWrapper> postAssessmentWrappers) {
        try{
            List<Lead> leads = new List<Lead>();
            for(PostAssessmentWrapper wrapper : postAssessmentWrappers){
                Lead lead = wrapper.Lead;
                lead.Lead_Assessment_Rule__c = wrapper.ruleId;

                for(Lead_Assessment_Action__c action : wrapper.actions){
                    lead.put(action.Lead_Field__c, getActionValue(action));
                }
                leads.add(lead);
            }

            if(leads.size() <= 10){
                synchronizeWithLeadDistributor(leads);
                update leads;
            }else{
                insert new Lead_Assessment_Log__c(
                        Message__c = 'Leads batch size is ' +
                                String.valueOf(leads.size()) +
                                '.\n Maximum callouts number in Batch is 10.',
                        Type__c = LOG_TYPE_ERROR
                );
            }
        }catch(Exception e){
            insertBasicErrorLog(e.getMessage());
        }
    }

    private static void synchronizeWithLeadDistributor(List<Lead> leads) {
        List<Lead_Assessment_Log__c> logs = new List<Lead_Assessment_Log__c>();
        for(Lead lead : leads){
            String requestBody = generateLeadDistributorRequestBody(lead);
            String endpoint = getLeadDistributorEndpoint();
            HttpRequest req = createAzureRequest(leads.size(), requestBody, endpoint);
            HTTPResponse res = new Http().send(req);

            logs.add(new Lead_Assessment_Log__c(
                Message__c = getAzureIntegrationLogMessage(lead.Id,res, requestBody, endpoint),
                Type__c = res.getStatusCode() < 200 || res.getStatusCode() >= 300 ? LOG_TYPE_ERROR : LOG_TYPE_SUCCESS
            ));
        }
        insert logs;
    }

    public static void insertBasicErrorLog(String errorMessage){
        insert new Lead_Assessment_Log__c(
                Message__c = errorMessage,
                Type__c = LeadAssessmentService.LOG_TYPE_ERROR
        );
    }

    private static HttpRequest createAzureRequest(Integer batchSize, String requestBody, String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader(Utils.AZURE_KEY_HEADER, Utils.NAMED_CREDENTIAL_PASSWORD);
        req.setHeader(Utils.CONTENT_TYPE, Utils.APPLICATION_JSON);
        Integer timeoutDivider = Math.min(Utils.MAXIMUM_CALLOUTS_IN_BATCH, batchSize);
        req.setTimeout((Utils.ASYNC_TRANSACTION_TIME/timeoutDivider)/2);
        req.setMethod(Utils.POST_METHOD);
        req.setBody(requestBody);
        return req;
    }


    private static String getAzureIntegrationLogMessage(Id leadId, HttpResponse httpResponse, String requestBody, String endpoint) {
        return  'leadId: ' + leadId +
                '\nrequestBody: \n' + requestBody.replaceAll(',',',\n') +
                '\nstatusCode: ' + httpResponse.getStatusCode() +
                '\nstatusBody: ' + httpResponse.getBody() +
                '\nendpoint: ' + endpoint;
    }

    public static String generateLeadDistributorRequestBody(Lead lead) {
        LeadAzureIntegrationWrapper wrapper = new LeadAzureIntegrationWrapper();
        String serializedWrapper = JSON.serialize(wrapper);
        Map<String,Object> serializedWrapperMap =  (Map<String,Object>) JSON.deserializeUntyped(serializedWrapper);
        Map<String,String> azureFieldToSalesforceField = getAzureFieldToSalesforceFieldMap();
        for(String azureField : azureFieldToSalesforceField.keySet()){
            String salesforceField = azureFieldToSalesforceField.get(azureField);
            if(LEAD_FIELDS_VALUES.contains(salesforceField?.toLowerCase().replaceAll('!',''))){
                serializedWrapperMap.put(azureField, parseLeadFieldValue(lead,salesforceField,azureField,serializedWrapperMap));
            }
        }
        return JSON.serialize(serializedWrapperMap);
    }

    private static Map<String, String> getAzureFieldToSalesforceFieldMap() {
        Map<String,String> azureFieldToSalesforceField = new Map<String,String>();
        Set<String> azureWrapperFields = new Set<String>();
        for(SObjectField field: Azure_B2C_Lead_Integration_Fields__mdt.sobjectType.getDescribe().fields.getMap().values()) {
            if(field.getDescribe().isCustom()){
                azureWrapperFields.add(String.valueOf(field));
            }
        }

        Azure_B2C_Lead_Integration_Fields__mdt customMetadataInstance =
                Azure_B2C_Lead_Integration_Fields__mdt.getInstance(Utils.AZURE_B2C_LEAD_INTEGRATION_CUSTOM_METADATA_RECORD_NAME);

        for(String field : azureWrapperFields){
            String fieldWithoutCustomSuffix = field?.remove('__c');
            azureFieldToSalesforceField.put(fieldWithoutCustomSuffix, String.valueOf(customMetadataInstance.get(field)));
        }
        return azureFieldToSalesforceField;
    }

    private static Object parseLeadFieldValue(Lead lead, String salesforceField, String azureField, Map<String,Object> serializedWrapperMap) {
        if(String.valueOf(serializedWrapperMap.get(azureField)) == '()'){
            Object leadField = lead?.get(salesforceField);
            if(leadField == null){
                return new List<String>();
            }else{
                return String.valueOf(lead?.get(salesforceField))?.split(';');
            }
        }
        else if(salesforceField?.contains('!')){
            return !(Boolean)lead.get(salesforceField.replaceAll('!',''));
        }else{
            return lead.get(salesforceField) == null ? '' : lead.get(salesforceField);
        }
    }

    public static String getLeadDistributorEndpoint() {
        String orgType = UTILS.getOrgType();
        if(orgType == Utils.DEVELOPER){
            return Utils.LEAD_DISTRIBUTOR_DEV_CREDENTIAL;
        }else if(orgType == UTILS.DEVELOPER_PRO){
            return Utils.LEAD_DISTRIBUTOR_DEV_CREDENTIAL;
        }else if(orgType == UTILS.PARTIAL_COPY){
            return Utils.LEAD_DISTRIBUTOR_UAT_CREDENTIAL;
        }else if(orgType == UTILS.FULL_COPY){
            return Utils.LEAD_DISTRIBUTOR_UAT_CREDENTIAL;
        }else if(orgType == UTILS.PRODUCTION){
            return Utils.LEAD_DISTRIBUTOR_PROD_CREDENTIAL;
        }else{
            return null;
        }
    }

    private static Object getActionValue(Lead_Assessment_Action__c leadAssessmentAction) {
        String value = leadAssessmentAction.Lead_Field_Value__c;
        if(BOOLEAN_RELATED_VALUES.contains(leadAssessmentAction.Lead_Field_Value__c)){
            return Boolean.valueOf(value);
        }else{
            return value;
        }
    }

    public static String generateLeadQueryFromConditionsWithComplexConditionsFields(List<Lead_Assessment_Condition__c> simpleConditions, List<Lead_Assessment_Condition__c> complexConditions, String recordTypes) {
        return  'SELECT ' +
                getAllNecessaryLeadFields(complexConditions) +
                ' FROM Lead \n WHERE RecordType.Name IN ' +
                getFormattedRecordTypes(recordTypes) +
                generateWhereClauseConditions(simpleConditions);
    }

    public static String generateLeadQueryFromConditionsWithSpecificRange(List<Lead_Assessment_Condition__c> conditions, List<Lead> leadScope, String recordTypes) {
        return  'SELECT Id FROM Lead WHERE ID IN :' + leadScope +' AND RecordType.Name IN ' +
                getFormattedRecordTypes(recordTypes) +
                generateWhereClauseConditions(conditions);
    }

    private static String getAllNecessaryLeadFields(List<Lead_Assessment_Condition__c> conditions) {
        Set<String> necessaryFieldsSet = new Set<String>();

        if(conditions != null) {
            for (Lead_Assessment_Condition__c condition : conditions) {
                List<String> conditionFields = getALlLeadKeyFieldsFromQuery(condition?.Lead_Assessment_Query__r.Query_Piece__c);
                conditionFields.add('Name');
                for (String field : conditionFields) {
                    necessaryFieldsSet.add(field);
                }
            }
        }

        for(String field : getAzureFieldToSalesforceFieldMap().values()){
            String salesforceField = field.replaceAll('!','');
            if(LEAD_FIELDS_VALUES.contains(salesforceField?.toLowerCase())){
                necessaryFieldsSet.add(salesforceField);
            }
        }

        return getQueryFormatFieldsFromSet(necessaryFieldsSet);
    }

    private static String getQueryFormatFieldsFromSet(Set<String> fields) {
        String queryFields = '';
        for(String field : fields){
            queryFields += field + ',';
        }
        return queryFields.removeEnd(',');
    }

    public static String generateLeadQueryForCertainLead(Lead_Assessment_Condition__c condition, Lead lead) {
        String queryPiece = condition.Lead_Assessment_Query__r.Query_Piece__c;
        List<String> leadFields = getALlLeadKeyFieldsFromQuery(queryPiece);
        for(String leadKeyField : leadFields){
            queryPiece = queryPiece.replace('[' + leadKeyField + ']', replaceLeadField(lead.get(leadKeyField)));
        }

        return queryPiece.replaceFirst('Id', 'COUNT()');
    }

    private static String replaceLeadField(Object passedField) {
        if(passedField == null){
            return 'null';
        }

        String field = (String) passedField;
        if(field == 'true' || field == 'false' || field == 'null'){
            return field;
        }else{
            return '\'' + field + '\'';
        }
    }

    public static Map<Id, Schema.Lead> upsertLeadsMap(Map<Id, Lead> simpleQueryLeads, Map<Id, Lead> temporaryLeadMap) {
        for(Id leadId : temporaryLeadMap.keySet()){
            Lead leadFromQuery = temporaryLeadMap.get(leadId);
            if(simpleQueryLeads.containsKey(leadId)){
                Map<String, Object> queryLeadFieldsMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(leadFromQuery));

                Lead leadInMap = simpleQueryLeads.get(leadId);
                Map<String, Object> alreadyInMapLeadFieldsMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(leadInMap));

                queryLeadFieldsMap.remove(Utils.SOBJECT_MAP_ATTRIBUTES);
                queryLeadFieldsMap.remove(Utils.SOBJECT_MAP_RECORD_TYPE_ID);

                for(String field : queryLeadFieldsMap.keySet()){
                    alreadyInMapLeadFieldsMap.put(field, leadFromQuery.get(field));
                }

                Lead alreadyInMapLeadWithQueryFields = (Lead) JSON.deserialize(JSON.serialize(alreadyInMapLeadFieldsMap), Lead.class);
                simpleQueryLeads.put(leadId, alreadyInMapLeadWithQueryFields);
            }else{
                simpleQueryLeads.put(leadId, leadFromQuery);
            }
        }
        return simpleQueryLeads;
    }

    public static List<LeadAssessmentService.PostAssessmentWrapper> generatePostAssessmentWrappers(List<LeadAssessmentService.RuleWrapper> ruleWrappers, List<Lead> leadScope) {
        List<LeadAssessmentService.PostAssessmentWrapper> assessmentWrappers = new List<LeadAssessmentService.PostAssessmentWrapper>();
        Set<Id> alreadyEvaluatedLeadsIds = new Set<Id>();
        for(LeadAssessmentService.RuleWrapper ruleWrapper : ruleWrappers){
            for(Lead currentLead : leadScope){

                if(!ruleWrapper.simpleQueryLeadsIds.contains(currentLead.Id) ||
                        alreadyEvaluatedLeadsIds.contains(currentLead.Id)){
                    continue;
                }

                List<Lead_Assessment_Condition__c> complexConditions = ruleWrapper.complexConditions;
                Boolean meetsAllConditions = true;
                for(Lead_Assessment_Condition__c complexCondition : complexConditions){
                    Boolean meetsRule = LeadAssessmentService.validateComplexQuerySize(Database.countQuery(
                            LeadAssessmentService.generateLeadQueryForCertainLead(complexCondition,currentLead)),
                            complexCondition);
                    if(!meetsRule) {
                        meetsAllConditions = false;
                        break;
                    }
                }

                if(meetsAllConditions){
                    assessmentWrappers.add(new LeadAssessmentService.PostAssessmentWrapper(
                            currentLead,
                            ruleWrapper.ruleId,
                            ruleWrapper.actions)
                    );
                    alreadyEvaluatedLeadsIds.add(currentLead.Id);
                }

            }
        }
        return assessmentWrappers;
    }

    public static List<LeadAssessmentService.RuleWrapper> generateRuleWrappers(List<Lead> leadScope) {
        List<Lead_Assessment_Rule__c> rules = LeadAssessmentService.getAllAssessmentRules();
        List<LeadAssessmentService.RuleWrapper> ruleWrappers = new List<LeadAssessmentService.RuleWrapper>();
        for(Lead_Assessment_Rule__c rule : rules){
            List<Lead_Assessment_Condition__c> simpleConditions = LeadAssessmentService.getSimpleConditions(rule.Lead_Assessment_Conditions__r);
            List<Lead_Assessment_Condition__c> complexConditions = LeadAssessmentService.getComplexConditions(rule.Lead_Assessment_Conditions__r);
            String recordTypes = rule.Lead_Assessment_Type__r.Record_Type__c;
            Set<Id> simpleQueryLeadsIds = getLeadsIdsWithConditionsFromTheScope(simpleConditions,leadScope,recordTypes);

            ruleWrappers.add(new LeadAssessmentService.ruleWrapper(
                    rule.Id,
                    simpleConditions,
                    complexConditions,
                    simpleQueryLeadsIds,
                    rule.Lead_Assessment_Actions__r)
            );
        }
        return ruleWrappers;
    }

    private static Set<Id> getLeadsIdsWithConditionsFromTheScope(List<Lead_Assessment_Condition__c> conditions, List<Lead> leadScope, String recordTypes) {
        Set<Id> resultIds = new Map<Id,SObject>(leadScope).keySet();
        return new Map<Id,SObject>(
                    Database.query(
                        'SELECT Id FROM Lead WHERE ID IN ' + generateQueryReadyInRange(resultIds) +' AND RecordType.Name IN ' +
                        getFormattedRecordTypes(recordTypes) +
                        generateWhereClauseConditions(conditions)
                    )
                ).keySet();
    }

    private static String generateQueryReadyInRange(Set<Id> valuesSet) {
        return JSON.serialize(valuesSet)?.replace('[','(')?.replace(']',')')?.replaceAll('\"','\'');
    }

    public static List<Schema.Lead_Assessment_Rule__c> getAllAssessmentRules() {
        return [SELECT  Id,
                        Lead_Assessment_Type__r.Record_Type__c,
                        (SELECT Id,
                                Name,
                                Lead_Assessment_Query__r.Query_Piece__c,
                                Lead_Assessment_Rule__r.Lead_Assessment_Type__r.Record_Type__c,
                                Condition_Filter__c,
                                Condition_Value__c
                        FROM Lead_Assessment_Conditions__r),
                        (SELECT Id,
                                Lead_Field__c,
                                Lead_Field_Value__c
                        FROM Lead_Assessment_Actions__r)
                FROM Lead_Assessment_Rule__c];
    }

    public static Map<Id, Schema.Lead> getSimpleQueryLeadsMap(List<Schema.Lead_Assessment_Rule__c> rules) {
        Map<Id,Lead> simpleQueryLeads = new Map<Id,Lead>();
        for(Lead_Assessment_Rule__c rule : rules){
            List<Lead_Assessment_Condition__c> simpleConditions = LeadAssessmentService.getSimpleConditions(rule.Lead_Assessment_Conditions__r);
            List<Lead_Assessment_Condition__c> complexConditions = LeadAssessmentService.getComplexConditions(rule.Lead_Assessment_Conditions__r);
            String recordTypes = rule.Lead_Assessment_Type__r.Record_Type__c;
            Map<Id,Lead> temporaryLeadMap = new Map<Id,Lead>((List<Lead>)Database.query(
                    LeadAssessmentService.generateLeadQueryFromConditionsWithComplexConditionsFields(
                            simpleConditions, complexConditions,recordTypes))
            );
            simpleQueryLeads = LeadAssessmentService.upsertLeadsMap(simpleQueryLeads, temporaryLeadMap);
        }
        return simpleQueryLeads;
    }
    
    public class LWCWrapper {
        String recordLink {get;set;}
        String conditionName {get;set;}
        String query {get;set;}
        String validation {get;set;}
        String rowsReturned {get;set;}
        Boolean isValid {get;set;}
        String styleFormat {get;set;}
        Boolean isSimple {get;set;}
        String type {get;set;}
        String actionName {get;set;}
    }

    public class WhereClauseWrapper{
        String filter {get;set;}
        String value {get;set;}
        String field {get;set;}
    }

    public class RuleWrapper{
        public Id ruleId {get;set;}
        public List<Lead_Assessment_Condition__c> simpleConditions {get;set;}
        public List<Lead_Assessment_Condition__c> complexConditions {get;set;}
        public Set<Id> simpleQueryLeadsIds {get;set;}
        public List<Lead_Assessment_Action__c> actions {get;set;}
        public RuleWrapper(
                Id ruleId,
                List<Lead_Assessment_Condition__c> simpleConditions,
                List<Lead_Assessment_Condition__c> complexConditions,
                Set<Id> simpleQueryLeadsIds,
                List<Lead_Assessment_Action__c> actions){
            this.ruleId = ruleId;
            this.simpleConditions = simpleConditions;
            this.complexConditions = complexConditions;
            this.simpleQueryLeadsIds = simpleQueryLeadsIds;
            this.actions = actions;
        }
    }

    public class PostAssessmentWrapper{
        public Lead lead {get;set;}
        public Id ruleId {get;set;}
        public List<Lead_Assessment_Action__c> actions {get;set;}
        public PostAssessmentWrapper(Lead lead, Id ruleId, List<Lead_Assessment_Action__c> actions){
            this.lead = lead;
            this.ruleId = ruleId;
            this.actions = actions;
        }
    }

    public class LeadAzureIntegrationWrapper{
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String phone {get;set;}
        public String email {get;set;}
        public String leadIDPortal {get;set;}

        public String channel {get;set;}

        public List<String> localities {get;set;}
        public List<String> districts {get;set;}
        public List<String> areaMarketingNames {get;set;}
        public List<String> projectNames {get;set;}

        public String leadOrigin {get;set;}

        public String privacyAgreementAccepted {get;set;}
        public String marketingEmailAllowed {get;set;}

        public String projectBusinessSegment{get;set;}
        public String countryInterface{get;set;}

        public Boolean isColdLead {get;set;}
        public LeadAzureIntegrationWrapper(){
            this.isColdLead = false;
            this.channel = Utils.COLD_LEAD_NURTURING_AZURE;
            this.projectBusinessSegment = 'Housing';
            this.countryInterface = Utils.COUNTRY_CODE_FI; //ISO 639-1 two-letter country code
            this.initializeLists();
        }

        public void initializeLists(){
            this.localities = new List<String>();
            this.districts = new List<String>();
            this.areaMarketingNames = new List<String>();
            this.projectNames = new List<String>();
        }
    }

    public static String getNextScheduleExecutionTime() {
        Lead_Assessment_Delay__mdt customMetadataInstance =
                Lead_Assessment_Delay__mdt.getInstance(Utils.LEAD_ASSESSMENT_BATCH_CUSTOM_METADATA_RECORD_NAME);

        if(customMetadataInstance != null){
            Datetime datetimeInstance = System.now();
            datetimeInstance = datetimeInstance.addDays(Integer.valueOf(customMetadataInstance.Days_Delay__c));
            datetimeInstance = datetimeInstance.addHours(Integer.valueOf(customMetadataInstance.Hours_Delay__c));
            datetimeInstance = datetimeInstance.addMinutes(Integer.valueOf(customMetadataInstance.Minutes_Delay__c));

            return parseDateTimeToCronExpression(datetimeInstance);
        }else{
            return null;
        }
    }

    private static String parseDateTimeToCronExpression(Datetime datetimeInstance) {
        return  '0 ' +
                String.valueOf(datetimeInstance.minute()) +
                ' ' +
                String.valueOf(datetimeInstance.hour()) +
                ' ' +
                String.valueOf(datetimeInstance.day()) +
                ' ' +
                String.valueOf(datetimeInstance.month()) +
                ' ?' +
                ' ' +
                String.valueOf(datetimeInstance.year());
    }
}