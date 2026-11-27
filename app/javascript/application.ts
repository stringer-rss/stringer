import { session } from "@hotwired/turbo";
import "@hotwired/turbo-rails";
import "@rails/activestorage";
import "bootstrap";

import "./controllers/index";

session.drive = false;
