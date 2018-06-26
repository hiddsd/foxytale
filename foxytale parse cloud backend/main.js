//dev version
// Use Parse.Cloud.define to define as many cloud functions as you want



Parse.Cloud.define("getFacebookAppLink", function(request, response) {
Parse.Cloud.httpRequest({
  url: 'https://graph.facebook.com/app/app_link_hosts',
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: {
    access_token : 'fb_access_token',
    name : request.params.applink,
    ios : '[{"url" : "'+request.params.applink+'","app_store_id" : 955868746,"app_name" : "Foxytale",},]',
    web : '{"should_fallback" : false,}'
  }
}).then(function(httpResponse){
  //success

  console.log(httpResponse.text);
  var data = JSON.parse(httpResponse.text);
  Parse.Cloud.httpRequest({
  url: 'https://graph.facebook.com/'+data.id+'?access_token='+access_token+'&fields=canonical_url&pretty=true'
}).then(function(httpResponse){
  //success
  var data = JSON.parse(httpResponse.text);
  response.success(data.canonical_url);
}, function(httpResponse) {
  //error
  console.error('Request failed with response code ' + httpResponse.status);
  response.error("appLink failed inner");
});
}, function(httpResponse) {
  //error
  console.error('Request failed with response code ' + httpResponse.status);
  response.error("appLink failed outa");
});
});

/*
var Buffer = require('buffer').Buffer;

Parse.Cloud.define("getFacebookAppLink", function(request, response) {

var access_token = new Buffer(access_token,'utf8');
var name = new Buffer(request.params.applink,'utf8');
var ios = new Buffer('[{"url" : "'+request.params.applink+'","app_store_id" : 955868746,"app_name" : "Foxytale",},]','utf8');
var web = new Buffer('{"should_fallback" : false,}','utf8');

var contentBuffer = Buffer.concat([access_token, name, ios, web]);

Parse.Cloud.httpRequest({
  url: 'https://graph.facebook.com/app/app_link_hosts',
  method: 'POST',
  headers: {
    'Content-Type': 'text/html; charset=utf-8'
  },
  body: contentBuffer
}).then(function(httpResponse){
  //success
  console.log(httpResponse.text);
  var data = JSON.parse(httpResponse.text);
  Parse.Cloud.httpRequest({
  method: 'POST',
  url: 'https://graph.facebook.com/'+data.id,
  headers: {
    'Content-Type': 'application/json;charset=utf-8'
  },
  body: {
    access_token : "fb_access_token",
    fields : canonical_url,
    pretty : true
  }
}).then(function(httpResponse){
  //success
  console.log(httpResponse.text);
  var data = JSON.parse(httpResponse.text);
  response.success(data.canonical_url);
}, function(httpResponse) {
  //error
  console.error('Request failed with response code ' + httpResponse.status);
  response.error("appLink failed");
});
}, function(httpResponse) {
  //error
  console.error('Request failed with response code ' + httpResponse.status);
  response.error("appLink failed");
});
}); */



Parse.Cloud.define("sendPushToUser", function(request, response) {
  var senderUser = request.user;
  var recipientUserId = request.params.recipientId;
  var message = request.params.message;

  // Send the push.
  // Find devices associated with the recipient user
  var recipientUser = new Parse.User();
  recipientUser.id = recipientUserId;
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo("currentUser", recipientUser);
  
  // Send the push notification to results of the query
  Parse.Push.send({
    where: pushQuery,
    data: {
      alert: message,
      badge: "increment",
      sound: ""
    }
  }).then(function() {
      response.success("Push was sent successfully.");
  }, function(error) {
      response.error("Push failed to send with error: " + error.message);
  });
});


Parse.Cloud.afterDelete("Story", function(request) {
  var query = new Parse.Query("Activity");
  query.equalTo("toStory", request.object);
 
  query.find().then(function(activitys) {
    return Parse.Object.destroyAll(activitys);
  }).then(function(success) {
    // The related activitys were deleted
  }, function(error) {
    console.error("Error deleting related activitys " + error.code + ": " + error.message);
  });

  var query = new Parse.Query("Photo");
  query.equalTo("story", request.object);
 
  query.find().then(function(photos) {
    return Parse.Object.destroyAll(photos);
  }).then(function(success) {
    // The related photos were deleted
  }, function(error) {
    console.error("Error deleting related photos " + error.code + ": " + error.message);
  });
});

function countStorys(user){
  var storys = new Parse.Query("Story");
  storys.equalTo("creator", user);
  return storys.count();
}

function countContributes(user){
  var conntributes = new Parse.Query("Activity");
  conntributes.equalTo("fromUser", user);
  conntributes.equalTo("type","contribute");
  return conntributes.count();
}

Parse.Cloud.define("profile", function(request, response) {

  if(request.params.userId == null){
    var user = request.user;
  }
  else{
    var userId = request.params.userId;

    var user = new Parse.User();
    user.id = userId;
  }
    // wait for them all to complete using Parse.Promise.when()
    // result order will match the order passed to when()
    Parse.Promise.when([countStorys(user), countContributes(user)]).then(function(countOfStorys, countOfConntributes) {
        response.success({
            storys: countOfStorys,
            conntributes: countOfConntributes
        });
    });
});

//Background job flags user with inapropriate flaged pictures
Parse.Cloud.job("flagUsers", function(request, status) {
  // Set up to modify user data
  Parse.Cloud.useMasterKey();  
  // Query for flaged photos
  var photoQuery = new Parse.Query("Photo");
  photoQuery.equalTo("flaged", true);
  photoQuery.include("user");
 
  photoQuery.each(function(photo){
    //Increase user flagCount
    var user = photo.get("user");
    user.increment("reportCounter");
    return user.save();
  }).then(function() {
    // Set the job's success status
    status.success("Migration completed successfully.");
  }, function(error) {
    // Set the job's error status
    status.error("Uh oh, something went wrong.");
  });
});

//Job that deletes User with given ID
Parse.Cloud.job("deleteUser", function(request, status) {
  Parse.Cloud.useMasterKey();                                                                                                                       
  var query = new Parse.Query(Parse.User);                                                                                                          
  query.get(request.params.userId, {                                                                                                              
    success: function(user) {                                                                                                                       
      user.destroy({                                                                                                                                
        success: function() {                                                                                                                       
          status.success('User deleted');                                                                                                         
        },                                                                                                                                          
        error: function(error) {                                                                                                                    
          status.error(error);                                                                                                                    
        }                                                                                                                                           
      });                                                                                                                                           
    },                                                                                                                                              
    error: function(error) {                                                                                                                        
      status.error(error);                                                                                                                        
    }                                                                                                                                               
  });                                                                                                                                               
});

Parse.Cloud.afterDelete(Parse.User, function(request) {
  Parse.Cloud.useMasterKey();

  //Delete all Pictures
  var query = new Parse.Query("Photo");
  query.equalTo("user", request.object);
  query.find().then(function(photos) {
    return Parse.Object.destroyAll(photos);
  }).then(function(success) {
    // The related activitys were deleted
  }, function(error) {
    console.error("Error deleting related photos " + error.code + ": " + error.message);
  });

  //Delete all Storys + All Pictures to that storys (durch after delete story)
  var query = new Parse.Query("Story");
  query.equalTo("creator", request.object);
  query.find().then(function(storys) {
    return Parse.Object.destroyAll(storys);
  }).then(function(success) {
    // The related activitys were deleted
  }, function(error) {
    console.error("Error deleting related storys " + error.code + ": " + error.message);
  });

  //Delete all Activitys (like,contribute,friend)
  var query = new Parse.Query("Activity");
  query.equalTo("fromUser", request.object);
  query.find().then(function(activitys) {
    return Parse.Object.destroyAll(activitys);
  }).then(function(success) {
    // The related activitys were deleted
  }, function(error) {
    console.error("Error deleting related activitys " + error.code + ": " + error.message);
  });

  //Delete all friendship Activitys with the user
  var query = new Parse.Query("Activity");
  query.equalTo("toUser", request.object);
  query.find().then(function(activitys) {
    return Parse.Object.destroyAll(activitys);
  }).then(function(success) {
    // The related activitys were deleted
  }, function(error) {
    console.error("Error deleting related friendships " + error.code + ": " + error.message);
  });

});

Parse.Cloud.beforeSave("Activity", function(request,response) {
    if (request.user == null) {
        response.error();
    } else {
        response.success();
    }
});

Parse.Cloud.beforeSave("Photo", function(request,response) {
    if (request.user == null) {
        response.error();
    } else {
        response.success();
    }
});

Parse.Cloud.beforeSave("Story", function(request,response) {
    if (request.user == null) {
        response.error();
    } else {
        response.success();
    }
});


