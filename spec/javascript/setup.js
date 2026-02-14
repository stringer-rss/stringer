import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";

import "jquery";
import underscore from "underscore";
import Backbone from "backbone";

const jquery = window.jQuery;
globalThis.$ = jquery;
globalThis.jQuery = jquery;
globalThis._ = underscore;
globalThis.Backbone = Backbone;

Backbone.$ = jquery;

_.templateSettings = {
  interpolate: /\{\{=(.+?)\}\}/g,
  evaluate: /\{\{(.+?)\}\}/g,
};

globalThis.CSRFToken = function () {
  return "";
};

globalThis.requestHeaders = function () {
  return { "X-CSRF-Token": CSRFToken() };
};

// Inject the story template into the DOM.
// This is a static test fixture extracted from _templates.html.erb,
// with the ERB t() call replaced by a plain string.
const templateHTML = [
  '<script type="text/template" id="story-template">',
  '  <div class="row story-preview">',
  '    <div class="col-md-3">',
  '      <div class="story-starred">',
  '        <i class="fa {{ if(is_starred) { }}fa-star{{ } else { }}fa-star-o{{ } }}"></i>',
  "      </div>",
  '      <p class="blog-title">',
  "        {{= source }}",
  "      </p>",
  "    </div>",
  '    <div class="col-md-9">',
  '      <p class="story-details">',
  '        <span class="story-title">',
  "          {{= headline }}",
  "        </span>",
  '        <span class="story-lead">',
  "          &mdash; {{= lead }}",
  "        </span>",
  "      </p>",
  "    </div>",
  "  </div>",
  "",
  '  <div class="story-body-container">',
  '    <div class="story-body">',
  "      <h1>",
  '        <a href="{{= permalink }}">{{= title }}</a>',
  "        {{ if (enclosure_url) { }}",
  '          <a class="story-enclosure" target="_blank" href="{{= enclosure_url }}">',
  '            <i class="fa fa-download"></i>',
  "          </a>",
  "        {{ } }}",
  "      </h1>",
  "      {{= body }}",
  "    </div>",
  '    <div class="row story-actions-container">',
  '      <div class="pull-left">',
  '        <span class="story-published">',
  "          {{= pretty_date }}",
  "        </span>",
  "      </div>",
  '      <div class="pull-right story-actions">',
  '        <div class="story-keep-unread">',
  '          <i class="fa {{ if(keep_unread) { }}fa-check{{ } else { }}fa-square-o{{ } }}"></i> Keep unread',
  "        </div>",
  '        <div class="story-starred">',
  '          <i class="fa {{ if(is_starred) { }}fa-star{{ } else { }}fa-star-o{{ } }}"></i>',
  "        </div>",
  '        <a class="story-permalink" target="_blank" href="{{= permalink }}">',
  '          <i class="fa fa-external-link"></i>',
  "        </a>",
  "      </div>",
  "    </div>",
  "  </div>",
  "</script>",
].join("\n");

document.body.insertAdjacentHTML("beforeend", templateHTML);

// Load application.js class definitions into the global scope
const appJsPath = path.resolve(__dirname, "../../app/assets/javascripts/application.js");
const appJs = fs.readFileSync(appJsPath, "utf-8");

// Strip the sprockets require directives and the $(document).ready block
const strippedJs = appJs
  .replace(/^\/\/= require .+$/gm, "")
  .replace(/_.templateSettings\s*=\s*\{[^}]+\};/, "")
  .replace(/\$\(document\)\.ready\(function\(\)\s*\{[\s\S]*\}\);?\s*$/, "");

vm.runInThisContext(strippedJs, { filename: "application.js" });
