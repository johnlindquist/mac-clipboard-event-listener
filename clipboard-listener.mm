#include <napi.h>
#include <AppKit/AppKit.h>

napi_threadsafe_function g_tsfnImage = nullptr;
napi_threadsafe_function g_tsfnText = nullptr;

bool g_checkingClipboard = false; // Variable to control loop

void CallJavaScript(napi_env env, napi_value jsCallback, void* context, void* data) {
  napi_value undefined;
  napi_get_undefined(env, &undefined);
  napi_call_function(env, undefined, jsCallback, 0, nullptr, nullptr);
}

bool ClipboardHasImage() {
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
  NSArray *classArray = [NSArray arrayWithObject:[NSImage class]];
  NSDictionary *options = [NSDictionary dictionary];

  BOOL ok = [pasteboard canReadObjectForClasses:classArray options:options];
  
  return ok;
}

bool ClipboardHasText() {
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
  NSString *string = [pasteboard stringForType:NSPasteboardTypeString];
  
  return (string != nil);
}

void CheckClipboardForChanges() {
  if (!g_checkingClipboard) return;

  static NSInteger changeCount = -1;
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

  if (pasteboard.changeCount != changeCount) {
    changeCount = pasteboard.changeCount;

    if (ClipboardHasImage() && g_tsfnImage != nullptr) {
      napi_call_threadsafe_function(g_tsfnImage, nullptr, napi_tsfn_nonblocking);
    }

    if (ClipboardHasText() && g_tsfnText != nullptr) {
      napi_call_threadsafe_function(g_tsfnText, nullptr, napi_tsfn_nonblocking);
    }
  }

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if (g_checkingClipboard) CheckClipboardForChanges();
  });
}

Napi::Value OnClipboardImageChange(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();

  if (info.Length() < 1) {
    Napi::TypeError::New(env, "Wrong number of arguments").ThrowAsJavaScriptException();
    return env.Null();
  }

  if (!info[0].IsFunction()) {
    Napi::TypeError::New(env, "Argument must be a function").ThrowAsJavaScriptException();
    return env.Null();
  }

  if (g_tsfnImage != nullptr) {
    napi_release_threadsafe_function(g_tsfnImage, napi_tsfn_release);
  }

  napi_create_threadsafe_function(env, info[0], nullptr, Napi::String::New(env, "clipboard image change callback"), 0, 1, nullptr, nullptr, nullptr, CallJavaScript, &g_tsfnImage);
  napi_ref_threadsafe_function(env, g_tsfnImage);

  return env.Null();
}

Napi::Value OnClipboardTextChange(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();

  if (info.Length() < 1) {
    Napi::TypeError::New(env, "Wrong number of arguments").ThrowAsJavaScriptException();
    return env.Null();
  }

  if (!info[0].IsFunction()) {
    Napi::TypeError::New(env, "Argument must be a function").ThrowAsJavaScriptException();
    return env.Null();
  }

  if (g_tsfnText != nullptr) {
    napi_release_threadsafe_function(g_tsfnText, napi_tsfn_release);
  }

  napi_create_threadsafe_function(env, info[0], nullptr, Napi::String::New(env, "clipboard text change callback"), 0, 1, nullptr, nullptr, nullptr, CallJavaScript, &g_tsfnText);
  napi_ref_threadsafe_function(env, g_tsfnText);

  return env.Null();
}

Napi::Value Start(const Napi::CallbackInfo& info) {
  g_checkingClipboard = true;
  CheckClipboardForChanges();
  return info.Env().Null();
}

Napi::Value Stop(const Napi::CallbackInfo& info) {
  g_checkingClipboard = false;
  if (g_tsfnImage != nullptr) {
    napi_release_threadsafe_function(g_tsfnImage, napi_tsfn_release);
    g_tsfnImage = nullptr;
  }
  if (g_tsfnText != nullptr) {
    napi_release_threadsafe_function(g_tsfnText, napi_tsfn_release);
    g_tsfnText = nullptr;
  }
  return info.Env().Null();
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "onClipboardImageChange"), Napi::Function::New(env, OnClipboardImageChange));
  exports.Set(Napi::String::New(env, "onClipboardTextChange"), Napi::Function::New(env, OnClipboardTextChange));
  exports.Set(Napi::String::New(env, "start"), Napi::Function::New(env, Start));
  exports.Set(Napi::String::New(env, "stop"), Napi::Function::New(env, Stop));
  return exports;
}

NODE_API_MODULE(addon, Init)
