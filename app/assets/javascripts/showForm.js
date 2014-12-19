
      $(function() {

        var ticketingType = $("#ticketing_type");
        var priceAdvField = $("#price-adv");
        var priceDoorField = $("#price-door");

        var priceDoor = priceDoorField.val()
        var priceAdv = priceAdvField.val();

        function ticketingTypeUpdate() {
          if (ticketingType.val() == "Just list the show"){
            console.log("Just list");
            priceDoor = priceDoorField.val()
            priceAdv = priceAdvField.val();
            priceAdvField.val(0);
            priceDoorField.val(0);
            priceAdvField.parent().parent().parent().hide();
            priceDoorField.parent().parent().parent().hide();
          } else {
            console.log("Sell tickets")
            priceAdvField.val(priceAdv);
            priceDoorField.val(priceDoor);
            priceAdvField.parent().parent().parent().show();
            priceDoorField.parent().parent().parent().show();
          }
        }

        ticketingTypeUpdate();

        ticketingType.change(function() {
          ticketingTypeUpdate();
        });

        function showError(error) {
          $('#form-errors').html(error);
          $('#form-errors').show();
        }

        $('#show-form .input-group.date').datepicker({
            todayHighlight: true
        });

        $('#show-form').submit(function(e) {
          if ($('#show-date').val() == '') {
            showError("Show date field cannot be empty.");
            $('#show-date').focus();
            // e.preventDefault();
            return false
          }
        })

        function eretrieve( value, eid, field ) {
          // grabs act-specific links, makes and fills a field for each
          // makes and fills hidden field for echonest_id
          $.ajax({
            url: "/eretrieve/" +"?act=" + value + "&eid="+ eid,
            dataType: "json",
            ///////////////////////////////////
            success: function (data) {
              var echoField = field.find('.hidden').filter('input');
              var echoButton = field.find('.btn-echoclear');
              var echoReminder = field.find('#echo-reminder')
              var echoTip = field.find('#echo-tip')

              if (echoButton.hasClass("btn-echoclear-hide")) {
                echoButton.removeClass("btn-echoclear-hide");
                echoReminder.removeClass("btn-echoclear-hide");
                echoTip.addClass("btn-echoclear-hide");
              }

              echoButton.click(function() {
                field.find("a.btn-ext-link-remove.remove_nested_fields").click();
                
                echoField.val("");

                if (echoField.val() === "") {
                  if (!echoButton.hasClass("btn-echoclear-hide")) {
                    echoButton.addClass("btn-echoclear-hide");
                    echoReminder.addClass("btn-echoclear-hide");
                    echoTip.removeClass("btn-echoclear-hide");
                  }
                } else {
                  if (echoButton.hasClass("btn-echoclear-hide")) {
                    echoButton.removeClass("btn-echoclear-hide");
                    echoReminder.removeClass("btn-echoclear-hide");
                    echoTip.addClass("btn-echoclear-hide");
                  }
                }              
              });

              echoField.val(eid);

              var urls = data["urls"]
              for (var key in urls) {
                if (urls.hasOwnProperty(key)) {
                  $(field).one('nested:fieldAdded', function(event){
                    var dropdown = event.field.find('select').first();
                    if (key == 0 || key == 1 || key == 2 || key == 3 || key == 4 || key == 5 ){
                      dropdown.prop('selectedIndex', key);
                    }
                    event.field.find('.string').filter('input').first().val(urls[key]);
                    var dropdown = event.field.find('select').first();
                  });
                  field.find('a.add_nested_fields').click();
                }
              }
            }
            //////////////////////////
          });
        };

        $(document).on('nested:fieldAdded:acts', function(event){
          // this field was just inserted into your form
          var field = event.field; 
          // it's a jQuery object already! Now you can find date input
          var bandField = field.find('.string').filter('input').first();

          // and activate datepicker on it
          bandField.autocomplete({
            source: function( request, response ) {
              $.ajax({
                url: "/esuggest/" + request.term,
                dataType: "json",
                success: function( data ) {
                  response( data );
                }
              });
            },
            minLength: 3, 
            select: function( event, ui ) {
              field.find('.hidden').filter('input').val(""); // in case other act info already filled
              field.find("a.btn-ext-link-remove.remove_nested_fields").click();
              
              eretrieve(ui.item.value, ui.item.id, field);
            }
          });
        })
      });
