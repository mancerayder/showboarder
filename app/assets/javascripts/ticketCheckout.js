$(function () {
  var expiration = new Date();
  expiration = new Date(<%= (t.reserved_at + 15.minutes).to_i * 1000 %>);
  $('#defaultCountdown<%= t.id %>').countdown({until: expiration, format:'MS', compact:'true'});
});