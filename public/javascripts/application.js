$(function() {
  

  //image_tag('/images/ajax-loader.gif', :class => 'ajax-start');
  $(document).ajaxStart(function() {
    $("span.ajax-loading").html('<img src="/images/ajax-loader.gif" class="ajax-start">');
  });
  
  $(document).ajaxStop(function() {
    $("span.ajax-loading").html('');
  });
  
  
  /* for dobs since they must be 18 */
  $("input.dob_picker").datepicker({
    autoSize: true,
    gotoCurrent: true,
    changeMonth: true,
    changeYear: true,
    dateFormat: 'yy-mm-dd',
    maxDate: "-18Y -1D",
  });

  /* regular date picker */
  $("input.date_picker").datepicker({
    autoSize: true,
    gotoCurrent: true,
    changeMonth: true,
    changeYear: true,
    dateFormat: 'yy-mm-dd',
  });
  
  
  $(".functions a").live("click", function() {
    $(this).parent().html("working...");
  });
  
  $("#completed .paggination.right a").live("click", function(e) {
    e.preventDefault();
    var url = $(this).attr("href");
    $("#completed").load(url);
  });
  
  $("#archived .paggination.right a").live("click", function(e) {
    e.preventDefault();
    var url = $(this).attr("href");
    $("#archived").load(url);
  });
  
  $('form#search_completed').live("submit", function(e) { 
    var form = $(this);
    var input = form.find(":input:first");
    input[0].select();
    e.preventDefault();
    $("#completed").load('/completed/search?q=' + input.val());
  });
  
  $('form#search_archived').live("submit", function(e) { 
    var form = $(this);
    var input = form.find(":input:first");
    input[0].select();
    e.preventDefault();
    $("#archived").load('/archived/search?q=' + input.val());
  });
  
});