import bindings from "bindings";
const addon = bindings("mac-clipboard-listener.node");
export const onClipboardImageChange = (handler) => {
    addon.onClipboardImageChange(handler);
};
export const onClipboardTextChange = (handler) => {
    addon.onClipboardTextChange(handler);
};
export const start = () => {
    addon.start();
};
export const stop = () => {
    addon.stop();
};
