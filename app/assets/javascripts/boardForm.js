// $(document).on('nested:fieldAdded:stages', function(event){
//   // this field was just inserted into your form
//   var field = event.field;
//   map_init(39.850033, -95.6500523, 4, 'pac-input', 'map-canvas')
//   // it's a jQuery object already! Now you can find date input
//   // var dateField = field.find('.date');
//   // and activate datepicker on it

//   // dateField.datepicker();
// })

// $(document).on('nested:fieldRemoved:stages', function(event){
//   var field = event.field;

//   field.remove();
//   })

// $(function() {
//   map_init(39.850033, -95.6500523, 4, 'pac-input', 'map-canvas')
//   $( "input[name=stageCount]" ).change(function() {
//     var $oneStage = $( '#one-stage' );
//     // var $multipleStages = $( '#multiple-stages' );
//   //   $( "p" ).html(
//   //     ".attr( \"checked\" ): <b>" + $oneStage.attr( "checked" ) + "</b><br>" +
//   //     ".prop( \"checked\" ): <b>" + $oneStage.prop( "checked" ) + "</b><br>" +
//   //     ".is( \":checked\" ): <b>" + $oneStage.is( ":checked" ) ) + "</b>";
//   //   $( "h3" ).html(
//   //     ".attr( \"checked\" ): <b>" + $multipleStages.attr( "checked" ) + "</b><br>" +
//   //     ".prop( \"checked\" ): <b>" + $multipleStages.prop( "checked" ) + "</b><br>" +
//   //     ".is( \":checked\" ): <b>" + $multipleStages.is( ":checked" ) ) + "</b>";
//   // }).change();
//   // if ($oneStage.prop("checked")){
//   //   console.log("one")
//   // }
//   // if ($multipleStages.prop("checked")){
//   //   console.log("multiple")
//   // }
//   });
// });

$(function() {
  map_init(39.850033, -95.6500523, 4, 'pac-input', 'map-canvas');

  function showError(error) {
    $('#form-errors').html(error);
    $('#form-errors').show();
  }

  $('#board-form').submit(function(e) {
    if ($('#board_stages_attributes_0_places_reference').val() == '') {
      showError("Please select a location on the map before continuing");
      $('#pac-input').focus();
      // e.preventDefault();
      return false
    }
  });
});