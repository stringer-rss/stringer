$(document).ready(function() {
  var previous_req_id = 0;
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

    var storyId = $this.data("id");

    if (storyId > 0) {
        $.post("/mark_as_read", { story_id: storyId })
        .done(function() {
            if(previous_req_id != storyId ){
                var title = $("head > title")[0];
                var stories_count = parseInt(title.text.match(/\d+/));
                if (stories_count > 1){
                    title.text = title.text.replace(/\d+/,stories_count - 1);
                }else{
                    title.text = title.text.replace("(1)","")
                }
                previous_req_id = storyId;
            }
        })
        .fail(function() { alert("something broke!"); });
    }
  });

  $("li.story").on("toggleStory", function(e) {
    e.preventDefault();
    var $this = $(this);

    var openStories = $("li.story.open");

    if($this.hasClass("open")) {
      $this.trigger("closeStory");
    } else {
      $this.trigger("openStory");
    }

    openStories.trigger("closeStory");
    
    window.scrollTo(0, $this.offset().top);
  });

  $("#mark-all").click(function(e) {
    e.preventDefault();

    $("form#mark-all-as-read").submit();
  });

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

  var cursorPosition = -1;
  var MAX_POSITION = $("li.story").size();

  var Stringer = {
    setCursorPosition: function(position) {
      if (position < 0) position = 0;

      var stories = $("li.story");
      stories.removeClass("cursor");
      stories.eq(position).addClass("cursor");
    },

    currentlySelectedStory: function() {
      position = cursorPosition;
      if (position < 0) position = 0;

      return $("li.story").eq(position);
    }
  };

  Mousetrap.bind("j", function() {
    if (cursorPosition < MAX_POSITION - 1) {
      Stringer.setCursorPosition(++cursorPosition)
      Stringer.currentlySelectedStory().trigger("toggleStory");
    }
  });

  Mousetrap.bind("k", function() {
    if (cursorPosition > 0) {
      Stringer.setCursorPosition(--cursorPosition);
      Stringer.currentlySelectedStory().trigger("toggleStory");
    } else {
      cursorPosition = 0;
      
      Stringer.setCursorPosition(cursorPosition);
      Stringer.currentlySelectedStory().trigger("openStory");
    }
  });

  Mousetrap.bind(["o", "enter"], function() {
    Stringer.currentlySelectedStory().trigger("toggleStory");
    Stringer.setCursorPosition(cursorPosition);
  });

  Mousetrap.bind("r", function() {
    var refresh = $("a#refresh")[0];
    if (refresh) refresh.click();
  });

  Mousetrap.bind("shift+a", function() {
    $("form#mark-all-as-read").submit();
  });

  Mousetrap.bind(["b","v"], function() {
    var currentStory = Stringer.currentlySelectedStory();
    var permalink = currentStory.find("a.story-permalink")[0];

    if (permalink) window.open(permalink.href, '_blank');
  });
});
