@RestResource(urlMapping='/webhooks')
global with sharing class GitHubWebHookSubscription {
    @HttpPost
    global static void handlePush() {
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            
            String hashVal = req.headers.get('X-Hub-Signature-256');
            Blob reqBody = req.requestBody;
            Blob macVal = Crypto.generateMac('hmacSHA256', reqBody, Blob.valueOf('secret765@gitRepo'));
            String macString = 'sha256='+EncodingUtil.convertToHex(macVal);
            System.debug('macString:: '+macString);
            System.debug('hashVal:: '+hashVal);
            
            if(hashVal == macString)
            {
                System.debug('request1:: '+req.requestBody.toString());
                RequestBody gitNotif = (RequestBody)JSON.deserialize(reqBody.toString(), RequestBody.class);
                System.debug('request2:: '+gitNotif);
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(new ResponseBody('Success','Notification Received')));
            }
            else
            {
                res.statusCode = 401;
                res.responseBody = Blob.valueOf(JSON.serialize(new ResponseBody('Failure','Invalid Subscription')));
            }
        } catch(Exception ex){
            System.debug('Some Exception:: '+ex.getMessage());
        }
    }
    
    public class ResponseBody{
        String response;
        String message;
        public ResponseBody(String resp, String msg){
            response = resp;
            message = msg;
        }
    }
    
    public class RequestBody {
        List<CommitBody> commits; 
        RepoDetail repository;
    }
    
    public class CommitBody {
        CommitterDetail committer; 
        String timestamp;
        String url;
        List<String> added;
        List<String> removed;
        List<String> modified;
    }
    
    public class CommitterDetail {
        String name; 
        String email;
    }
    
    public class RepoDetail {
        String name; 
        String url;
    }
}