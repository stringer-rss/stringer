"use strict";

describe("Story", function(){
  it("should exist", function(){
    Story.should.exist;
  });

  it("uses defaults", function(){
    var story = new Story();
    story.get('open').should.be.false;
    story.get('selected').should.be.false;
  });

  describe("open", function(){
    it("sets open and selected to true", function(){
      var story = new Story();
      story.open();
      story.get("open").should.be.true;
      story.get("selected").should.be.true;
    });

    it("sets is_read to true if keep_unread isn't true", function(){
      var story = new Story();
      (!! story.get("keep_unread")).should.be.false;
      story.open();
      story.get("is_read").should.be.true;
    });

    it("doesn't sets is_read to true if keep_unread is true", function(){
      var story = new Story();
      story.set("keep_unread", true);
      story.open();
      (!! story.get("is_read")).should.be.false;
    });

    it("calls closeOthers, unselectAll, setSelection on collection", function(){
      var story = new Story(),
          spy = story.collection = {
            closeOthers:  sinon.spy(),
            unselectAll:  sinon.spy(),
            setSelection: sinon.spy()
          };
      story.open();
      spy.closeOthers.should.have.been.calledWith(story);
      spy.unselectAll.should.have.been.calledOnce;
      spy.setSelection.should.have.been.calledWith(story);
    });

    it("calls save if it should save", function(){
      var story = new Story();

      sinon.stub(story, "save");
      sinon.stub(story, "shouldSave", function(){
        return true;
      });

      story.open();
      story.shouldSave.should.have.been.calledOnce;
      story.save.should.have.been.calledOnce;
    })
  });

  describe("close", function(){
    it("sets open to false", function(){
      var story = new Story();
      story.set("open", true);
      story.get("open").should.be.true;
      story.close();
      story.get("open").should.be.false;
    });
  });

  describe("select", function(){
    it("sets selected to true", function(){
      var story = new Story();
      story.select();
      story.get("selected").should.be.true;
    });

    it("calls unselectAll on collection", function(){
      var story = new Story(),
          spy = story.collection = {
            unselectAll: sinon.spy()
          };
      story.select();
      spy.unselectAll.should.have.been.calledOnce;
    });
  });

  describe("toggle", function(){
    it("calles open/close based on state", function(){
      var story = new Story();
      sinon.stub(story, "open");
      sinon.stub(story, "close");

      story.toggle();
      story.open.should.have.been.calledOnce;
      story.close.should.not.have.been.called;

      story.set("open", true);
      story.toggle();
      story.open.should.have.been.calledOnce;
      story.close.should.have.been.calledOnce;
    });
  });

  describe("shouldSave", function(){
    it("returns false in there are no changed Attributes", function(){
      var story = new Story();
      sinon.stub(story, "changedAttributes", function(){
        return false;
      });
      story.shouldSave().should.be.false;
      story.changedAttributes.should.have.been.calledOnce;
    });

    it("returns false if it has changedAttributes but no id", function(){
      var story = new Story();
      sinon.stub(story, "changedAttributes", function(){
        return {is_read: true};
      });
      story.shouldSave().should.be.false;
      story.changedAttributes.should.have.been.calledOnce;
    });

    it("returns true if it has changedAttributes and an id", function(){
      var story = new Story({id: 1});
      sinon.stub(story, "changedAttributes", function(){
        return {is_read: true};
      });
      story.shouldSave().should.be.true;
      story.changedAttributes.should.have.been.calledOnce;
    });
  });

  describe("openInTab", function(){
    it("opens a new window", function(){
      var story = new Story({permalink: "http://localhost"});
      sinon.stub(window, "open");

      story.openInTab();
      window.open.should.have.been.calledWith("http://localhost", "_blank");
      window.open.restore();
    });
  });
});
