$(function() {
  $("#sms_send_button").click(function() {
    $("#sms_sending_success").text("");
    $("#sms_sending_error").text("");
    var text = $("#sms_content").val();
    var dataString = 'dest='+ $("#sms_dest").val() + '&message='+text;
    $.ajax({
      type: "POST",
      url: "/message/send",
      data: dataString,
      dataType: "json",
      success: function(data) {
        if (data.success) {
          $("#sms_sending_success").text(data.result);
        } else {
          $("#sms_sending_error").text(data.result);
        }
      },
      failure: function() {
        $("#sms_sending_error").text("Error sending message");
      }
    });
    return false;
  });
});