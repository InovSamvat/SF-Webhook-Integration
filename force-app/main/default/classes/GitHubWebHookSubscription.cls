@RestResource(urlMapping='/webhooks')
global with sharing class GitHubWebHookSubscription {
    @TestVisible private static final String HEADERSIGN = 'X-Hub-Signature-256';
    @TestVisible private static final String SHA = 'sha256=';
    @TestVisible private static final String HMACSHA = 'hmacSHA256';
    @TestVisible private static final String PASS = Git_Secret__c.getOrgDefaults().Secret__c;
    @TestVisible private static final String SUCCESSTXT = 'Success';
    @TestVisible private static final String FAIL = 'Failure';
    @TestVisible private static final String MSG = 'Notification Received';
    @TestVisible private static final String INVALIDMSG = 'Invalid Subscription';
        
    @HttpPost
    global static void handlePush() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            String hashVal = req.headers.get(HEADERSIGN);
            Blob reqBody = req.requestBody;
            Blob macVal = Crypto.generateMac(HMACSHA, reqBody, Blob.valueOf(PASS));
            String macString = SHA + EncodingUtil.convertToHex(macVal);
            System.debug('strmac:: '+macString);
            if(hashVal == macString)
            {
                RequestBody gitNotif = (RequestBody)JSON.deserialize(reqBody.toString(), RequestBody.class);
                insertNotif(gitNotif);
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(new ResponseBody(SUCCESSTXT, MSG)));
            }
            else
            {
                res.statusCode = 401;
                res.responseBody = Blob.valueOf(JSON.serialize(new ResponseBody(FAIL, INVALIDMSG)));
            }
        } catch(Exception ex){
            res.statusCode = 401;
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseBody(FAIL,ex.getMessage())));
            System.debug('Some Exception:: '+ex.getMessage());
        }
    }
    
    public static void insertNotif(RequestBody gitNotif){
        List<Github_Notification__c> notifRecs = new List<Github_Notification__c>();
        
        for(CommitBody cb: gitNotif.commits)
        {
            Github_Notification__c notifRec = new Github_Notification__c();
            String modifiedComp = cb?.modified?.size()>0?String.join(cb?.modified,';;'):null;
            String removedComp = cb?.removed?.size()>0?String.join(cb?.removed,';;'):null;
            String addedComp = cb?.added?.size()>0?String.join(cb?.added,';;'):null;
            
            notifRec.Repository_Name__c = gitNotif?.repository?.name;
            notifRec.Email__c = cb?.committer?.email;
            notifRec.Committer__c = cb?.committer?.name;
            notifRec.Message__c = cb?.message;
            notifRec.Modified_Component__c = modifiedComp;
            notifRec.Removed_Component__c = removedComp;
            notifRec.Added_Component__c = addedComp;
            notifRec.Timestamp__c = cb?.timestamp;
            notifRec.URL__c = cb?.url;
            
            notifRecs.add(notifRec);
        }
        
        insert notifRecs;
        
    }
    
    public class ResponseBody{
        @TestVisible String response;
        @TestVisible String message;
        @TestVisible public ResponseBody(String resp, String msg){
            response = resp;
            message = msg;
        }
    }
    
    public class RequestBody {
        @TestVisible List<CommitBody> commits; 
        @TestVisible RepoDetail repository;
    }
    
    public class CommitBody {
        @TestVisible CommitterDetail committer; 
        @TestVisible String timestamp;
        @TestVisible String url;
        @TestVisible String message;
        @TestVisible List<String> added;
        @TestVisible List<String> removed;
        @TestVisible List<String> modified;
    }
    
    public class CommitterDetail {
        @TestVisible String name; 
        @TestVisible String email;
    }
    
    public class RepoDetail {
        @TestVisible String name; 
        @TestVisible String url;
    }
}