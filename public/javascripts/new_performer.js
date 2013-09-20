$(function() {
  
  $("span.hint").each(function() {
    field = $(this).prev();
    $(field).attr('placeholder', $(this).html());
    $(this).hide();
  });

  $("input").focus(function() {
    if(!$(this).hasClass('date_picker')) {
      $(this).val('');
    }
  
  });

  
  /* live search functionality for first name and last name */
  $("input.searchable").keyup(function() {
    var first_name_field = $("input#user_first_name");
    var last_name_field = $("input#user_last_name");
    get_cadre_data(first_name_field, last_name_field);
    
  });
  
  $("a#cadre-check").click(function(e) {
    e.preventDefault();
    var first_name_field = $("input#user_first_name");
    var last_name_field = $("input#user_last_name");
    get_cadre_data(first_name_field, last_name_field);
  })
  
  $("span.cadre_link").hide();
  
  function get_cadre_data(first_name_field, last_name_field) {
    vars = {}
    if ($(first_name_field).val() != '' && !$(first_name_field).hasClass('greyText')) {
      vars['first_name'] = $(first_name_field).val();
    }
    if ($(last_name_field).val() != '' && !$(last_name_field).hasClass('greyText')) {
      vars['last_name'] = $(last_name_field).val();
    }
  
    $.post('/performer/lookup', vars, function(data) {
      if($("#results").is(':hidden')) {
        $("#results").show();
      }
      $("#results").html(data);
    });
  }
  
})
