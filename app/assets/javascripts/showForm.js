
      $(function() {

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
              console.log(data)
              var echoField = field.find('.hidden').filter('input');
              var echoButton = field.find('button');

              if (echoButton.hasClass("btn-echoclear")) {
                echoButton.removeClass("btn-echoclear");
              }

              echoButton.click(function() {
                field.find('input').not(field.find(".required")).val('');

                
                field.find("a.remove_nested_fields:contains(Remove this link)").click();
                if (echoField.val() === "") {
                  if (!echoButton.hasClass("btn-echoclear")) {
                    echoButton.addClass("btn-echoclear");
                  }
                } else {
                  if (echoButton.hasClass("btn-echoclear")) {
                    echoButton.removeClass("btn-echoclear");
                  }
                }              
              });
              echoField.val(eid);

              var urls = data["urls"]
              for (var key in urls) {
                if (urls.hasOwnProperty(key)) {
                  $(field).on('nested:fieldAdded', function(event){
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
              eretrieve(ui.item.value, ui.item.id, field);
            }
          });
        })
      });
