var Selector = {
  
  max_entries : 3,

  initialize : function(max_entries){
    
    this.max_entries = max_entries;
    
    this.initialize_masonry();

    var counter = $(".selected_photos_count");

    $(".select_photo").not(".already_entered").click(function(){
      var bttn = $(this),
          num_selected = $(".select_photo.selected").length + $(".select_photo.already_entered").length;

      if (num_selected<Selector.max_entries && !bttn.hasClass('selected')) {
        bttn.addClass("selected");
        bttn.siblings("input[type=radio]").attr('selected','selected');
      } else if (bttn.hasClass("selected")){
        bttn.removeClass("selected");
        bttn.siblings("input[type=radio]").removeAttr('selected');
      }
      
      counter.text( $(".select_photo.selected").length + $(".select_photo.already_entered").length );

      if ($(".select_photo.selected").length>0) {
        $("#submit_btn").removeClass('btn-default').addClass('btn-success');
      } else {
        $("#submit_btn").addClass('btn-default').removeClass('btn-success');
      }
    });

    $("form.select_photos").submit(function(){
      var f = $(this);

      if (!$(".select_photo.selected").length) {
        Flasher.show('danger',"You must select at least one photo to use in the contest.");
        
      } else {

        var photos = $.map($(".select_photo.selected"),function(el){
          var img = $(el).find("img");
          return {
            id:         img.attr('data-id'),
            text:       img.attr('data-text'),
            standard:   img.attr('data-standard'),
            low:        img.attr('data-low'),
            thumbnail:  img.attr('data-thumbnail')
          };
        });

        $.ajax({
          url      : f.attr('action'),
          type     : "POST",
          dataType : "JSON",
          data     : { 
            authenticity_token: $("#authenticity_token").val(), 
            provider: $("#provider").val(),
            photos: photos },
          success : function(data){
            window.location.assign("/your_entries");
          }
        });

      }

      return false;
    });

  },

  initialize_masonry : function(){
    var c = $("#selectable_photos");
    c.imagesLoaded( function() {
     c.masonry({ itemSelector: '.photo' });
    });
  }

};