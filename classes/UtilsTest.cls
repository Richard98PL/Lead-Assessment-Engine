@isTest
public with sharing class UtilsTest {
    @IsTest
    static void presentedProjectNewTrigger() {

        //Create Account
        Account ac2 = new Account(BillingCity='Espoo', BillingCountry='Finland');
        ac2.Name = 'test';
        ac2.Type = 'Asiakas';
        insert ac2;

        //Create Opp
        Opportunity o = new Opportunity();
        o.Name = 'oppty';
        o.StageName = 'RFQ';
        o.CloseDate = Date.today() + 30;
        o.Toimistotila__c = 300;
        o.AccountId = ac2.id;
        insert o;

/*
        //Create CommitmentSpace
        Commitment_Space__c cs = new Commitment_Space__c();
        cs.Name = 'test';
        insert cs;

        //Create presentedCommitmentSpace
        Presented_Commitment_Space__c pc = new Presented_Commitment_Space__c();
        pc.Commitment_Space__c = cs.id;
        pc.Opportunity__c = o.id;
        insert pc;
*/
        //Create Project
        Project_TT__c pr = new Project_TT__c(YIT_Decision_to_start_Project__c=Date.today());
        pr.Name = 'test';
        insert pr;

        //Create presentedProject
        Presented_Project_new__c pp = new Presented_Project_new__c();
        pp.Project__c = pr.id;
        pp.Opportunity__c = o.id;
        insert pp;

        //Create Projects and give initial values to fields that are forbidden - to test save prevention
        List<Project_TT__c> prts = new List<Project_TT__c>();
        for (integer i=0; i<14; i++){
            Project_TT__c pr2 = new Project_TT__c(YIT_Decision_to_start_Project__c=Date.today());
            pr2.Name = 'test2';
            if(i==0)pr2.Rented_Space_m__c = 100;
            if(i==1)pr2.Storage_m__c = 100;
            if(i==2)pr2.Share_of_Joint_Premises__c = 100;
            if(i==3)pr2.Retail_m__c = 100;
            if(i==4)pr2.Restaurant__c = 100;
            if(i==5)pr2.Other_Space__c = 100;
            if(i==6)pr2.Office_m__c = 100;
            if(i==7)pr2.Logistics_m__c = 100;
            if(i==8)pr2.Accommodation_m__c = 100;
            if(i==9)pr2.Parking_Spaces_Outdoor_warm__c = 100;
            if(i==10)pr2.Parking_Spaces_Outdoor_cold__c = 100;
            if(i==11)pr2.Parking_Spaces_Indoor_warm__c = 100;
            if(i==12)pr2.Parking_Spaces_Indoor_cold__c = 100;
            if(i==13)pr2.PARKING_SPACE_RENTED__c = 100;
            prts.add(pr2);
        }

        for (Project_TT__c projtt : prts){
            try{
                insert projtt;
                //System.assert(false);
            } catch (DmlException e) {
                //System.assert(e.getMessage().contains('first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Cannot give value to this field directly. Its value is calculated by summing up child record values.'), e.getMessage());
            }
        }
    }


//  -------------- Test for batch and batchJob triggers -------------------
    static testMethod void testBatchTrigger() {

        //Set context variable to indicate that we are inside a test.
        //In Globals this is used to construct right soql query only for tests where limit is lower.
        Utils.isTest = true;

        // Create new batch job
        Batch_Job__c newJob = new Batch_Job__c(
                Run_Every__c = 1,
                Run_Every_Units__c = 'Days',
                Name = 'Account Update Process',
                Description__c = 'Batch job...');

        insert newJob;

        // Try to delete it and so test batchJobTrigger deletion prevention
        try{
            delete newjob;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Cannot delete this job. It is used in background batch runs.'), e.getMessage());
        }

        // Create batch run for the job - Days
        Batch_Run__c newRun = new Batch_Run__c(
                Scheduled_To_Run__c = Datetime.now(),
                Trigger_Batch_Run__c = true,
                Batch_Job_Name__c = 'Sample Batch Job',
                Batch_Job__c = newJob.Id,
                Run_Every__c = newJob.Run_Every__c,
                Run_Every_Units__c = newJob.Run_Every_Units__c);

        insert newRun;

        // Create batch run for the job - Hours
        Batch_Run__c newHRun = new Batch_Run__c(
                Scheduled_To_Run__c = null, //Intentionally leave blank
                Trigger_Batch_Run__c = true,
                Batch_Job_Name__c = newJob.Name, // Set different name
                Batch_Job__c = newJob.Id,
                Run_Every__c = -10,  // intentionally set negative value
                Run_Every_Units__c = 'Hours'); // Set hour value

        insert newHRun;


        // Create batch run for the job - set it now completed - trigger should ignore it
        Batch_Run__c completedRun = new Batch_Run__c(
                Scheduled_To_Run__c = Datetime.now()-1,
                Completed__c = Datetime.now()-1,
                Batch_Job_Name__c = 'Sample Batch Job',
                Batch_Job__c = newJob.Id,
                Run_Every__c = newJob.Run_Every__c,
                Run_Every_Units__c = newJob.Run_Every_Units__c);

        insert completedRun;

        // Create batch run for the job - do not trigger it - then test rescheduling
        Batch_Run__c noRun = new Batch_Run__c(
                Scheduled_To_Run__c = Datetime.now()+1,
                Batch_Job_Name__c = newJob.Name,
                Batch_Job__c = newJob.Id,
                Run_Every__c = newJob.Run_Every__c,
                Run_Every_Units__c = newJob.Run_Every_Units__c);

        insert noRun;
        update noRun; // also update to test scheduling update

    }

    static testMethod void testTenderTrigger() {

        // List to hold up tenders
        List<Tender__c> tds = new List<Tender__c>();

        // Create test data
        Account a = new Account(BillingCity='Espoo', BillingCountry='Finland');
        a.Name = 'testabc';
        a.Type = 'Asiakas';
        insert a;

        Opportunity o = new Opportunity();
        o.Name = 'testabcopp';
        o.AccountId = a.Id;
        o.Amount = 1000;
        o.StageName='RFQ';
        o.CloseDate=System.today() + 7;
        o.Toimistotila__c = 100;
        insert o;

        Project_TT__c p = new Project_TT__c(YIT_Decision_to_start_Project__c=Date.today());
        p.Name = 'testabcproj';
        insert p;

        Presented_Project_new__c pp = new Presented_Project_new__c(Account__c = a.Id,
                Date_Presented__c = System.today()-1,
                Opportunity__c = o.Id,
                Project__c = p.Id);
        insert pp;
        // To test bulk processing, mass create tenders
        for(integer i=0; i<100; i++){

            Tender__c t = new Tender__c();
            t.Project__c = p.Id;
            t.Opportunity__c = o.Id;
            tds.add(t);
        }
        insert tds;

        // Get Account id from Tender object
        Id id = [SELECT Id, Account__c FROM Tender__c WHERE Opportunity__c = :o.Id LIMIT 1].Account__c;

        // Assert that Account__c contains same value as Account created earlier
        System.assert( id == a.Id );

    }


//  -------------- Test for accountTrigger -------------------
    static testMethod void testAccountTrigger() {

        // Bulk processing is tested in Globals.cls - here only single record entries
        // Create 1st child account - this will not yet get its parentId field filled
        Account ac1 = new Account(BillingCity='Espoo', BillingCountry='Finland');
        ac1.Name = 'test child 1';
        ac1.Type = 'Asiakas';
        ac1.Fonecta_ID__c = '0404198';
        ac1.emoyhti_n_ID__c = '0503486';
        insert ac1;

        // Assert that accountTrigger did its job and flagged this record
        //System.assertEquals('B', [select Id, Parent_Flag__c from Account where id = :ac1.Id].Parent_Flag__c);

        // Create one parent account
        Account ap = new Account(BillingCity='Espoo', BillingCountry='Finland');
        ap.Name = 'test parent';
        ap.Type = 'Asiakas';
        ap.Fonecta_ID__c = '0503486';
        insert ap;

        // Assert that accountTrigger did its job and flagged this record
//        System.assertEquals('NULL', [select Id, Parent_Flag__c from Account where id = :ap.Id].Parent_Flag__c);

        // Create 2nd child account - this should get parentId filled
        Account ac2 = new Account(BillingCity='Espoo', BillingCountry='Finland');
        ac2.Name = 'test child 2';
        ac2.Type = 'Asiakas';
        ac2.Fonecta_ID__c = '0405373';
        ac2.emoyhti_n_ID__c = '0503486';
        insert ac2;

        // Assert that accountTrigger did its job and filled parent id
//        System.assertEquals(ap.Id, [select Id, ParentId from Account where id = :ac2.Id].ParentId);
        // Also assert that accountTrigger did its job and flagged this record
//        System.assertEquals('OK', [select Id, Parent_Flag__c from Account where id = :ac2.Id].Parent_Flag__c);

        // Update hier override flag to be true - it should be possible to manually set parentId
        ac2.Hierarchy_Override__c = true;
        ac2.ParentId = ac1.Id;
        update ac2;
        // Assert that manually set parent is there and still ext parent points to other account, and parent flag is correct
//        Account assureAcct = [select Id, ParentId, emoyhti_n_ID__c, Parent_Flag__c from Account where id = :ac2.Id limit 1];
//        System.assertEquals(ac1.Id, assureAcct.ParentId);
//        System.assertEquals('0503486', assureAcct.emoyhti_n_ID__c);
//        System.assertEquals('OVERRIDDEN', assureAcct.Parent_Flag__c);


        Account acd1 = new Account(BillingCity='Espoo', BillingCountry='Finland');
        acd1.Name = 'test child 3';
        acd1.Type = 'Asiakas';
        acd1.Fonecta_ID__c = '0403285';
        acd1.emoyhti_n_ID__c = '';
        acd1.D_B_ID__c='909030139';
        acd1.D_B_Parent_ID__c='987123678';
        insert acd1;

        Account selectedAc=[select Id, D_B_ID__c,D_B_Parent_ID__c,Fonecta_ID__c,Parent_Flag__c,ParentId
        from Account
        where id = :acd1.Id LIMIT 1];
        System.assertEquals('909030139',selectedAc.D_B_ID__c);
        System.assertEquals('987123678',selectedAc.D_B_Parent_ID__c);
        System.assertEquals('0403285',selectedAc.Fonecta_ID__c);
        System.assertEquals(null,selectedAc.ParentId);
        System.assertEquals('NULL',selectedAc.Parent_Flag__c);

        Account acd2 = new Account(BillingCity='Espoo', BillingCountry='Finland');
        acd2.Name = 'test child 3';
        acd2.Type = 'Asiakas';
        acd2.D_B_ID__c='909033339';
        acd2.D_B_Parent_ID__c='893445678';
        insert acd2;

        Account selectedAc2=[select Id, D_B_ID__c,D_B_Parent_ID__c,Fonecta_ID__c,Parent_Flag__c from Account where id = :acd2.Id LIMIT 1];
        System.assertEquals('909033339',selectedAc2.D_B_ID__c);
        System.assertEquals('893445678',selectedAc2.D_B_Parent_ID__c);
        System.assertEquals(null,selectedAc2.Fonecta_ID__c);
        System.assertEquals('B',selectedAc2.Parent_Flag__c);

        // Create one parent account
        Account apd = new Account(BillingCity='Espoo', BillingCountry='Finland');
        apd.Name = 'test parent 2';
        apd.Type = 'Asiakas';
        apd.D_B_ID__c = '987123678';
        insert apd;
        // Assert that accountTrigger did its job and flagged this record
//        System.assertEquals('NULL', [select Id, Parent_Flag__c from Account where id = :apd.Id].Parent_Flag__c);

        // Create 2nd child account - this should get parentId filled
        Account acd3 = new Account(BillingCity='Espoo', BillingCountry='Finland');
        acd3.Name = 'test child 3';
        acd3.Type = 'Asiakas';
        acd3.D_B_ID__c = '039485761';
        acd3.D_B_Parent_ID__c = '987123678';
        insert acd3;

        Account selectedAc3=[select Id, D_B_ID__c,D_B_Parent_ID__c,
                Fonecta_ID__c,Parent_Flag__c, ParentId
        from Account
        where id = :acd3.Id LIMIT 1];
        // Also assert that accountTrigger did its job and flagged this record
//        System.assertEquals('OK', selectedAc3.Parent_Flag__c);
        // Assert that accountTrigger did its job and filled parent id
//        System.assertEquals(apd.Id, selectedAc3.ParentId);


        // Update hier override flag to be true - it should be possible to manually set parentId
        acd3.Hierarchy_Override__c = true;
        acd3.ParentId = acd1.Id;
        update acd3;

        // Assert that manually set parent is there and still ext parent points to other account, and parent flag is correct
        Account assureAcct2 = [select Id, D_B_ID__c,D_B_Parent_ID__c, ParentId,
                emoyhti_n_ID__c, Parent_Flag__c
        from Account
        where id = :acd3.Id limit 1];

    }
}