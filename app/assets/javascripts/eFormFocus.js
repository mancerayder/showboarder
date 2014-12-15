$(function () {

  //TextBox Focus Event
  $(".form-control").focus(function () {
    $(this).closest(".textbox-wrap").addClass("focused");
  }).blur(function () {
    $(this).closest(".textbox-wrap").removeClass("focused");
  });

});