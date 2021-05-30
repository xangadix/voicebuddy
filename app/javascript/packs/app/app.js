// TEST API
/*
function testApi() {
  fetch('/app/test_api')
    .then( function(resp) { console.log("response:", resp)} )
    .then( function(data) {
      console.log("API got data: ", data)
      //document.getElementById('test').innerHTML = ' has data ' + data.var1
  });
}
*/
/*
function receiver(event) {
  console.log("iframe got an event from app:", event.origin, event.data)
  var command = event.data.split("||")[0]
  var source = event.data.split("||")[1]
  var msg = event.data.split("||")[2]
  console.log("command: ", command)
  console.log("source: ", source)
  console.log("message: ", msg)


  if (source == "WEB") {
    console.log("nevermind, its only me.")
    return

  } else {

    // source is APP
    // token_removed_ok?
    // token_set_ok?
    // clientTokenWasFound
    if (command == "SET_TOKEN") {
      console.log("got local token! ", msg)
      // document.getElementById('localtoken_display').innerHTML = msg
    }
  }
}

// LOGIN failed message
console.log("check ", window.location, window.location.hash.indexOf('login_failed') != -1)
if (window.location.hash.indexOf('login_failed') != -1) {
  document.getElementById('login_message').innerHTML = 'Login Failed!'
}

// init
window.addEventListener('message', receiver, false);
window.onload = function() {
  console.log("onload!")
  window.parent.postMessage("WEB_READY||WEB||message from web", "*")
  // window.parent.postMessage("SET_TOKEN||WEB||@{client_token}", "")
  // window.parent.postMessage("SET_REMINDER||WEB||datatime, exercise", "")
  // window.parent.postMessage("REMOVE_REMINDER||WEB||reminder_id", "")
}
*/
