$(function () {

  //Custom Checkbox For Light Theme
  $("input").iCheck({
    checkboxClass: 'icheckbox_square-blue',
    increaseArea: '20%'
  });


  //Custom Checkbox For Dark Theme
  $(".dark input").iCheck({
    checkboxClass: 'icheckbox_polaris',
    increaseArea: '20%'
  });


  //TextBox Focus Event
  $(".form-control").focus(function () {
    $(this).closest(".textbox-wrap").addClass("focused");
  }).blur(function () {
    $(this).closest(".textbox-wrap").removeClass("focused");
  });

});