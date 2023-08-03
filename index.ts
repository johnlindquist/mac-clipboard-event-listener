import bindings from "bindings"
const addon = bindings("mac-clipboard-listener.node")

type ChangeHandler = () => void
export const onClipboardImageChange = (handler: ChangeHandler) => {
  addon.onClipboardImageChange(handler)
}
export const onClipboardTextChange = (handler: ChangeHandler) => {
  addon.onClipboardTextChange(handler)
}

export const start = () => {
  addon.start()
}

export const stop = () => {
  addon.stop()
}
