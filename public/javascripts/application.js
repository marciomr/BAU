// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function () {
    $.get("books/adv_search", function(data){
        adv_search_data = data;
    });
    
    adv_search_show();
    
    $('#isbn').focusout(function(){
        $('#book_isbn').val($(this).val());
    });
    
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
    $('#adv_search_show').click(function () {
        $('#advanced_search').append(adv_search_data).hide().slideDown();
        adv_search_hide();

        $('#adv_search_show').hide();
        return false;           
    }); 
}  

function adv_search_hide(){
    $('#adv_search_hide').click(function () {
        $('#adv_search_content').slideUp().delay().queue(function() {
            $(this).remove();
        });
        $('#adv_search_show').show();        
        return false;           
    });
}
