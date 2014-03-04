$(function() {
   $('#flash').delay(500).fadeIn('normal', function() {
      $(this).delay(4500).fadeOut();
      $('#beta_form').fadeOut();
   });
});