_.templateSettings = {
  interpolate: /\{\{\=(.+?)\}\}/g,
  evaluate: /\{\{(.+?)\}\}/g
};

$(document).ready(function() {
  $(".remove-feed").click(function(e) {
    e.preventDefault();
    var $this = $(this);

    var feedId = $this.parents("li").data("id");

    if (feedId > 0) {
      $.ajax({url: "/feeds/" + feedId, type: "DELETE"})
       .success(function() {
          $this.parents("li").fadeOut(500, function () {
            $(this).remove();
          });
        })
       .fail(function() { alert("something broke!"); });
    }
  });

  Mousetrap.bind("?", function() {
    $("#shortcuts").modal('toggle');
  });
});