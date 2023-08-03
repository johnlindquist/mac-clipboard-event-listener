import { start, stop, onClipboardImageChange, onClipboardTextChange } from "../index.js"

console.log(`Starting...`)
start()

onClipboardImageChange(() => {
  console.log("image")
})

onClipboardTextChange(() => {
  console.log("text")
})

setTimeout(() => {
  stop()
  console.log(`Stopped`)

  //   setTimeout(() => {
  //     start()
  //     console.log(`Restarting...`)

  //     setTimeout(() => {
  //       stop()
  //       console.log(`Stopped.`)
  //     }, 3000)
  //   }, 3000)
}, 3000)
