'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "3f69e0d0d8c197ef9e0a2bf8fb0aed35",
"assets/assets/icons/icon.png": "5829d64517a1dcb483a85a3056353a85",
"assets/assets/icons/icon_1.png": "c01ec450b7758694816e0a607500d30e",
"assets/assets/icons/pokeball.png": "14572c36e2d331532f19f54c7593a0ce",
"assets/assets/icons/pokeball_1.png": "c9542ee0b693813e8d0ae69e7217f0d7",
"assets/assets/images/bug.png": "09b5dfed3f50286b98b8eebb628a00e2",
"assets/assets/images/dark.png": "d04a30f0b8e303eef053cb28b1926c8e",
"assets/assets/images/dragon.png": "72e737d88278dfa3371284fc9f81b150",
"assets/assets/images/electric.png": "aad3567f751af86267d203b088e4b6e3",
"assets/assets/images/fairy.png": "9c0cc4827cd45eaed012ab9357388837",
"assets/assets/images/fighting.png": "7da31201c694df3eb6a81132b6fec0ec",
"assets/assets/images/fire.png": "96d5818a6b2f7cf6a356ed3c3e69db34",
"assets/assets/images/flying.png": "8497680ca011385944487bfc929abcff",
"assets/assets/images/ghost.png": "26cea1ee4e02e96c38e8d5578151a5cb",
"assets/assets/images/grass.png": "1e699a01deec5e0d07e260fec5c7ef5c",
"assets/assets/images/ground.png": "fecfe6e72cbe30a7e6e5711d17e69900",
"assets/assets/images/ice.png": "38a5e81a0fe951c2556b49cce4829ea1",
"assets/assets/images/normal.png": "7e733ff656b709e1dba4f55c7515445a",
"assets/assets/images/poison.png": "00614b70225ccc861664e011940f3d27",
"assets/assets/images/psychic.png": "050e805f90b6e1643c20fd147e6ca97a",
"assets/assets/images/rock.png": "16f6cb0bbe5608e392f8bf4b88542308",
"assets/assets/images/steel.png": "bb54f023c5327e9d587e7786e4f08081",
"assets/assets/images/water.png": "499091dcab09a2f4a48011713afad85c",
"assets/FontManifest.json": "1b1e7812d9eb9f666db8444d7dde1b20",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/NOTICES": "1817ecfc262935503e48cb84ff44712e",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/material_design_icons_flutter/lib/fonts/materialdesignicons-webfont.ttf": "174c02fc4609e8fc4389f5d21f16a296",
"favicon.png": "94079bcb42271970c028f9e8b5651cfd",
"icons/Icon-192.png": "46d238516db5d49cc88a170219ddd07f",
"icons/Icon-512.png": "5829d64517a1dcb483a85a3056353a85",
"index.html": "a93f973560a1bd1bf09d96c004f33045",
"/": "a93f973560a1bd1bf09d96c004f33045",
"main.dart.js": "2deb4b8c76711e00407a1ebd2bc39f06",
"manifest.json": "d491b1306d028536419c3997a605b4de",
"splash/img/dark-1x.png": "fcda59fbf98bbfd31d7ef2bdf7ab35e4",
"splash/img/dark-2x.png": "8ebdb826888292c2944720dc540d2169",
"splash/img/dark-3x.png": "fbe7ba45b09536b558fe533fe8680243",
"splash/img/light-1x.png": "fcda59fbf98bbfd31d7ef2bdf7ab35e4",
"splash/img/light-2x.png": "8ebdb826888292c2944720dc540d2169",
"splash/img/light-3x.png": "fbe7ba45b09536b558fe533fe8680243",
"splash/style.css": "6b69cb06c7aa9b12ff83f688e0c80cde",
"version.json": "b92667e2cf8fb9283bc068de06be00af"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
