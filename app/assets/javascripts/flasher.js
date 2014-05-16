var Flasher = {
  
  show: function(alert_type, str){
    $("<div class='alert alert-" + alert_type + " fixed'><button type='button' class='close' data-dismiss='alert'>&times;</button><strong>" + str + "</strong></div>").appendTo('body');
  }

}