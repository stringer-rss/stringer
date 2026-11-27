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
  escape: /\{\{-(.+?)\}\}/g,
  evaluate: /\{\{(.+?)\}\}/g,
  interpolate: /\{\{=(.+?)\}\}/g
};

var Story = Backbone.Model.extend({});

var StoryView = Backbone.NativeView.extend({
  className: "story",

  initialize: function() {
    this.template = _.template(document.querySelector(this.template).innerHTML);
    this.listenTo(this.model, 'add', this.render);
    this.el.addEventListener('story-refresh:refreshed', (e) => {
      this.model.set(e.detail.story, {silent: true});
      this.render();
    });
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
      action: "keep-unread-toggle:toggled->story#keepUnreadToggled",
      controller: "story star-toggle keep-unread-toggle story-refresh",
      keepUnreadToggleIdValue: String(jsonModel.id),
      keepUnreadToggleIsReadValue: String(jsonModel.is_read),
      keepUnreadToggleKeepUnreadValue: String(jsonModel.keep_unread),
      starToggleIdValue: String(jsonModel.id),
      starToggleStarredValue: String(jsonModel.is_starred),
      storyIdValue: String(jsonModel.id),
      storyIsReadValue: String(jsonModel.is_read),
      storyKeepUnreadValue: String(jsonModel.keep_unread),
      storyListTarget: "story",
      storyPermalinkValue: String(jsonModel.permalink),
      storyRefreshIdValue: String(jsonModel.id),
      unreadCountTarget: "story",
    });
    return this;
  },

  tagName: "li",

  template: "#story-template",

});

var StoryList = Backbone.Collection.extend({
  model: Story,

  url: "/stories"
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
  },

  loadData: function(data) {
    this.stories.reset(data);
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
