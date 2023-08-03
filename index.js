// index.ts
import bindings from "bindings";
var addon = bindings("mac-clipboard-listener.node");
var onClipboardImageChange = (handler) => {
  addon.onClipboardImageChange(handler);
};
var onClipboardTextChange = (handler) => {
  addon.onClipboardTextChange(handler);
};
var start = () => {
  addon.start();
};
var stop = () => {
  addon.stop();
};
export {
  onClipboardImageChange,
  onClipboardTextChange,
  start,
  stop
};
