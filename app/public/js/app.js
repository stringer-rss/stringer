$(document).ready(function() {
  $(".story-preview").click(function(e){ 
    e.preventDefault();

    var $this = $(this);

    var openStories = $("li.story.open");
    
    if(!$this.hasClass("open")) {
      $this.trigger("openStory");
    }

    openStories.trigger("closeStory");
  });

  $("li.story").on("closeStory", function(e) {
    e.preventDefault();
    var $this = $(this);

    if($this.hasClass("open")) {
      $this.removeClass("open");
      $this.addClass("read");

      $(".story-lead", this).show();
      $(".story-body-container", this).stop().hide();
    }
  });

  $("li.story").on("openStory", function(e) {
    e.preventDefault();
    var $this = $(this);

    $this.addClass("open");

    $(".story-lead", this).fadeOut(1000);
    $(".story-body-container", this).stop().show();

    var story_id = $this.data("id");

    if (story_id > 0) {
      $.post("/mark_as_read", { story_id: story_id })
       .fail(function() { alert("something broke!"); });
    }
  });

  $("li.story").on("toggleStory", function(e) {
    e.preventDefault();
    var $this = $(this);

    if($this.hasClass("open")) {
      $this.trigger("closeStory");
    } else {
      $this.trigger("openStory");
    }
  });

  $("#mark-all").click(function(e) {
    e.preventDefault();

    $("form#mark-all-as-read").submit();
  });

  $(".remove-feed").click(function(e) {
    e.preventDefault();
    var $this = $(this);

    var feed_id = $this.parents("li").data("id");

    if (feed_id > 0) {
      $.post("/delete_feed", { feed_id: feed_id })
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

  var cursor_position = -1;
  var MAX_POSITION = $("li.story").size();

  Mousetrap.bind("k", function() {
    if (cursor_position < MAX_POSITION - 1) {
      cursor_position++;
      
      $("li.story").removeClass("cursor");
      $("li.story").eq(cursor_position).addClass("cursor");
    }
  });

  Mousetrap.bind("j", function() {
    $("li.story").removeClass("cursor");

    if (cursor_position > 0) {
      cursor_position--;
      $("li.story").eq(cursor_position).addClass("cursor");
    } else {
      $("li.story").eq(0).addClass("cursor");
    }
  });

  Mousetrap.bind(["o", "enter"], function() {
    $("li.story").eq(cursor_position).trigger("toggleStory");
  });

  Mousetrap.bind("r", function() {
    var refresh = $("a#refresh")[0];
    if (refresh) refresh.click();
  });

  Mousetrap.bind("shift+a", function() {
    $("form#mark-all-as-read").submit();
  });

  Mousetrap.bind("v", function() {
    var permalink = $("li.story.open a#story-permalink")[0];
    if (permalink) permalink.click();
  });
});