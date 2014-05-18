var Tipper = {
  
  initialize: function(){
    this.current_user = CURRENT_USER;
    this.form = $("form.tip-form");
    this.initialize_buttons();
  },

  initialize_buttons: function(){
    
    var that = this;

    that.form.submit(function(){
      
      that.form.find(".btn").button('loading');

      $.ajax({
        url      : that.form.attr('action'),
        data     : that.form.serializeArray(),
        type     : "POST",
        dataType : "JSON",
        success  : function(data) {
          if (data.errors) {
            that.show_error(data.errors);
          } else {
            that.display_invoice(data.invoice_address_with_amount, data.id);
          }
        },
        complete : function(x,s) {
          that.form.find(".btn").button('reset');
        }
      });

      return false;
    });
    
  },

  display_invoice: function(invoice_address_with_amount, remittance_id){
    var that = this;
    $("#qr_code").attr( 'src', $("#qr_code").attr('data-src')+escape(invoice_address_with_amount) );
    $("#invoice_address").val(invoice_address_with_amount);
    $("#invoice").modal();
    // $('#invoice').on('hidden.bs.modal', function (e) {
    //   // that.redirect_to_thanks(remittance_id);
    // });
  },

  show_error: function(str) {
    $("<div class='alert alert-danger'><button type='button' class='close' data-dismiss='alert'>&times;</button><strong>" + str + "</strong></div>").appendTo('body');
  }
}