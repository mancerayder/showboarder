// Activates Stellar.js jQuery Plugin - Plugin does not initialize on mobile devices listed below

var isMobile = {
  Android: function() {
    return navigator.userAgent.match(/Android/i);
  },
  BlackBerry: function() {
    return navigator.userAgent.match(/BlackBerry/i);
  },
  iOS: function() {
    return navigator.userAgent.match(/iPhone|iPad|iPod/i);
  },
  Opera: function() {
    return navigator.userAgent.match(/Opera Mini/i);
  },
  Windows: function() {
    return navigator.userAgent.match(/IEMobile/i);
  },
  any: function() {
    return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows());
  }
};

jQuery(document).ready(function() {
  if (!isMobile.any()) {
    $(window).stellar({
      horizontalScrolling: false,
      verticalScrolling: true,
      verticalOffset: 0,
      horizontalOffset: 0
    });
  }

  $('a.scrollto').click(function(e){
    $('html,body').scrollTo(this.hash, this.hash, {gap:{y:-70}});
    e.preventDefault();
  });
  
  $('.address-tooltip').hover(function() {
    $('.address-tooltip').tooltip();
  })
});