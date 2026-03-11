/*
 * In module contexts, jQuery 2.x skips global registration (noGlobal=true
 * when module.exports is present). This shim imports jQuery and exposes it
 * as a global so Bootstrap and other scripts can find `typeof jQuery`.
 */
// @ts-expect-error -- No type declarations bundled; see @types/jquery
import jQuery from "../../../node_modules/jquery/dist/jquery.js";

Object.assign(globalThis, {$: jQuery, jQuery});

export default jQuery;
