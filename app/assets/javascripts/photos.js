$(function(){
  $("ul.photos").imagesLoaded(function(){     
    $("ul.photos").masonry({
      itemSelector: ".photo"
    });
  }).progress( function( instance, image ) {
    if (image.isLoaded) {
      $(image.img).fadeTo(1000,1);
    }
  });
});