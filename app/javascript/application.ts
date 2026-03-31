// @ts-nocheck
import "@hotwired/turbo-rails";
import "@rails/activestorage";
import * as bootstrap from "bootstrap";

window.bootstrap = bootstrap;
import "mousetrap";
import _ from "underscore";
import Backbone from "backbone";
import "backbone.nativeview";

import "./controllers/index";

Turbo.session.drive = false;

/* global Mousetrap */

Backbone.ajax = async function(options) {
  try {
    const response = await fetch(options.url, {
      body: options.data,
      headers: {"Content-Type": "application/json", ...options.headers},
      method: options.type || "GET",
    });
    const data = await response.json();
    if (response.ok && options.success) {
      options.success(data, response.statusText, response);
    } else if (!response.ok && options.error) {
      options.error(response, response.statusText, null);
    }
  } catch (err: unknown) {
    if (options.error) options.error(null, "error", err);
  }
};

_.templateSettings = {
  evaluate: /\{\{(.+?)\}\}/g,
  interpolate: /\{\{=(.+?)\}\}/g
};

function CSRFToken() {
  const tokenTag = document.getElementsByName('csrf-token')[0];

  return (tokenTag && tokenTag.content) || '';
}

function requestHeaders() {
  return { 'X-CSRF-Token': CSRFToken() };
}

var Story = Backbone.Model.extend({
  close: function() {
    this.set("open", false);
  },

  defaults: function() {
    return {
      "open" : false,
      "selected" : false
    }
  },

  open: function() {
    if (!this.get("keep_unread")) this.set("is_read", true);
    if (this.shouldSave()) this.save(null, { headers: requestHeaders() });

    if(this.collection){
      this.collection.closeOthers(this);
      this.collection.unselectAll();
      this.collection.setSelection(this);
    }

    this.set("open", true);
    this.set("selected", true);
  },

  openInTab: function() {
    window.open(this.get("permalink"), '_blank');
  },

  select: function() {
    if(this.collection) this.collection.unselectAll();
    this.set("selected", true);
  },

  shouldSave: function() {
    return this.changedAttributes() && this.get("id") > 0;
  },

  toggle: function() {
    if (this.get("open")) {
      this.close();
    } else {
      this.open();
    }
  },

  toggleKeepUnread: function() {
    if (this.get("keep_unread")) {
      this.set("keep_unread", false);
      this.set("is_read", true);
    } else {
      this.set("keep_unread", true);
      this.set("is_read", false);
    }

    if (this.shouldSave()) this.save(null, { headers: requestHeaders() });
  },

  unselect: function() {
    this.set("selected", false);
  }
});

var StoryView = Backbone.NativeView.extend({
  className: "story",
  events: {
    "click .story-preview" : "storyClicked"
  },

  initialize: function() {
    this.template = _.template(document.querySelector(this.template).innerHTML);
    this.listenTo(this.model, 'add', this.render);
    this.listenTo(this.model, 'change:selected', this.itemSelected);
    this.listenTo(this.model, 'change:open', this.itemOpened);
    this.listenTo(this.model, 'change:is_read', this.itemRead);
    this.el.addEventListener('keep-unread-toggle:toggled', (e) => {
      var detail = e.detail;
      this.model.set({is_read: detail.isRead, keep_unread: detail.keepUnread}, {silent: true});
      this.model.trigger('change:is_read');
    });
  },

  itemOpened: function() {
    var storyLead = this.el.querySelector(".story-lead");
    if (this.model.get("open")) {
      this.el.classList.add("open");
      if (storyLead) storyLead.style.display = "none";
      this.el.scrollIntoView({ block: "start" });
    } else {
      this.el.classList.remove("open");
      if (storyLead) storyLead.style.display = "";
    }
  },

  itemRead: function() {
    this.el.classList.toggle("read", this.model.get("is_read"));
  },

  itemSelected: function() {
    this.el.classList.toggle("cursor", this.model.get("selected"));
    requestAnimationFrame(() => { this.el.scrollIntoView({ block: "nearest" }); });
  },

  render: function() {
    var jsonModel = this.model.toJSON();
    this.el.innerHTML = this.template(jsonModel);
    if (jsonModel.is_read) {
      this.el.classList.add('read');
    }
    if (jsonModel.keep_unread) {
      this.el.classList.add('keepUnread');
    }
    Object.assign(this.el.dataset, {
      controller: "star-toggle keep-unread-toggle",
      keepUnreadToggleIdValue: String(jsonModel.id),
      keepUnreadToggleIsReadValue: String(jsonModel.is_read),
      keepUnreadToggleKeepUnreadValue: String(jsonModel.keep_unread),
      starToggleIdValue: String(jsonModel.id),
      starToggleStarredValue: String(jsonModel.is_starred),
    });
    return this;
  },

  storyClicked: function(e) {
    if (e.metaKey || e.ctrlKey || e.which == 2) {
      var backgroundTab = window.open(this.model.get("permalink"));
      if (backgroundTab) backgroundTab.blur();
      window.focus();
      if (!this.model.get("keep_unread")) this.model.set("is_read", true);
      if (this.model.shouldSave()) this.model.save(null, { headers: requestHeaders() });
    } else {
      this.model.toggle();
      this.el.scrollIntoView({ block: "start" });
    }
  },

  tagName: "li",

  template: "#story-template",

});

var StoryList = Backbone.Collection.extend({
  closeOthers: function(modelToSkip) {
    this.each(function(model) {
      if (model.id != modelToSkip.id) {
        model.close();
      }
    });
  },
  initialize: function() {
    this.cursorPosition = -1;
  },

  max_position: function() {
    return this.length - 1;
  },

  model: Story,

  moveCursorDown: function() {
    if (this.cursorPosition < this.max_position()) {
      this.cursorPosition++;
    } else {
      this.cursorPosition = 0;
    }

    this.at(this.cursorPosition).select();
  },

  moveCursorUp: function() {
    if (this.cursorPosition > 0) {
      this.cursorPosition--;
    } else {
      this.cursorPosition = this.max_position();
    }

    this.at(this.cursorPosition).select();
  },

  openCurrentSelection: function() {
    this.at(this.cursorPosition).open();
  },

  selected: function() {
    return this.where({selected: true});
  },

  selectedStoryId: function() {
    var selectedStory = this.at(this.cursorPosition);
    return selectedStory ? selectedStory.id : -1;
  },

  setSelection: function(model) {
    this.cursorPosition = this.indexOf(model);
  },

  toggleCurrent: function() {
    if (this.cursorPosition < 0) this.cursorPosition = 0;
    this.at(this.cursorPosition).toggle();
  },

  toggleCurrentKeepUnread: function() {
    if (this.cursorPosition < 0) this.cursorPosition = 0;
    this.at(this.cursorPosition).toggleKeepUnread();
  },

  unreadCount: function() {
    return this.where({is_read: false}).length;
  },

  unselectAll: function() {
    _.invoke(this.selected(), "unselect");
  },

  url: "/stories",

  viewCurrentInTab: function() {
    if (this.cursorPosition < 0) this.cursorPosition = 0;
    this.at(this.cursorPosition).openInTab();
  }
});

var AppView = Backbone.NativeView.extend({
  addAll: function() {
    this.stories.each(this.addOne, this);
  },

  addOne: function(story) {
    var view = new StoryView({model: story});
    this.el.querySelector("#story-list").appendChild(view.render().el);
  },

  el: "#stories",

  initialize: function(collection) {
    this.stories = collection;

    this.listenTo(this.stories, 'add', this.addOne);
    this.listenTo(this.stories, 'reset', this.addAll);
    this.listenTo(this.stories, 'all', this.render);
  },

  loadData: function(data) {
    this.stories.reset(data);
  },

  moveCursorDown: function() {
    this.stories.moveCursorDown();
  },

  moveCursorUp: function() {
    this.stories.moveCursorUp();
  },

  openCurrentSelection: function() {
    this.stories.openCurrentSelection();
  },

  render: function() {
    var unreadCount = this.stories.unreadCount();

    if (unreadCount === 0) {
      document.title = window.i18n.titleName;
    } else {
      document.title = "(" + unreadCount + ") " + window.i18n.titleName;
    }
  },

  toggleCurrent: function() {
    this.stories.toggleCurrent();
  },

  toggleCurrentKeepUnread: function() {
    this.stories.toggleCurrentKeepUnread();
  },

  viewCurrentInTab: function() {
    this.stories.viewCurrentInTab();
  }
});

document.addEventListener("DOMContentLoaded", function() {
  Mousetrap.bind("?", function() {
    bootstrap.Modal.getOrCreateInstance(document.getElementById('shortcuts')).toggle();
  });
});

window.StoryList = StoryList;
window.AppView = AppView;

export { Story, StoryView, StoryList, AppView };
