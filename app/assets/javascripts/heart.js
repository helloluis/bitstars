var Heart = {
  
  initialize: function(photos){
    this.user = CURRENT_USER;
    
    if (photos) {
      this.photos = photos;
    } else {
      this.standalone = true;
    }
    
    if (this.user) {
      this.initialize_hearts();
      this.initialize_photos();
    } else {
      this.initialize_register_instructions();
    }
  },

  initialize_hearts: function(){
    var that = this;
    if (that.standalone===true) {
      $(".heart").click(function(){
        var h = $(this);
        if (h.find(".glyphicon").hasClass('liked')) {
          that.unheart( h, h.attr('data-id') );
        } else {
          that.heart( h, h.attr('data-id') );
        }
      });
    } else {
      $(".heart").click(function(){
        var h = $(this);
        if (h.parents(".likes").hasClass('btn-danger')) {
          that.unheart( h, h.attr('data-id') );
        } else {
          that.heart( h, h.attr('data-id') );
        }
      });
    }
    
  },

  initialize_photos: function(){

    var that =  this,
        ids  =  $.map($(".likes"),function(el){
                  return $(el).attr('data-id');
                });
    
    $.ajax({
      url      : "/photos/hearts",
      type     : "GET",
      data     : { photo_ids : ids },
      dataType : "JSON",
      success  : function(data){
        _.each(data.ids,function(id){
          that.display_heart($(".heart[data-id=" + id + "]"));
        });
      }
    });

  },

  unheart : function(el, id) {
    var that = this;
    $.ajax({
      url: "/photos/" + id + "/unheart",
      type: "GET",
      success : function(data){
        that.remove_heart(el,data.count);
      }
    });
  },

  heart : function(el, id) {
    var that = this;
    $.ajax({
      url: "/photos/" + id + "/heart",
      type: "GET",
      success : function(data){
        that.display_heart(el,data.count);
      }
    });
  },

  display_heart: function(el, count) {
    if (!this.standalone) {
      el.parents(".likes").addClass("btn-danger");
      el.find(".heart-label").text( el.find(".heart-label").attr('data-unlike') );
      if (count) { 
        el.parents(".likes").find(".like_count").text(count); 
      }
    } else {
      el.find(".glyphicon").addClass("liked");
      el.find(".heart-label").text( el.find(".heart-label").attr('data-unlike') );
      el.removeClass('btn-default').addClass('btn-danger');  
      if (count) { 
        $(".like_count").text(count); 
      }
    }
    
  },

  remove_heart: function(el, count) {
    if (!this.standalone) {
      el.parents(".likes").removeClass("btn-danger");
      el.find(".heart-label").text( el.find(".heart-label").attr('data-like') );
      if (count) { 
        el.parents(".likes").find(".like_count").text(count); 
      }
    } else {
      el.find(".glyphicon").removeClass("liked");
      el.find(".heart-label").text( el.find(".heart-label").attr('data-like') );
      el.removeClass('btn-danger').addClass('btn-default');  
      if (count) { 
        $(".like_count").text(count); 
      }
    }
    
  },

  initialize_register_instructions : function(){
    
    $(".heart").click(function(){
      Flasher.show("warning", "You need to login <a href='/users/auth/instagram'>via Instagram</a> or <a href='/users/auth/facebook'>Facebook</a> in order to like something.");
    });

  }

};