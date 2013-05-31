"use strict";

describe("Storyiew", function(){
  it("should exist", function(){
    StoryView.should.exist;
  });

  describe("Rendering the view", function(){
    before(function() {
      this.story = new Story({
        source: "TechKrunch",
        headline: "Every startups acquired by Yahoo!",
        lead: "This is the lead.",
        title: "Every startups acquired by Yahoo! NOT!!",
        body: "All remote workers have been exiled to Ohio.",
        pretty_date: "Mon July 1, 2013",
        permalink: "http://example.com/krunch",
        keep_unread: false,
        is_read: false
      });

      this.view = new StoryView({model: this.story})

      this.view.render();
    });

    it("should render li.story items", function(){
      this.view.$el.hasClass("story").should.be.true;
    });

    var assertTagExists = function(el, tagName) {
      el.find(tagName).should.have.length(1);
    };

    var assertPropertyRendered = function(el, model, propName) {
      el.html().should.have.string(model.get(propName));
    };

    it("should render blog title", function(){
      assertTagExists(this.view.$el, ".blog-title");
      assertPropertyRendered(this.view.$el, this.story, "source");
    });

    it("should render story headline", function(){
      assertTagExists(this.view.$el, ".story-title");
      assertPropertyRendered(this.view.$el, this.story, "headline");
    });

    it("should render story lead", function(){
      assertTagExists(this.view.$el, ".story-lead");
      assertPropertyRendered(this.view.$el, this.story, "lead");
    });

    it("should render story full title", function(){
      assertTagExists(this.view.$el, ".story-body");
      assertPropertyRendered(this.view.$el, this.story, "title");
    });

    it("should render story full title as link", function(){
      assertTagExists(this.view.$el, ".story-body h1 a");
    });

    it("should render story full body", function(){
      assertTagExists(this.view.$el, ".story-body");
      assertPropertyRendered(this.view.$el, this.story, "body");
    });

    it("should render story date", function(){
      assertTagExists(this.view.$el, ".story-published");
      assertPropertyRendered(this.view.$el, this.story, "pretty_date");
    });

    it("should render story permalink", function(){
      assertTagExists(this.view.$el, ".story-permalink");
      assertPropertyRendered(this.view.$el, this.story, "permalink");
    });

    it("should render keep as unread button", function(){
      assertTagExists(this.view.$el, ".story-keep-unread");
    });

    it("should autofill unread button based on item", function(){
      assertTagExists(this.view.$el, ".story-keep-unread .icon-check-empty");

      this.story.set("keep_unread", true);
      this.view.render();

      assertTagExists(this.view.$el, ".story-keep-unread .icon-check");      
    });
  });
});