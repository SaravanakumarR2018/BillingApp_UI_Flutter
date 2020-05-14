'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "422034f30df88b530037e4805850161b",
"/": "422034f30df88b530037e4805850161b",
"main.dart.js": "f0387f1bc51215e682edd4fa71db3aa8",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "6697f798a6f688bbad1475184ad4a5b7",
"assets/LICENSE": "64b50c83314b55884e9d634d8ceaf1a9",
"assets/AssetManifest.json": "985ff6ef7d99efcb7a664d860e759a1a",
"assets/FontManifest.json": "580ff1a5d08679ded8fcf5c6848cece7",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/assets/logos/goog.png": "0fa3fe04edf6c0202970f2088edea9e7",
"assets/assets/logos/fb.png": "4fd2dd89cee556dac0f0982e69a65d1c",
"assets/assets/icon/billingapp.png": "563419bced15fbbac48570b20c4a879d"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
