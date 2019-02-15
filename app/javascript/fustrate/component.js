import $ from 'jquery';

import Listenable from './listenable';

class Component extends Listenable {
  static initialize() {
    $('body').append('<div id="flashes">');
  }
}

export default Component;
