// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function () {  
    adv_search = $('#advanced_search').html();
    $('#advanced_search').remove();
    $('#adv_search_hide').hide();
    $('#adv_search_show').show();
    
    $('.remove_button').val("x");
    $('.index_edit').wrapInner('<table>');
    $('.edit_link').wrap('<td>');
    $('.index_edit form').wrap('<td>');
});  

function remove_fields(link) {  
    $(link).prev("input[type=hidden]").val("1");  
    $(link).closest(".fields").hide();  
}  
  
function add_fields(link, association, content) {  
    var new_id = new Date().getTime();  
    var regexp = new RegExp("new_" + association, "g");  
    $(link).parent().before(content.replace(regexp, new_id));  
}

function adv_search_show(){
    $('#search_form').append('<div id="advanced_search">'+adv_search+'</div>');
    $('#advanced_search').hide();
    $('#adv_search_show').hide();
    $('#adv_search_hide').show();
    $('#advanced_search').slideDown();
}  

function adv_search_hide(){
    $('#adv_search_hide').hide();
    $('#adv_search_show').show(); 
    $('#advanced_search').slideUp().delay().queue(function() {
        $(this).remove();
    });
}
