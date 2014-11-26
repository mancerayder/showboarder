$(function(){
  var amountProduct = $('#amount-product');
  var amountSb = $('#amount-sb');
  var amountCharity = $('#amount-charity');
  var amountTotal = $('#amount-total');

  var totalCalculator = function() {
    return parseInt(amountSb.val()) + parseInt(amountCharity.val()) + parseInt(amountProduct.val())
  }

  var totalFill = function(){
    amountTotal.html("$" + totalCalculator().toString() + ".00");  
  }

  amountProduct.change(function(){
    totalFill();
  });

  amountSb.change(function(){
    totalFill();
  });

  amountCharity.change(function(){
    totalFill();
  });

  totalFill();

  $('#stripeButton').click(function(){
    var token = function(res){
      var $input = $('<input type=hidden name=stripeToken />').val(res.id);
      $('form').append($input);
      console.log(res)
      console.log(res.email)
      $.ajax({
        type: "POST",
        url: "<%= board_show_checkout_path(@board, @show) %>",
        data: { reserve_code: "<%= @reserve_code %>",
                stripeToken: res.id,
                name: res.card.name,
                email: res.email,
                amount_base: <%= @amount %>,
                amount_tip: (parseInt(amountProduct.val()) - <%= @amount %>),
                amount_sb: parseInt(amountSb.val()),
                amount_charity:parseInt(amountCharity.val())
                 }, // TODO - clean this up to only send a js plainObject with the necessary data
        success: function(data) { poll(data.guid, 60) },
        error: function(data) { showError(data.responseJSON.error) }
      });
    };

    StripeCheckout.open({
      key:         '<%= ENV["STRIPE_TEST_KEY_PUBLISHABLE"] %>', // TODO - replace with live key in production
      address:     true,
      amount:      (totalCalculator() * 100).toString(),
      currency:    'usd',
      name:        'Showboarder',
      description: "<%= @tickets.count %> tickets for $" + totalCalculator().toString() + ".00", //"<%= @tickets.count%> tickets totalCalculator() %>)",
      email: "<%= current_user.email %>",
      panelLabel:  'Checkout',
      token:       token
    });

    return false;
  });

  function showError(error) {
    var form = $('#payment-form');
    $('#payment-errors').html(error);
    $('#payment-errors').show();
    // $('#pay-button').show();
    // $('#spinner-button').hide();
  }

  function poll(guid, num_retries_left) {
    console.log("Polling...");
    if (num_retries_left == 0) {
      showError("This seems to be taking too long. Email <a href=\"contact@showboarder.com\">contact@showboarder.com</a> and reference sale <strong>" + guid );
      return;
    }
    $.get("/status/" + guid, function(data) {

      if (data.status === "finished") {
        window.location = "/confirm/" + guid;
      } else if (data.status === "errored") {
        showError(data.error)
      } else {
        setTimeout(function() { poll(guid, num_retries_left - 1) }, 500);
      }
    });
  }

});