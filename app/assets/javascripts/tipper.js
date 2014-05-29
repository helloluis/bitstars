var Tipper = {
  
  initialize: function(){
    this.current_user = CURRENT_USER;
    this.rates = RATES;
    this.form = $("form.tip-form");
    this.initialize_buttons();
  },

  initialize_buttons: function(){
    
    var that = this,
        tip_field = $("#tip_amount_in_btc"),
        convert = function(){
          var amount = tip_field.val();
          $(".value_in_php").html( accounting.formatMoney( (amount * that.rates['PHP']),'&#8369;' ) );
          $(".value_in_usd").html( accounting.formatMoney( (amount * that.rates['USD']),'$' ) );
        };

    tip_field.change(convert).keyup(convert);

    convert();

    that.form.submit(function(){
      
      if (!that.current_user) {
        that.show_error("You need to login <a href='/users/auth/instagram'>via Instagram</a> or <a href='/users/auth/facebook'>Facebook</a> in order to tip other users.");
        return false;
      }

      var amount = parseFloat(tip_field.val()),
          min = parseFloat(tip_field.attr('min')),
          max = parseFloat(tip_field.attr('max'));

      if (amount<min || amount>max) {
        that.show_error("Your tip amount must be between " + min + " and " + max + " BTC.");
        return false;
      }

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
            that.display_invoice(data.invoice_address_with_amount, data.invoice_address, data.id);
          }
        },
        complete : function(x,s) {
          that.form.find(".btn").button('reset');
        }
      });

      return false;
    });
    
  },

  display_invoice: function(invoice_address_with_amount, naked_invoice_address, remittance_id){
    var that = this;
    $("#qr_code").attr( 'src', $("#qr_code").attr('data-src')+escape(invoice_address_with_amount) );
    $("#invoice_address").
      bind('focus',function(){
        var el = this;
        el.select();
        $(el).bind('mouseup', function(){
          el.onmouseup = null;
          return false;
        });
      }).
      val(naked_invoice_address);
    $("#invoice").modal();
    $('#invoice').on('hidden.bs.modal', function (e) {
      $("#qr_code").attr('src','');
      $("#invoice_address").val("");
    });
  },

  show_error: function(str) {
    Flasher.show("danger", str);
  }
}