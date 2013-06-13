function updateWeather() {
    $.get('/service/weather.json', null, function (data) {
        if (data.success == 1) {	        
            set_weather_info(data.weather, data.forecasts);
        } else {
	        $('#weather').remove();
        }
        $('#city').html(data.city);
    }, 'json');
}
function set_weather_info(weather, forecasts) {
    $('#weather a span#weather-wrapper').html('<span class="wc">' + weather + '</span><span class="gbma"></span>');
    $('#weather #wm').html(forecasts);
}
function updateUrls(id) {
	$.get('/urls/' + id + ".json", null, function (data) {
		$("a.link1").each(function () {
			var dd = $(this).attr('dd');
	        var url_id = dd.split('-')[0];
	        $(this).attr('href', data[url_id]);
	    });
    }, 'json');
}

var search_words = null, suggest_count = 0;

function show_suggest() {
    $('#suggestions').css('display', 'block');
}

function suggest_visible() {
    return 'block' == $('#suggestions').css('display');
}

function update_suggestions(suggest) {
    var h = '', count = 0;
    $.each(suggest, function (index, value) {
        h = h + '<div id="gs' + count + '">' + value + '</div>';
        count = count + 1;
    });
    $('#suggestions').html(h);
    suggest_count = count
}

function suggest_scroll(e) {
    if (e.which == 38 || e.which == 40) {
        var s1 = null, s2 = null, pre = null, next = null;
        if (suggest_count == 0) return;
        if (e.which == 38) {
            if (!suggest_visible()) {
            	show_suggest();
            } else {
	            s1 = $('#suggestions div.select');
	            pre = null;
	            if (s1 != null && s1.length > 0) {
	                if (s1.attr('id') == $('#suggestions div').first().attr('id')) {
	                    pre = $('#suggestions div').last()
	                } else {
	                    pre = s1.prev();
	                }
	                s1.removeClass('select');
	                pre.addClass('select');                
	            } else {
	            	next = $('#suggestions div').last();
	                next.addClass('select');
	            }
	            $('#g_search').val(pre.html());
            }
        } else {
            if (!suggest_visible()) {
                show_suggest();
            } else {
                s2 = $('#suggestions div.select');
                if (s2 != null && s2.length > 0) {
                    if (s2.attr('id') == $('#suggestions div').last().attr('id')) {
                        next = $('#suggestions div').first()
                    } else {
                        next = s2.next();
                    }
                    s2.removeClass('select');
                    next.addClass('select');
                } else {
                    next = $('#suggestions div').first();
                    next.addClass('select');
                }
                $('#g_search').val(next.html());
            }
        }
    }
}

function query_suggest(e) {
    if (e.which == 38 || e.which == 40 || e.which == 37 || e.which == 39) return;
    var q = jQuery.trim($(this).val());
    if (q == '' || q == search_words) return;
    search_words = q;
    $.get('/util/suggest/' + search_words + '.json', null, function (suggest) {
        if (suggest != null && suggest.length > 0) {
            update_suggestions(suggest);
            show_suggest();
        }
    }, 'json');
}

function cookie_click(link_id) {
	var key = 'l' + link_id, count = $.cookie(key);
    if (count) count = parseInt(count) + 1;
    else count = 1;
    $.cookie(key, count);
    if (count > 0) $('a.' + key).addClass('anchored');
}

$(function () {
	$("#weather a, #wm").hover(
		function () {
		    $('#weather a').addClass("click");
		    $("#weather #wm").width($('#weather').width() - 42);
		    $("#weather #wm").show();
		},
		function () {
		    $('#weather a').removeClass("click");
		    $("#weather #wm").hide();
		}
	);

	$("#city-link, #city-menu").hover(
		function () {
			$("#city-menu").css("display", "block");
			$("#city-link").addClass("clicked")
		},
		function () {
			$("#city-menu").css("display", "none");
			$("#city-link").removeClass("clicked");
		}
	);
	
    $("#add-favourites").jBrowserBookmark({
        language: {
            'en': ['Please press [key] + ', ' to bookmark this page.']
        }
    });

    $("#add-favourites").click(function () {
        $.get('/util/favorite');
    });
    
    $("#sethomepage").click(function (e) {    	
    	try {
    		if ($.browser.msie) {
    			$.get('/util/sethomepage');
    			this.style.behavior='url(#default#homepage)';
    			this.setHomePage('http://' + $(this).attr('rel'));
    			e.preventDefault();
    			return false;
    		}
    	} catch(ex) {
    	}
    	return true;
    });

    $("#g_search").keyup(suggest_scroll).keyup($.debounce(250, query_suggest));
    document.onclick = function() {$("#suggestions").css("display", "none")};

    $("#suggestions div").live('click', function () {
        $('#g_search').val($(this).html());        
        $("#searchForm").submit();        
    }).live('mouseenter', function () {
        $('#suggestions div').removeClass('select');
        $(this).addClass('select');
    });

    $("#searchForm").submit(function () {
        if ($("#r4").attr("checked")) {
            $("#searchForm").attr("action", "http://maps.google.com.au/maps");
        } else {
            $("#searchForm").attr("action", "http://www.google.com.au/search");
        }
        $("#suggestions").css("display","none");
        return true;
    });

    $("a.link1, a.link2").click(function (e) {
        var dd = $(this).attr('dd');
        cookie_click(dd.split('-')[0]);
        window.open('/url/' + dd);
        e.preventDefault();
        return false;
    });

    $("a.link1, a.link2").each(function () {
        var key = 'l' + $(this).attr('dd').split('-')[0], count = $.cookie(key);
        if (parseInt(count) > 0) $(this).addClass('anchored');
    });
    
  $('.cate2 ul.img-link li a.img-link').hover(
		function () {
			$(this).next().show();
		},
		function () {
			$(this).next().hide();
		}
	);
	$('.tip-holder').hover(
		function () {
			$(this).show();
			$(this).prev().addClass('hover');
		},
		function () {
			$(this).hide();
			$(this).prev().removeClass('hover');
		}
	);
	
	updateWeather();
	setInterval(updateWeather, 60000 * 10);
});