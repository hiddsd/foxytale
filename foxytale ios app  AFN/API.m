//
//  API.m
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "API.h"
#import "StoryItem.h"
#import "SSKeychain.h"
#import "JSONResponseSerializerWithData.h"
#import "PageStoryViewController.h"
#import "PublishStoryViewController.h"

//simulator
#define kAPIHost @""
#define kAPIPath @""
#define url @""


@interface API() {
    int retries;
    PageStoryViewController *progressViewPage;
    PublishStoryViewController *progressViewPublish;
    int kind;
}
@end

@implementation API


#pragma mark - Singleton methods
/**
 * Singleton methods
 */
+(API*)sharedInstance
{
    static API *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIHost]];
    });
    return sharedInstance;
}

#pragma mark - init
//intialize the API class with the destination host name

-(API*)init
{
    //call super init
    self = [super init];
    retries = 0;
    return self;
}

-(BOOL)isAuthorized
{
    // Get the stored data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    
    return [[user objectForKey:@"IdUser"] intValue]>0;
}


-(void)commandWithParams:(NSMutableDictionary*)initialParams onCompletion:(JSONResponseBlock)completionBlock
{
    
    self.responseSerializer = [JSONResponseSerializerWithData serializer];
    self.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"application/json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:initialParams];
    
    NSArray* uploadFiles = nil;
    if ([params objectForKey:@"storyItems"]) {
        uploadFiles = (NSArray*)[params objectForKey:@"storyItems"];
        [params removeObjectForKey:@"storyItems"];
    }
    
    NSData* uploadFile = nil;
    if ([params objectForKey:@"file"]) {
        uploadFile = (NSData*)[params objectForKey:@"file"];
        [params removeObjectForKey:@"file"];
    }
    
    if ([params objectForKey:@"progressView"]) {
        if([[params objectForKey:@"progressView"] isKindOfClass:[PageStoryViewController class]]){
            progressViewPage = (PageStoryViewController*)[params objectForKey:@"progressView"];
            kind = 1;
        }
        else if([[params objectForKey:@"progressView"] isKindOfClass:[PublishStoryViewController class]]){
            progressViewPublish = (PublishStoryViewController*)[params objectForKey:@"progressView"];
            kind = 2;
        }
        [params removeObjectForKey:@"progressView"];
    }
    
    //NSLog(@"sended Params: %@", params);
    
    if(uploadFiles || uploadFile){
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"aplication/json"];
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
            if(uploadFiles){
                for(StoryItem *storyItem in uploadFiles){
                    NSData *imageData = UIImageJPEGRepresentation(storyItem.imageWithText,70);
                    [formData appendPartWithFileData:imageData name:@"files[]" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
                }
            }
            else if(uploadFile){
                [formData appendPartWithFileData:uploadFile
                                            name:@"file"
                                        fileName:@"photo.jpg"
                                        mimeType:@"image/jpeg"];
            }
        } error:nil];
        
        NSProgress *progress;
        
        NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if(kind == 1){
                [progress removeObserver:progressViewPage forKeyPath:@"fractionCompleted" context:NULL];
                kind = 0;
            }
            else if(kind == 2){
                [progress removeObserver:progressViewPublish forKeyPath:@"fractionCompleted" context:NULL];
                kind = 0;
            }
            if (error) {
                //failure :(
                NSLog(@"Error: %@", error);
                completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
            } else {
                //success!
                
                //if authentification expired
                //repead request
                NSDictionary *response = responseObject;
                if ([@"Authorization required" compare:[response objectForKey:@"error"]]==NSOrderedSame || [@"0007" compare:[response objectForKey:@"error"]]==NSOrderedSame) {
                    if(retries < 2){
                        retries++;
                        [self repeatRequest:initialParams onCompletion:completionBlock];
                    }
                    else{
                        retries = 0;
                        completionBlock(responseObject);
                    }
                }
                else{
                    completionBlock(responseObject);
                }
            }
        }];
        
        [task resume];
        
        // Observe fractionCompleted using KVO
        if(kind == 1){
            [progress addObserver:progressViewPage
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        }
        else if(kind == 2){           
            [progress addObserver:progressViewPublish
                       forKeyPath:@"fractionCompleted"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
        }
        
        
        
        
        
        
        
        
        
        
        
        
        /*
        [self POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
            if(uploadFiles){
                for(StoryItem *storyItem in uploadFiles){
                    NSData *imageData = UIImageJPEGRepresentation(storyItem.imageWithText,70);
                    [formData appendPartWithFileData:imageData name:@"files[]" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
                }
            }
            else if(uploadFile){
                [formData appendPartWithFileData:uploadFile
                                            name:@"file"
                                        fileName:@"photo.jpg"
                                        mimeType:@"image/jpeg"];
            }
        }success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //success!
            
            //if authentification expired
            //repead request
            NSDictionary *response = responseObject;
            if ([@"Authorization required" compare:[response objectForKey:@"error"]]==NSOrderedSame || [@"0007" compare:[response objectForKey:@"error"]]==NSOrderedSame) {
                if(retries < 2){
                    retries++;
                    [self repeatRequest:initialParams onCompletion:completionBlock];
                }
                else{
                    retries = 0;
                    completionBlock(responseObject);
                }
            }
            else{
                completionBlock(responseObject);
            }
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //failure :(
            NSLog(@"Error: %@", error);
            completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
        }];
         */
    }
    else{
        [self POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //success!
            //if authentification expired
            //repead request
            NSDictionary *response = responseObject;
            if ([@"Authorization required" compare:[response objectForKey:@"error"]]==NSOrderedSame || [@"0007" compare:[response objectForKey:@"error"]]==NSOrderedSame) {
                if(retries < 2){
                    retries++;
                    [self repeatRequest:initialParams onCompletion:completionBlock];
                }
                else{
                    retries = 0;
                    completionBlock(responseObject);
                }
            }
            else{
                
                completionBlock(responseObject);
            }
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //failure :(
            NSLog(@"Error: %@", error);
            completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
        }];
    }
}

-(void)repeatRequest:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock{
    NSLog(@"Refresh Session and try again");
    
    //get stored Username and Password
    NSString* username = [[self getUser] objectForKey:@"username"];
    NSString* hashedPassword = [SSKeychain passwordForService:@"StoryStrips" account:username];
    
    //Login
    NSString* command = @"login";
    NSMutableDictionary* loginparams =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  username, @"username",
                                  hashedPassword, @"password",
                                  nil];
    
    //make the call to the web API
    [self commandWithParams:loginparams
                               onCompletion:^(NSDictionary *json) {
                                   //result returned
                                   NSDictionary* res = [[json objectForKey:@"result"] objectAtIndex:0];
                                   
                                   if ([json objectForKey:@"error"]==nil && [[res objectForKey:@"IdUser"] intValue]>0) {
                                       //success
                                       //repeat request
                                       [self commandWithParams:params onCompletion:completionBlock];
                                   } else {
                                       //error
                                       //ToDo redirect to login Screen
                                       
                                   }
                               }];
}

-(NSURL*)urlForImageWithId:(NSNumber*)IdPhoto IdUser:(NSNumber*)IdUser IdStory:(NSNumber*)IdStory isThumb:(BOOL)isThumb {
    NSString* urlString = [NSString stringWithFormat:@"%@/%@upload/%@/%@/%@%@.jpg",
                           kAPIHost, kAPIPath, IdUser, IdStory, IdPhoto, (isThumb)?@"-thumb":@""
                           ];
    return [NSURL URLWithString:urlString];
}

-(void)setUser:(NSDictionary*)user password:(NSString*)password
{
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:user forKey:@"user"];
    [defaults synchronize];
    
    [SSKeychain setPassword:password forService:@"StoryStrips" account:[user objectForKey:@"username"]];
}

-(NSDictionary*)getUser{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    
    return user;
}

-(void)logout{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    [SSKeychain deletePasswordForService:@"StoryStrips" account:[user objectForKey:@"username"]];
    [defaults removeObjectForKey:@"user"];
}

@end
