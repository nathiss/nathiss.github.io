// init
var windowWidth = $(window).width();
var menuWidth = $('.menu-wrapper').outerWidth();


$('.main-wrapper').css({
    'left': menuWidth,
    'width': windowWidth - menuWidth
});

