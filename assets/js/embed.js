// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";
import 'alpinejs'



import "mdn-polyfills/Object.assign"
import "mdn-polyfills/CustomEvent"
import "mdn-polyfills/String.prototype.startsWith"
import "mdn-polyfills/Array.from"
import "mdn-polyfills/NodeList.prototype.forEach"
import "mdn-polyfills/Element.prototype.closest"
import "mdn-polyfills/Element.prototype.matches"
import "mdn-polyfills/Node.prototype.remove"
import "child-replace-with-polyfill"
import "url-search-params-polyfill"
import "formdata-polyfill"
import "classlist-polyfill"
import "@webcomponents/template"
import "shim-keyboard-event-key"

import {
  Socket
} from "phoenix";
import LiveSocket from "phoenix_live_view";


class MyLiveSocket extends LiveSocket {

  getHref() {
    return 'https://www.example.com/embed';
  }
}

let conf = {
  host: 'kandires.werkzeugh.at.test'
};


(function () {

  let appdiv = document.getElementById("kandires");

  let baseurl = `https://${conf.host}`;


  var request = new XMLHttpRequest();


  const urlParams = new URLSearchParams(window.location.search);
  const step = urlParams.get('step');
  let url = `${baseurl}/embed`;
  if (step && step.match(/[a-z0-9_]+/i)) {
    url = url + '/' + step
  }
  url = url + '?pathname=' + escape(window.location.pathname);
  request.open('GET', url, true);
  request.withCredentials = true;

  request.onload = () => {
    if (request.status >= 200 && request.status < 400) {
      var resp = request.responseText;


      appdiv.innerHTML = resp;

      let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
      console.log('#log 6385 csrf ', csrfToken);
      let liveSocket = new MyLiveSocket(`wss://${conf.host}/live`, Socket, {
        params: {
          _csrf_token: csrfToken
        }
      });

      console.log('#log connected', liveSocket);
      liveSocket.connect();
    }
  };

  request.send();


})();
