// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

library videoplay.src.util.swfobject;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'embedjs.dart';

const String DEFAULT_SWFOBJECT_LOCATION = "packages/videoplay/js/swfobject.js";
const String DEFAULT_SWFOBJECT_NAME = "swfobject";


class SwfObjectException implements Exception {
    final String message;

    SwfObjectException(this.message);
}


Future<SwfObjectFactory> createSwfObjectFactory({
        String swfScriptUri: null, String swfObjName: null }) {
    if (swfScriptUri == null) {
        swfScriptUri = DEFAULT_SWFOBJECT_LOCATION;
    }
    if (swfObjName == null) {
        swfObjName = DEFAULT_SWFOBJECT_NAME;
    }

    return embedJsScriptObject(swfScriptUri, swfObjName)
        .then((JsObject obj) {
            return new SwfObjectFactory(obj);
        });
}


/**
 * Allows for building up the variables for creating the SWF object, then
 * create the object.
 */
class SwfObjectFactory {
    static int objectIndex = 0;

    /** locally unique identifier for this swf object */
    final String contextPrefix;
    final JsObject _swfEmbedder;
    final List<String> _contextObjects = [];
    ObjectElement _swfElement;
    JsObject _swfJs;
    Iterable<String> get contextObjectNames => _contextObjects;

    int _state = 0;

    String swfUrl;
    Element wrapperElement;
    int width;
    int height;
    String swfVersion = "8";
    String xiSwfUrl;
    Map<String, String> flashvars = {};
    Map<String, String> params = {};
    Map<String, String> attribs = {};

    factory SwfObjectFactory(JsObject jsSwfObject) {
        String id = "__SWF" + (objectIndex++).toString() + "_";
        return new SwfObjectFactory._(jsSwfObject, id);
    }

    SwfObjectFactory._(this._swfEmbedder, this.contextPrefix);

    String createGlobalContextName(String suffix) {
        return contextPrefix + suffix;
    }

    void addGlobalCallback(String globalContextName, Function callback) {
        _contextObjects.add(globalContextName);
        context[globalContextName] = callback;
    }

    Swf embedSwf({ String swfObjectId }) {
        if (_state != 0) {
            throw new SwfObjectException("already embedded swf object");
        }
        if (wrapperElement == null) {
            throw new SwfObjectException("wrapper element not set");
        }
        _state = 1;

        DivElement replaced = new DivElement();
        wrapperElement.children.add(replaced);

        bool success = false;
        ObjectElement ref = null;

        _swfEmbedder.callMethod('embedSWF', [
                swfUrl, replaced,
                width.toString(), height.toString(), "8",
                xiSwfUrl,
                new JsObject.jsify(flashvars),
                new JsObject.jsify(params),
                new JsObject.jsify(attribs),
                (JsObject results) {
                    if (results.hasProperty('success')) {
                        success = results['success'];
                    }
                    if (results.hasProperty('ref')) {
                        ref = results['ref'];
                    }
                }
            ]);

        if (! success) {
            throw new SwfObjectException("could not create the flash player");
        }

        if (ref == null) {
            // Find the embedded object.  Because we may be in a shadow DOM,
            // we need to just ask the parent wrapping object.
            for (Element el in wrapperElement.children) {
                if (el is ObjectElement &&
                        (swfObjectId == null ||
                        (el.attributes.containsKey('id') &&
                        el.getAttribute('id') == swfObjectId))) {
                    ref = el;
                }
            }
        }

        if (ref == null) {
            throw new SwfObjectException("could not create the flash player");
        }

        return new Swf(this, ref);
    }
}


class SwfEvent {
    final Swf swf;
    final String eventName;
    final DateTime when = new DateTime.now();
    final dynamic arg;
    final dynamic eventValue;

    SwfEvent(this.swf, this.eventName, this.arg, this.eventValue);
}


class Swf {
    static int objectIndex = 0;

    final String objectId;
    final List<String> _contextObjects;
    ObjectElement _swfElement;
    JsObject _js;
    final Element wrapperElement;
    final StreamController<SwfEvent> _events =
            new StreamController<SwfEvent>.broadcast();

    Stream<SwfEvent> get events => _events.stream;

    factory Swf(SwfObjectFactory factory, ObjectElement swfEl) {
        JsObject jsObj = new JsObject.fromBrowserObject(swfEl);
        return new Swf._(factory.contextPrefix,
                new List.from(factory.contextObjectNames),
                swfEl, jsObj, factory.wrapperElement);

    }

    Swf._(this.objectId, this._contextObjects, this._swfElement,
            this._js, this.wrapperElement);

    /**
     * Adds an event listener that pushes [SwfEvent] instances into the
     * [events] stream.
     */
    void addEventListener(String eventName, [ dynamic eventValue ]) {
        String id = objectId + eventName;
        _contextObjects.add(id);
        context[id] = (arg) {
            var val = eventValue;
            if (eventValue is Function) {
                val = eventValue(arg);
            }
            _events.sink.add(new SwfEvent(this, eventName, arg, val));
        };
        _js.callMethod('addEventListener', [ eventName, id ]);
    }


    dynamic invoke(String method, [ List args ]) {
        if (args == null) {
            args = [];
        }
        return _js.callMethod(method, args);
    }


    void destroy() {
        _swfElement.remove();
        for (String id in _contextObjects) {
            context.deleteProperty(id);
        }
        _events.sink.close();
        _swfElement = null;
        _js = null;
    }
}
