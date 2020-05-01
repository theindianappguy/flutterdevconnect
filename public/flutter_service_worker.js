'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "0e6fe7610c2a720a64213120d6b9df08",
"/": "0e6fe7610c2a720a64213120d6b9df08",
"main.dart.js": "068ba49cde37355ab78d24abf81d8098",
"favicon.png": "b2cd3acc845e2ba8895bc280124088c2",
"icons/Icon-192.png": "4465d63f57906dc67ed9c2ecce3ddc4f",
"icons/Icon-512.png": "0b3a492c9f1b10d6ee64ff630a64eb25",
"manifest.json": "c139f50911ca96dc13f3ef0096e0f74c",
"assets/LICENSE": "8033621fb4b62db0bd2ef00b98922078",
"assets/AssetManifest.json": "f329e64b9293dabf4b6177b18ba40014",
"assets/FontManifest.json": "e8aa4d19e8e636aebc8066611718a76b",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/assets/images/info.png": "21593986fce2ebd98788d4dfe41c27ea",
"assets/assets/images/gif.png": "ea68dc7e5c79551cc4390e1d6f9fd19d",
"assets/assets/images/book.png": "6a7da092517e34202a08da88cd71a078",
"assets/assets/images/gallery.png": "d9fade6ffb059164c8050b86558ebcbe",
"assets/assets/images/mail.png": "5b62ced007402ed7f61edb72a1577342",
"assets/assets/images/smiley.png": "72761d3e1839d0988ab8f158d06a354c",
"assets/assets/images/info_blue.png": "8ad7990e44a5168b689fe86e74258e5c",
"assets/assets/images/search_white.png": "ed461ca683333d3b3f252ab5e890f8b4",
"assets/assets/images/microphone.png": "b1d3e7dad43f93bf9a4098ff89917408",
"assets/assets/images/back_arrow.png": "d4df74353a032c212881f71fc8fda2e7",
"assets/assets/images/github.png": "6f67c560e04b757e0a944e097efcb572",
"assets/assets/images/logout.png": "0e6ff6346955b8edf26c15ee89b16c2a",
"assets/assets/images/home.png": "9a179009919d39352e0d193836c2b6ae",
"assets/assets/images/call_icon.png": "689636b6037294f75ae5ddbaf10df49b",
"assets/assets/images/block.png": "5c3ec61d688789c33a5a2297883e3fc9",
"assets/assets/images/chatbubble.png": "df1b0f1f3c8795a42cb6f330d2f9435f",
"assets/assets/images/logo.png": "9e9ec2a9ddb267cffe0be2bd106ea26c",
"assets/assets/images/money.png": "73ee841493f06adfe7fdfa966470c5fa",
"assets/assets/images/share.png": "cbd053fedf63665c3f7bfc352aa62203",
"assets/assets/images/search_grey.png": "5a9bdde4f1dc3058d758c50950ab22e3",
"assets/assets/images/openbook.png": "b1a59954d1eacf1d4e9c6fbde2d30a5a",
"assets/assets/images/camera.png": "9d299856817ce1275fd4a0ab5a6d6299",
"assets/assets/images/coin.png": "015ddebc17c30b1160976608fd4918d7",
"assets/assets/images/send.png": "c53b66924c9a76467ef6b8bf87445aee",
"assets/assets/images/add_solid.png": "341a4ce40ccaafddadb7b0b1b8e652e3",
"assets/assets/images/back_btn_white.png": "5da2af680b5da98323115153aeba1b7e",
"assets/assets/images/blue_phone.png": "d47ea48d192366ac293e0ea2fd86e4d4",
"assets/assets/fonts/overpass_bold.otf": "e6dbbcd2f162fd16564f50bfbbbfcb58",
"assets/assets/fonts/overpass_regular.otf": "71096f93ab59ad7c66a963700c422f54"
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
