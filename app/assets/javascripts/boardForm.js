$(function() {
  map_init(39.850033, -95.6500523, 4, 'pac-input', 'map-canvas');

  function showError(error) {
    $('#form-errors').html(error);
    $('#form-errors').show();
  }

  function extLinkPrepend(event) {
    event.field.find('.url').val(event.field.find('.ext-link-select').val().toLowerCase() + ".com/");
  }

  $(document).on('nested:fieldAdded', function (event) {
    extLinkPrepend(event)
    event.field.find('.ext-link-select').change(function () {
      extLinkPrepend(event);
    });
  });

  $('#board-form').submit(function(e) {
    if ($('#board_stages_attributes_0_places_reference').val() == '') {
      showError("Please select a location on the map before continuing");
      $('#pac-input').focus();
      $('#map-plz').css("color","red");
      return false
    }
  });
});