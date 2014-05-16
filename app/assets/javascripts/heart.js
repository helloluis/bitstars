var Heart = {
  
  initialize: function(photos){
    this.user = CURRENT_USER;
    this.photos = photos;
    if (this.user) {
      this.initialize_hearts();
    }
  },

  initialize_hearts: function(){
    var that = this;
    $(".heart").click(function(){
      var h = $(this);
      if (h.find(".glyphicon").hasClass('liked')) {
        that.unheart( h, h.attr('data-id') );
      } else {
        that.heart( h, h.attr('data-id') );
      }
    });
  },

  unheart : function(el, id) {
    $.ajax({
      url: "/photos/" + id + "/unheart",
      type: "GET",
      success : function(data){
        el.find(".glyphicon").removeClass("liked");
        $(".like_count").text(data.count);
      }
    });
  },

  heart : function(el, id) {
    $.ajax({
      url: "/photos/" + id + "/heart",
      type: "GET",
      success : function(data){
        el.find(".glyphicon").addClass("liked");
        $(".like_count").text(data.count);
      }
    });
  }

};