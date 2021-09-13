public class Utils {
    public static final String PRODUCTION = 'Production';
    public static final String DEVELOPER = 'Developer';
    public static final String DEVELOPER_PRO = 'Developer Pro';
    public static final String PARTIAL_COPY = 'Partial Copy';
    public static final String FULL_COPY = 'Full Copy';

    public static final String POST_METHOD = 'POST';
    public static final String AZURE_KEY_HEADER = 'Ocp-Apim-Subscription-Key';
    public static final String CONTENT_TYPE = 'Content-Type';
    public static final String APPLICATION_JSON = 'application/json';
    public static final Integer ASYNC_TRANSACTION_TIME = 120000;
    public static final Integer MAXIMUM_CALLOUTS_IN_BATCH = 10;

    public static final String NAMED_CREDENTIAL_PASSWORD = '{!$Credential.Password}';

    public static final String COUNTRY_CODE_FI = 'FI';

    public static final String COLD_LEAD_NURTURING_AZURE = 'Cold lead nurturing';

    public static final String SOBJECT_MAP_ATTRIBUTES = 'attributes';
    public static final String SOBJECT_MAP_RECORD_TYPE_ID = 'RecordTypeId';
    public static final String AZURE_B2C_LEAD_INTEGRATION_CUSTOM_METADATA_RECORD_NAME = 'Configuration';
    public static final String LEAD_ASSESSMENT_BATCH_CUSTOM_METADATA_RECORD_NAME = 'Configuration';
    public static final String BATCH_LEAD_ASSESSMENT_SCHEDULER = 'BatchLeadAssessmentScheduler';

    public final static String LEAD_DISTRIBUTOR_DEV_CREDENTIAL = 'callout:Lead_Distributor_B2C_Dev';
    public final static String LEAD_DISTRIBUTOR_UAT_CREDENTIAL = 'callout:Lead_Distributor_B2C_Uat';
    public final static String LEAD_DISTRIBUTOR_PROD_CREDENTIAL = 'callout:Lead_Distributor_B2C_Prod';

    public final static String FILTER_GREATER_THAN = '>';
    public final static String FILTER_GREATER_OR_EQUAL_THAN = '>=';
    public final static String FILTER_LESSER_THAN = '<';
    public final static String FILTER_LESSER_OR_EQUAL_THAN = '<=';
    public final static String FILTER_EQUALS = '=';
    public final static String FILTERS_NOT_EQUALS = '!=';

    public static boolean projectEsriWorkflowDone = false;
    public static boolean potentialProjectEsriWorkflowDone = false;

    // EDIT 24.10.2012
    public static boolean isLeadMassConversion = false;

    // Public utils class variables used for trigger and apex class communication
    public static boolean inUpdate = false;
    public static boolean inBatchTrigger = false;
    public static boolean inPremiseTrigger = false;
    public static boolean isTest = false;

    // Public datetime vars to indicate when some calculations programs (in premise contract object) are released - determines
    // whether substractions are done or not - i.e. if deleting item it should not be substracted if
    // the record has been last modified before this date, otherwise result will be negative or less than it should.
    public static Datetime premiseProgramRelease = datetime.newInstanceGmt(2009, 2, 8, 11, 48, 0); // Overall calcs of premise contract spaces up to project
    public static Datetime premiseProgramRentedPRelease = datetime.newInstanceGmt(2009, 3, 21, 12, 10, 0);  // Rented parking space calcs
    public static Datetime premiseProgramAbsRentRelease = datetime.newInstanceGmt(2010, 9, 1, 18, 25, 0);  // Absolute net rent calcs
    // 2 dimensional Map for storing space types and their values
    public static Map<String, Map<String, Double>> spaces = new Map<String, Map<String, Double>>();

    // Valid YIT contract types that are summed up to total project size
    public static String v1 = 'YIT Tenancy Agreement';
    public static String v2 = 'YIT Pre-agreement';

    // Free Space YIT contract type that is summed up to total project size but excluded from rented space
    public static String vac = 'YIT Vacant Space';

    public static String res = 'Premise Reservation';

    // Non valid premise contract types that are not summed up (Commitment Space types are summed to their own object)
    public static String t1 = 'Commitment Space Tenancy Agreement';
    public static String t2 = 'Other Agreement Information';
    // Free Space for commit space contract type that is summed up to total size but excluded from rented space
    public static String vacCommit = 'Commitment Space Vacant Space';

    // Set of valid contract types that are summed up to total project or commit space size
    public static Set<String> validcTypes = new Set<String>{v1,v2};

    // Set of YIT contract types whose changes are taken into account when calculating sums to project or commit space object
    public static Set<String> YITTypes = new Set<String>{v1,v2,vac,t1,t2,vacCommit, res}; // , res

    // Valid space types that are summed up to total rented space
    public static Set<String> validSpaceTypes = new Set<String>{'Office', 'Retail', 'Storage', 'Logistics', 'Restaurant', 'Accommodation', 'Share of Joint Premises', 'Other Space', 'Care Space', 'Nursery'};

    // Valid parking space types that are summed up to total rented space
    public static Set<String> validPSpaceTypes = new Set<String>{'Parking Indoor, warm', 'Parking Indoor, cold', 'Parking Outdoor, warm', 'Parking Outdoor, cold'};

    public static final String TRIGGER_DELETE = 'DELETE';
    public static final String TRIGGER_INSERT = 'INSERT';
    public static final String TRIGGER_UPDATE = 'UPDATE';

    //Opportunity Stages
    public static final String PROSPECT_STAGE = '1 - Prospect';
    public static final String PREPARATION_CONCEPTING_STAGE = '2 - Preparation / Concepting';
    public static final String TENDERING_DESIGN_STAGE = '3 - Tendering / Design';
    public static final String SUBMITTED_NEGOTIATION_STAGE = '3a - Submitted / Negotiation';
    public static final String CLOSED_WON_STARTUP_STAGE = '3b1 - Closed Won / Start-up';
    public static final String CLOSED_LOST_STAGE = '3b2 - Closed Lost';
    public static final String QUITTED_STAGE = '3b3 - Quitted';

    //Lease Tender Stages
    public static final String WON_TENDER_STAGE = 'Won';
    public static final String OPEN_TENDER_STAGE = 'Open';
    public static final String LOST_TENDER_STAGE = 'Lost';

    private static String DATA_STORAGE = 'DataStorageMB';

    // Method to remove new absolute net rent - rented values from a map
//    public static void removeRentedAbsNew(){
//        system.debug('### remove new abs called.');
//        if(spaces.containsKey('AbsRentOcc'))
//            if(spaces.get('AbsRentOcc').containsKey('new')){
//                spaces.get('AbsRentOcc').remove('new');
//                system.debug('### new abs rent removed.');
//            }
//
//
//    }

    // Method to remove new rented space values from a map
//    public static void removeRentedSpaceNew(){
//        if(spaces.containsKey('Rented'))
//            if(spaces.get('Rented').containsKey('new')) spaces.get('Rented').remove('new');
//
//        if(spaces.containsKey('RentedP'))
//            if(spaces.get('RentedP').containsKey('new')) spaces.get('RentedP').remove('new');
//    }

    // Method to remove old rented space values from a map
//    public static void removeRentedSpaceOld(){
//        if(spaces.containsKey('Rented'))
//            if(spaces.get('Rented').containsKey('old')) spaces.get('Rented').remove('old');
//
//        if(spaces.containsKey('RentedP'))
//            if(spaces.get('RentedP').containsKey('old')) spaces.get('RentedP').remove('old');
//    }

    // old method for old triggers
    public static void removeRentedAbsNew(){}
    public static void collectSpaceDelete(String firstString, Double firstDouble, String secondString){}
    public static void removeRentedSpaceNew(){}
    public static void collectSpaceInsert(String firstString, Double firstDouble, String secondString){}
    public static void removeRentedSpaceOld(){}
    public static void removeSpaceNew(){}

    // Method to remove new space values from a map
//    public static void removeSpaceNew(){
//
//        if(spaces.containsKey('Office'))
//            if(spaces.get('Office').containsKey('new')) spaces.get('Office').remove('new');
//
//        if(spaces.containsKey('Retail'))
//            if(spaces.get('Retail').containsKey('new')) spaces.get('Retail').remove('new');
//
//        if(spaces.containsKey('Logistics'))
//            if(spaces.get('Logistics').containsKey('new')) spaces.get('Logistics').remove('new');
//
//        if(spaces.containsKey('Storage'))
//            if(spaces.get('Storage').containsKey('new')) spaces.get('Storage').remove('new');
//
//        if(spaces.containsKey('Restaurant'))
//            if(spaces.get('Restaurant').containsKey('new')) spaces.get('Restaurant').remove('new');
//
//        if(spaces.containsKey('Accommodation'))
//            if(spaces.get('Accommodation').containsKey('new')) spaces.get('Accommodation').remove('new');
//
//        if(spaces.containsKey('Share of Joint Premises'))
//            if(spaces.get('Share of Joint Premises').containsKey('new')) spaces.get('Share of Joint Premises').remove('new');
//
//        if(spaces.containsKey('Other Space'))
//            if(spaces.get('Other Space').containsKey('new')) spaces.get('Other Space').remove('new');
//
//        if(spaces.containsKey('Care Space'))
//            if(spaces.get('Care Space').containsKey('new')) spaces.get('Care Space').remove('new');
//
//        if(spaces.containsKey('Nursery'))
//            if(spaces.get('Nursery').containsKey('new')) spaces.get('Nursery').remove('new');
//
//        if(spaces.containsKey('Parking Indoor, warm'))
//            if(spaces.get('Parking Indoor, warm').containsKey('new')) spaces.get('Parking Indoor, warm').remove('new');
//
//        if(spaces.containsKey('Parking Indoor, cold'))
//            if(spaces.get('Parking Indoor, cold').containsKey('new')) spaces.get('Parking Indoor, cold').remove('new');
//
//        if(spaces.containsKey('Parking Outdoor, warm'))
//            if(spaces.get('Parking Outdoor, warm').containsKey('new')) spaces.get('Parking Outdoor, warm').remove('new');
//
//        if(spaces.containsKey('Parking Outdoor, cold'))
//            if(spaces.get('Parking Outdoor, cold').containsKey('new')) spaces.get('Parking Outdoor, cold').remove('new');
//
////        if(spaces.containsKey('AbsRentTotal'))
////            if(spaces.get('AbsRentTotal').containsKey('new')) spaces.get('AbsRentTotal').remove('new');
////
////        if(spaces.containsKey('AbsRentOcc'))
////            if(spaces.get('AbsRentOcc').containsKey('new')) spaces.get('AbsRentOcc').remove('new');
//
//    }


    // Method to remove old space values from a map
    public static void removeSpaceOld(){

        if(spaces.containsKey('Office'))
            if(spaces.get('Office').containsKey('old')) spaces.get('Office').remove('old');

        if(spaces.containsKey('Retail'))
            if(spaces.get('Retail').containsKey('old')) spaces.get('Retail').remove('old');

        if(spaces.containsKey('Logistics'))
            if(spaces.get('Logistics').containsKey('old')) spaces.get('Logistics').remove('old');

        if(spaces.containsKey('Storage'))
            if(spaces.get('Storage').containsKey('old')) spaces.get('Storage').remove('old');

        if(spaces.containsKey('Restaurant'))
            if(spaces.get('Restaurant').containsKey('old')) spaces.get('Restaurant').remove('old');

        if(spaces.containsKey('Accommodation'))
            if(spaces.get('Accommodation').containsKey('old')) spaces.get('Accommodation').remove('old');

        if(spaces.containsKey('Share of Joint Premises'))
            if(spaces.get('Share of Joint Premises').containsKey('old')) spaces.get('Share of Joint Premises').remove('old');

        if(spaces.containsKey('Other Space'))
            if(spaces.get('Other Space').containsKey('old')) spaces.get('Other Space').remove('old');

        if(spaces.containsKey('Care Space'))
            if(spaces.get('Care Space').containsKey('old')) spaces.get('Care Space').remove('old');

        if(spaces.containsKey('Nursery'))
            if(spaces.get('Nursery').containsKey('old')) spaces.get('Nursery').remove('old');

//        if(spaces.containsKey('Rented'))
//            if(spaces.get('Rented').containsKey('old')) spaces.get('Rented').remove('old');

        if(spaces.containsKey('Parking Indoor, warm'))
            if(spaces.get('Parking Indoor, warm').containsKey('old')) spaces.get('Parking Indoor, warm').remove('old');

        if(spaces.containsKey('Parking Indoor, cold'))
            if(spaces.get('Parking Indoor, cold').containsKey('old')) spaces.get('Parking Indoor, cold').remove('old');

        if(spaces.containsKey('Parking Outdoor, warm'))
            if(spaces.get('Parking Outdoor, warm').containsKey('old')) spaces.get('Parking Outdoor, warm').remove('old');

        if(spaces.containsKey('Parking Outdoor, cold'))
            if(spaces.get('Parking Outdoor, cold').containsKey('old')) spaces.get('Parking Outdoor, cold').remove('old');

//        if(spaces.containsKey('RentedP'))
//            if(spaces.get('RentedP').containsKey('old')) spaces.get('RentedP').remove('old');
//
//        if(spaces.containsKey('AbsRentTotal'))
//            if(spaces.get('AbsRentTotal').containsKey('old')) spaces.get('AbsRentTotal').remove('old');
//
//        if(spaces.containsKey('AbsRentOcc'))
//            if(spaces.get('AbsRentOcc').containsKey('old')) spaces.get('AbsRentOcc').remove('old');

    }


//    // Method to collect space values to a map in insert event
//    public static void collectSpaceInsert(String newType, Double newValue, String cType){
//
//        Double new1;
//
//        if(newValue != null) new1=newValue; else new1=0;
//
//        if(spaces.containsKey(newType) && newType != null && YITTypes.contains(cType)){
//
//                if(spaces.get(newType).containsKey('new'))  // If newType map exist there must be mapping for new already
//                    spaces.put(newType, new Map<String, Double>{'new' => spaces.get(newType).get('new') + new1} );
//
//                // Add also key for Rented Space field
//                if(validcTypes.contains(cType) && validSpaceTypes.contains(newType)) // If newType mapping exist, there must be map for rented and new already
//                    spaces.put('Rented', new Map<String, Double>{'new' => spaces.get('Rented').get('new') + new1} );
//
//                // Add also key for Rented Parking Space field
//                if(validcTypes.contains(cType) && validPSpaceTypes.contains(newType)) // If newType mapping exist, there must be map for rented and new already
//                    spaces.put('RentedP', new Map<String, Double>{'new' => spaces.get('RentedP').get('new') + new1} );
//
//        }else if(newType != null && YITTypes.contains(cType)){
//            spaces.put(newType, new Map<String, Double>{'new' => new1} );
//
//            // Add also key for Rented Space field
//            if(validcTypes.contains(cType) && validSpaceTypes.contains(newType)){
//
//                if(spaces.containsKey('Rented'))// There must be map for new already
//                    spaces.put('Rented', new Map<String, Double>{'new' => spaces.get('Rented').get('new') + new1} );
//                else
//                    spaces.put('Rented', new Map<String, Double>{'new' => new1} );
//
//            }
//
//            // Add also key for Rented Parking Space field
//            if(validcTypes.contains(cType) && validPSpaceTypes.contains(newType)){
//
//                if(spaces.containsKey('RentedP'))// There must be map for new already
//                    spaces.put('RentedP', new Map<String, Double>{'new' => spaces.get('RentedP').get('new') + new1} );
//                else
//                    spaces.put('RentedP', new Map<String, Double>{'new' => new1} );
//
//            }
//
//
//            // Add also keys for Absolute Net Rent
//            if(newType == 'AbsRent'){
//
//                if(spaces.containsKey('AbsRentTotal'))// There must be map for new already
//                    spaces.put('AbsRentTotal', new Map<String, Double>{'new' => spaces.get('AbsRentTotal').get('new') + new1} );
//                else
//                    spaces.put('AbsRentTotal', new Map<String, Double>{'new' => new1} );
//
//
//                // Add also key for Absolute Net Rent Occupied
//                if(validcTypes.contains(cType)){
//
//                    if(spaces.containsKey('AbsRentOcc'))// There must be map for new already
//                        spaces.put('AbsRentOcc', new Map<String, Double>{'new' => spaces.get('AbsRentOcc').get('new') + new1} );
//                    else
//                        spaces.put('AbsRentOcc', new Map<String, Double>{'new' => new1} );
//
//                }
//            }
//
//        }
//
//    }


    // Method to collect space values to a map in delete event
//    public static void collectSpaceDelete(String oldType, Double oldValue, String cType){
//
//        Double old1;
//
//        if(oldValue != null) old1=oldValue; else old1=0;
//
//        if(spaces.containsKey(oldType) && oldType != null && YITTypes.contains(cType)){
//
//                // There must be mapping for old value already
//                spaces.put(oldType, new Map<String, Double>{'old' => spaces.get(oldType).get('old') + old1} );
//
//                // Add also key for Rented Space field
//                if(validcTypes.contains(cType) && validSpaceTypes.contains(oldType)) // If oldType mapping exist, there must be map for rented and old already
//                    spaces.put('Rented', new Map<String, Double>{'old' => spaces.get('Rented').get('old') + old1} );
//
//                // Add also key for Rented Parking Space field
//                if(validcTypes.contains(cType) && validPSpaceTypes.contains(oldType)) // If oldType mapping exist, there must be map for rented and old already
//                    spaces.put('RentedP', new Map<String, Double>{'old' => spaces.get('RentedP').get('old') + old1} );
//
//
//        }else if(oldType != null && YITTypes.contains(cType)){
//            spaces.put(oldType, new Map<String, Double>{'old' => old1} );
//
//            // Add also key for Rented Space field
//            if(validcTypes.contains(cType) && validSpaceTypes.contains(oldType)){
//
//                if(spaces.containsKey('Rented')){
//                    if(spaces.get('Rented').containsKey('old')) // There must be mapping for old if rented mapping exists
//                        spaces.put('Rented', new Map<String, Double>{'old' => spaces.get('Rented').get('old') + old1} );
//                }else{
//                    spaces.put('Rented', new Map<String, Double>{'old' => old1} );
//                }
//            }
//
//            // Add also key for Rented Parking Space field
//            if(validcTypes.contains(cType) && validPSpaceTypes.contains(oldType)){
//
//                if(spaces.containsKey('RentedP')){
//                    if(spaces.get('RentedP').containsKey('old')) // There must be mapping for old if rented mapping exists
//                        spaces.put('RentedP', new Map<String, Double>{'old' => spaces.get('RentedP').get('old') + old1} );
//                }else{
//                    spaces.put('RentedP', new Map<String, Double>{'old' => old1} );
//                }
//            }
//
//            // Add also keys for Absolute Net Rent
//            if(oldType == 'AbsRent'){
//
//                if(spaces.containsKey('AbsRentTotal'))// There must be map for new already
//                    spaces.put('AbsRentTotal', new Map<String, Double>{'old' => spaces.get('AbsRentTotal').get('old') + old1} );
//                else
//                    spaces.put('AbsRentTotal', new Map<String, Double>{'old' => old1} );
//
//
//                // Add also key for Absolute Net Rent Occupied
//                if(validcTypes.contains(cType)){
//
//                    if(spaces.containsKey('AbsRentOcc'))// There must be map for new already
//                        spaces.put('AbsRentOcc', new Map<String, Double>{'old' => spaces.get('AbsRentOcc').get('old') + old1} );
//                    else
//                        spaces.put('AbsRentOcc', new Map<String, Double>{'old' => old1} );
//
//                }
//            }
//
//        }
//
//    }

    // Method to collect space values to a map in delete event
    public static void collectSpaceForTrigger(String ntype, Decimal value, String cType, String triggerType){

        Double val1;

        if(value != null) val1=value; else val1=0;

        if(spaces.containsKey(ntype) && ntype != null && YITTypes.contains(cType)){

            // There must be mapping for old value already
            spaces.put(ntype, new Map<String, Double>{triggerType == TRIGGER_DELETE ? 'old' : 'new' => spaces.get(ntype).get(triggerType == TRIGGER_DELETE ? 'old' : 'new') + val1} );

//            // Add also key for Rented Space field
//            if(validcTypes.contains(cType) && validSpaceTypes.contains(ntype)) // If oldType mapping exist, there must be map for rented and old already
//                spaces.put('Rented', new Map<String, Double>{triggerType == TRIGGER_DELETE ? 'old' : 'new' => spaces.get('Rented').get(triggerType == TRIGGER_DELETE ? 'old' : 'new') + val1} );
//
//            // Add also key for Rented Parking Space field
//            if(validcTypes.contains(cType) && validPSpaceTypes.contains(ntype)) // If oldType mapping exist, there must be map for rented and old already
//                spaces.put('RentedP', new Map<String, Double>{triggerType == TRIGGER_DELETE ? 'old' : 'new' => spaces.get('RentedP').get(triggerType == TRIGGER_DELETE ? 'old' : 'new') + val1} );


        }else if(ntype != null && YITTypes.contains(cType)){
            spaces.put(ntype, new Map<String, Double>{triggerType == TRIGGER_DELETE ? 'old' : 'new' => val1} );

//            // Add also key for Rented Space field
//            if(validcTypes.contains(cType) && validSpaceTypes.contains(ntype)){
//
//                if(spaces.containsKey('Rented')){
//                    if(spaces.get('Rented').containsKey('old')) // There must be mapping for old if rented mapping exists
//                        spaces.put('Rented', new Map<String, Double>{'old' => spaces.get('Rented').get('old') + val1} );
//                    else
//                        spaces.put('Rented', new Map<String, Double>{'new' => spaces.get('Rented').get('new') + val1} );
//                }else{
//                    spaces.put('Rented', new Map<String, Double>{triggerType == TRIGGER_DELETE ? 'old' : 'new' => val1} );
//                }
//            }

            // Add also key for Rented Parking Space field
//            if(validcTypes.contains(cType) && validPSpaceTypes.contains(ntype)){
//
//                if(spaces.containsKey('RentedP')){
//                    if(spaces.get('RentedP').containsKey('old')) // There must be mapping for old if rented mapping exists
//                        spaces.put('RentedP', new Map<String, Double>{'old' => spaces.get('RentedP').get('old') + val1} );
//                    else
//                        spaces.put('RentedP', new Map<String, Double>{'new' => spaces.get('RentedP').get('new') + val1} );
//                }else{
//                    spaces.put('RentedP', new Map<String, Double>{triggerType == TRIGGER_DELETE ? 'old' : 'new' => val1} );
//                }
//            }

            // Add also keys for Absolute Net Rent
//            if(ntype == 'AbsRent'){
//
//                if(spaces.containsKey('AbsRentTotal'))// There must be map for new already
//                    spaces.put('AbsRentTotal', new Map<String, Double>{triggerType == TRIGGER_DELETE ? 'old' : 'new' => spaces.get('AbsRentTotal').get(triggerType == TRIGGER_DELETE ? 'old' : 'new') + val1} );
//                else
//                    spaces.put('AbsRentTotal', new Map<String, Double>{triggerType == TRIGGER_DELETE ? 'old' : 'new' => val1} );
//
//
//                // Add also key for Absolute Net Rent Occupied
//                if(validcTypes.contains(cType)){
//
//                    if(spaces.containsKey('AbsRentOcc'))// There must be map for new already
//                        spaces.put('AbsRentOcc', new Map<String, Double>{triggerType == TRIGGER_DELETE ? 'old' : 'new' => spaces.get('AbsRentOcc').get(triggerType == TRIGGER_DELETE ? 'old' : 'new') + val1} );
//                    else
//                        spaces.put('AbsRentOcc', new Map<String, Double>{triggerType == TRIGGER_DELETE ? 'old' : 'new' => val1} );
//
//                }
//            }

        }

    }


    // Method to collect space types and values to a map in update event
    public static void collectSpace(String newType, String oldType, Decimal newValue, Decimal oldValue, String cTypeNew, String cTypeOld){

        Double new1;
        Double old1;

        if(newValue != null) new1=newValue; else new1=0;
        if(oldValue != null) old1=oldValue; else old1=0;


        // *********  CASE WHERE SPACE TYPE IS CHANGED  ************

//        if(oldType != newType && (validcTypes.contains(cTypeNew) || cTypeNew == null)){

        // *******  Handle case where space type gets null as new value  ********
        if(newType == null){

            if(oldValue != null){

                // If there is already a key for this space type
                if(spaces.containsKey(oldType)){

                    // There must be also mappings for new and old
                    spaces.put(oldType, new Map<String, Double>{'new' => spaces.get(oldType).get('new'), 'old' => spaces.get(oldType).get('old') + oldValue});

                    // If no key in map for this space type
                }else{
                    spaces.put(oldType, new Map<String, Double>{'old' => oldValue, 'new' => 0});
                }

                // Add also key for Rented Space field
//                        if((validcTypes.contains(cTypeNew) || validcTypes.contains(cTypeOld)) && validSpaceTypes.contains(oldType)){
//
//                            if(spaces.containsKey('Rented')){
//                                // If rented mapping is there, must be mappings for new and old
//                                spaces.put('Rented', new Map<String, Double>{'new' => spaces.get('Rented').get('new'), 'old' => spaces.get('Rented').get('old') + oldValue});
//
//                            }else{
//                                spaces.put('Rented', new Map<String, Double>{'old' => oldValue, 'new' => 0});
//                            }
//                        }

                // Add also key for Rented Parking Space field
//                        if((validcTypes.contains(cTypeNew) || validcTypes.contains(cTypeOld)) && validPSpaceTypes.contains(oldType)){
//
//                            if(spaces.containsKey('RentedP')){
//                                // If rented mapping is there, must be mappings for new and old
//                                spaces.put('RentedP', new Map<String, Double>{'new' => spaces.get('RentedP').get('new'), 'old' => spaces.get('RentedP').get('old') + oldValue});
//
//                            }else{
//                                spaces.put('RentedP', new Map<String, Double>{'old' => oldValue, 'new' => 0});
//                            }
//                        }

            }


            // *******  Handle case where space type was null and gets real value as new value  *******
        }else if(oldType == null){

            if(newValue != null){

                if(spaces.containsKey(newType)){
                    // If mapping for newType is there, must also be mapping for new and old
                    spaces.put(newType, new Map<String, Double>{'new' => spaces.get(newType).get('new') + newValue, 'old' => spaces.get(newType).get('old')});

                }else{
                    spaces.put(newType, new Map<String, Double>{'new' => newValue, 'old' => 0});
                }

                // Add also key for Rented Space field
//                        if((validcTypes.contains(cTypeNew) || validcTypes.contains(cTypeOld)) && validSpaceTypes.contains(newType)){
//
//                            if(spaces.containsKey('Rented')){
//                                // If mapping for rented value is there, must also be mapping for new and old
//                                spaces.put('Rented', new Map<String, Double>{'new' => spaces.get('Rented').get('new') + newValue, 'old' => spaces.get('Rented').get('old')});
//
//                            }else{
//                                spaces.put('Rented', new Map<String, Double>{'new' => newValue, 'old' => 0});
//                            }
//                        }
                // Add also key for Rented Parking Space field
//                        if((validcTypes.contains(cTypeNew) || validcTypes.contains(cTypeOld)) && validPSpaceTypes.contains(newType)){
//
//                            if(spaces.containsKey('RentedP')){
//                                // If mapping for rented value is there, must also be mapping for new and old
//                                spaces.put('RentedP', new Map<String, Double>{'new' => spaces.get('RentedP').get('new') + newValue, 'old' => spaces.get('RentedP').get('old')});
//
//                            }else{
//                                spaces.put('RentedP', new Map<String, Double>{'new' => newValue, 'old' => 0});
//                            }
//                        }

            }
            // *******  Last, handle case where space type is changed  ********
        }else{
            System.debug('*****Get there: ' + spaces);
            if(newValue != null){

                if(spaces.containsKey(newType)){
                    // If mapping for newType is there, must also be mapping for new and old
                    spaces.put(newType, new Map<String, Double>{'new' => spaces.get(newType).get('new') + newValue, 'old' => spaces.get(newType).get('old')});

                }else{
                    spaces.put(newType, new Map<String, Double>{'new' => newValue, 'old' => 0});
                }
            }
            if(oldValue != null){

                if(spaces.containsKey(oldType)){
                    // If mapping for oldType is there, must also be mapping for new and old
                    spaces.put(oldType, new Map<String, Double>{'new' => spaces.get(oldType).get('new'), 'old' => spaces.get(oldType).get('old') + oldValue});

                }else{
                    spaces.put(oldType, new Map<String, Double>{'old' => oldValue, 'new' => 0});
                }

            }

            System.debug('*****Get there: ' + spaces);

            // Add also key for Rented Space field
//                    if((validcTypes.contains(cTypeNew) || validcTypes.contains(cTypeOld)) && validSpaceTypes.contains(oldType) && validSpaceTypes.contains(newType)){
//
//                        if(spaces.containsKey('Rented')){
//                            // If mapping for rented value is there, must also be mapping for new and old
//                            spaces.put('Rented', new Map<String, Double>{'new' => spaces.get('Rented').get('new') + new1, 'old' => spaces.get('Rented').get('old') + old1});
//
//                        }else{
//                            spaces.put('Rented', new Map<String, Double>{'new' => new1, 'old' => old1});
//                        }
//                    }
            // Add also key for Rented Parking Space field
//                    if((validcTypes.contains(cTypeNew) || validcTypes.contains(cTypeOld)) && validPSpaceTypes.contains(oldType) && validPSpaceTypes.contains(newType)){
//
//                        if(spaces.containsKey('RentedP')){
//                            // If mapping for rented value is there, must also be mapping for new and old
//                            spaces.put('RentedP', new Map<String, Double>{'new' => spaces.get('RentedP').get('new') + new1, 'old' => spaces.get('RentedP').get('old') + old1});
//
//                        }else{
//                            spaces.put('RentedP', new Map<String, Double>{'new' => new1, 'old' => old1});
//                        }
//                    }

        }

//        // ************  END CASE WHERE SPACE TYPE IS CHANGED  ***************
//        }else if(validcTypes.contains(cTypeNew) || cTypeNew == null){
//
//            if(spaces.containsKey(newType)){
//                // If mapping for newType is there, must also be mapping for new and old
//                spaces.put(newType, new Map<String, Double>{'new' => spaces.get(newType).get('new') + new1, 'old' => spaces.get(newType).get('old') + old1} );
//
//            }else{
//                spaces.put(newType, new Map<String, Double>{'new' => new1, 'old' => old1} );
//            }
//
//            // Add also key for Rented Space field
////                if((validcTypes.contains(cTypeNew) || validcTypes.contains(cTypeOld)) && validSpaceTypes.contains(newType)){
////
////                    if(spaces.containsKey('Rented')){
////                        // If mapping for rented value is there, must also be mapping for new and old
////                        spaces.put('Rented', new Map<String, Double>{'new' => spaces.get('Rented').get('new') + new1, 'old' => spaces.get('Rented').get('old') + old1});
////
////                    }else{
////                        spaces.put('Rented', new Map<String, Double>{'new' => new1, 'old' => old1});
////                    }
////                }
//            // Add also key for Rented Parking Space field
////                if((validcTypes.contains(cTypeNew) || validcTypes.contains(cTypeOld)) && validPSpaceTypes.contains(newType)){
////
////                    if(spaces.containsKey('RentedP')){
////                        // If mapping for rented value is there, must also be mapping for new and old
////                        spaces.put('RentedP', new Map<String, Double>{'new' => spaces.get('RentedP').get('new') + new1, 'old' => spaces.get('RentedP').get('old') + old1});
////
////                    }else{
////                        spaces.put('RentedP', new Map<String, Double>{'new' => new1, 'old' => old1});
////                    }
////                }
//
//            // Add also keys for Absolute Net Rent
////                if(oldType == 'AbsRent'){
////
////                    if(spaces.containsKey('AbsRentTotal'))// There must be map for new already
////                        spaces.put('AbsRentTotal', new Map<String, Double>{'new' => spaces.get('AbsRentTotal').get('new') + new1, 'old' => spaces.get('AbsRentTotal').get('old') + old1} );
////                    else
////                        spaces.put('AbsRentTotal', new Map<String, Double>{'new' => new1, 'old' => old1} );
////
////
////                    // Add also key for Absolute Net Rent Occupied
////                    if(validcTypes.contains(cTypeNew) || validcTypes.contains(cTypeOld)){
////
////                        if(spaces.containsKey('AbsRentOcc'))// There must be map for new already
////                            spaces.put('AbsRentOcc', new Map<String, Double>{'new' => spaces.get('AbsRentOcc').get('new') + new1, 'old' => spaces.get('AbsRentOcc').get('old') + old1} );
////                        else
////                            spaces.put('AbsRentOcc', new Map<String, Double>{'new' => new1, 'old' => old1} );
////
////                    }
////                }
//
//        }
    }


    // Sum up Total rent /year field to project
    public static void calculateTotalRentMonth(Map<Id, project_TT__c> projects){

        for(Project_TT__c p : projects.values()){
            p.TOTAL_RENT_month__c = 0;
            p.TOTAL_Absolute_Net_Rent__c = 0;
            for(Premise_and_Contract_Information__c paci : p.R00N20000001XpRCEA0){
                if(paci.TOTAL_RENT_month__c != null) p.TOTAL_RENT_month__c += paci.TOTAL_RENT_month__c;
                if(paci.TOTAL_Absolute_Net_Rent__c != null) p.TOTAL_Absolute_Net_Rent__c += paci.TOTAL_Absolute_Net_Rent__c;
            }
        }

    }

    public static String getOrgType() {
        if(![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox){
            return PRODUCTION;
        }else{
            Integer storageLimit = OrgLimits.getMap().get(DATA_STORAGE).getLimit();
            String sandboxType;
            switch on storageLimit {
                when 200 {
                    sandboxType = DEVELOPER;
                }
                when 1024 {
                    sandboxType = DEVELOPER_PRO;
                }
                when 5120 {
                    sandboxType = PARTIAL_COPY;
                }
                when else {
                    sandboxType = FULL_COPY;
                }
            }
            return sandboxType;
        }
    }

}