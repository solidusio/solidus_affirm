(function(){
  /* wait for the DOM to be ready */
  affirm.ui.ready(function(){
    $(function() {
      /*****************************************************\
          setup loading and cancel events for the form
      \*****************************************************/
      affirm.checkout.on("cancel", function(){
        $("#checkout_form_payment input.disabled")
          .attr("disabled", false)
          .removeClass("disabled");
      });

      var button_text = $("#checkout_form_payment input[type='submit']").val();

      $("#checkout_form_payment input[type='submit']").on("loading", function(){
        button_text = $(this).val();
        $(this).val("Loading...");
      })

      .on("done_loading", function(){
        $(this).val(button_text);
      });

      /*****************************************************\
          handle continue button clicks with .open()
      \*****************************************************/
      $('#checkout_form_payment').submit(function(e){
        var checkedPaymentMethod = $('div[data-hook="checkout_payment_step"] input[type="radio"]:checked').val();
        var affirmPaymentMethodId = $("#affirm_checkout_payload").data("paymentgateway")
        if (affirmPaymentMethodId.toString() === checkedPaymentMethod) {
          var $submit_button = $(this).find("input[type='submit']");

          /*****************************************************\
              set the shared checkout data
          \*****************************************************/
          affirm.checkout($("#affirm_checkout_payload").data("affirm"));

          // show the loading message
          $submit_button.trigger("loading");

          // submit the checkout
          affirm.checkout.post();

          e.preventDefault();
          return false;
        }
      });
    });
  });
}());
