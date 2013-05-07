$(document).ready(function() {
  var OSName="Unknown OS";
  if (navigator.appVersion.indexOf("Win")!=-1) OSName="Windows";
  if (navigator.appVersion.indexOf("Mac")!=-1) OSName="MacOS";
  if (navigator.appVersion.indexOf("X11")!=-1) OSName="UNIX";
  if (navigator.appVersion.indexOf("Linux")!=-1) OSName="Linux";

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
    window.scrollTo(0,$(this).offset().top);
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
      $.post("/delete_feed", { feed_id: feedId })
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
      cursorPosition++;
    }

    Stringer.setCursorPosition(cursorPosition);
    Stringer.currentlySelectedStory().trigger("toggleStory");
  });

  Mousetrap.bind("k", function() {
    if (cursorPosition > 0) {
      cursorPosition--;
    } else {
      cursorPosition = 0;
    }

    Stringer.setCursorPosition(cursorPosition);
    Stringer.currentlySelectedStory().trigger("toggleStory");
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
    if (permalink) {
        permalink.target='_blank';
        var evt = document.createEvent("MouseEvents");
        if (OSName == 'MacOS')
        {
            //the tenth parameter of initMouseEvent sets ctrl key
            evt.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0,
                                    false, false, false, true, 0, null);            
        } else {
            //the tenth parameter of initMouseEvent sets ctrl key
            evt.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0,
                                    true, false, false, false, 0, null);
        }
        permalink.dispatchEvent(evt);
        window.focus();
    }
  });
});