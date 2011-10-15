$(document).ready( function() {
  var links = $("a.user_destroyer");
  for( var i=0; i < links.length; i++) {
    $(links[i]).click( function(){
      if(!confirm("Are you sure you want to delete this user? This operation cannot be reversed. "
      + "Click OK to delete the user, or click Cancel to keep the user."
      )){
        return false;
      }
    });
  }
});

