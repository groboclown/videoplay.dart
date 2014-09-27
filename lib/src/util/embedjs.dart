// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

library videoplay.src.util.embedjs;

import 'dart:async';
import 'dart:html';
import 'dart:js';


/**
 * Embeds a JavaScript source file into the current document.  This does
 * not wait for the script to load and be parsed.
 *
 * @param url the URI pointing to the source file.
 */
void embedJsScript(String uri) {
    // First, check if the script is already loaded.  We don't want to load
    // it twice.
    if (isJsScriptLoaded(uri)) {
        return;
    }

    var script = new ScriptElement();
    script.type = "text/javascript";
    script.src = uri;
    document.body.append(script);
}


/**
 * @return `true` if the script with the exact URI is already loaded, otherwise
 *      `false`.
 */
bool isJsScriptLoaded(String uri) {
    for (Element el in document.getElementsByTagName("script")) {
        if (el.getAttribute('src') == uri) {
            return true;
        }
    }
    return false;
}


/**
 * Exception thrown when an expected JavaScript object wasn't loaded, or wasn't
 * a JavaScript object ([JsObject]).
 */
class NoSuchJsObjectFound implements Exception {
    final String uri;
    final String jsObjectName;

    NoSuchJsObjectFound(this.uri, this.jsObjectName);

    @override
    String toString() =>
        "No JsObject named [${jsObjectName}] found in the global namespace (${uri})";
}


/**
 * Embeds the JavaScript source file from the URI into the current document,
 * and returns a [Future] that completes when the given JavaScript object
 * has been loaded.
 *
 * Note that the detection to see if the script was loaded is entirely based
 * around the existence of that `jsObjectName`.  If for some reason the loaded
 * script must swap out an existing object with the same name, then this
 * may incorrectly return the wrong object.
 */
Future<JsObject> embedJsScriptObject(String uri, String jsObjectName,
        { Duration checkInterval: null, int maxCheckIterations: 30 }) {
    // If the object
    if (context.hasProperty(jsObjectName) &&
                    context[jsObjectName] != null) {
        if (context[jsObjectName] is JsObject) {
            return new Future<JsObject>.value(context[jsObjectName]);
        }
    }

    if (checkInterval == null) {
        checkInterval = new Duration(milliseconds: 50);
    }

    embedJsScript(uri);
    Completer<JsObject> ret = new Completer<JsObject>();

    int checkedCount = 0;

    new Timer.periodic(checkInterval, (Timer t) {
        if (context.hasProperty(jsObjectName) &&
                context[jsObjectName] != null) {
            t.cancel();
            if (context[jsObjectName] is JsObject) {
                ret.complete(context[jsObjectName]);
            } else {
                ret.completeError(new NoSuchJsObjectFound(uri, jsObjectName));
            }
            return;
        }
        if (++checkedCount > maxCheckIterations) {
            t.cancel();
            ret.completeError(new NoSuchJsObjectFound(uri, jsObjectName));
        }
    });

    return ret.future;
}


