global class BatchLeadAssessmentScheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new BatchLeadAssessment(),Utils.MAXIMUM_CALLOUTS_IN_BATCH);
    }
}