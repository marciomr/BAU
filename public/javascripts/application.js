// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function remove_after_slide(element){
    new Effect.SlideUp(
        $(element), {
            duration:0.3,
            afterFinish: function () { 
                $(element).remove() 
            }
        }
    );
}

function mark_author_for_destroy(element){
    $(element).next('.should_destroy').value = 1;
    $(element).up('.author').fade();
}

function mark_tag_for_destroy(element){
    $(element).next('.should_destroy').value = 1;
    $(element).up('.tag').fade();
}
