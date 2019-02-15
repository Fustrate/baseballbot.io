import {Success, Warning, Info } from './components/flash'

class GenericPage {
  constructor(root) {
    this.root = root;

    this._reloadUIElements();
    this.addEventListeners();
    this.initialize();
  }

  include(concern) {
    var instance = new concern;

    for (var name in Object.getOwnPropertyNames(instance.constructor)) {
      if (key === 'included' || key === 'initialize') {
        continue;
      }

      if (!this.constructor[key]) {
        this.constructor[key] = instance.constructor[key];
      }
    }

    // Assign properties to the prototype
    for (var key in concern.prototype) {
      if (key === 'included' || key === 'initialize') {
        continue;
      }

      if (!this[key]) {
        this[key] = concern.prototype[key].bind(this);
      }
    }

    if (instance.included != null) {
      instance.included.apply(this);
    }
  }

  addEventListeners() {
    for (var name in this) {
      // Edge returns true for /one.+two/.test('onetwo'), 2017-10-21
      if (/^add..*EventListeners$/.test(name)) {
        this[name].apply(this);
      }
    }
  }

  // Once the interface is loaded and the event listeners are active, run any
  // other tasks.
  initialize() {}

  _reloadUIElements() {
    this.fields = {};
    this.buttons = {};

    $('[data-field]', this.root).not('.modal [data-field]')
      .each((i, element) => {
        this.fields[element.dataset.field] = $(element);
      });

    $('[data-button]', this.root).not('.modal [data-button]')
      .each((i, element) => {
        this.buttons[element.dataset.button] = $(element);
      });
  }

  flashSuccess(message, {icon} = {}) {
    new Success(message, { icon: icon });
  }

  flashWarning(message, {icon} = {}) {
    new Warning(message, { icon: icon });
  }

  flashInfo(message, {icon} = {}) {
    new Info(message, { icon: icon });
  }

  setHeader(text) {
    $('.header > span', this.root).text(text);
  }

  // Calls all methods matching /refresh.+/
  refresh() {
    for (var name in Object.getOwnPropertyNames(this)) {
      if (name.indexOf('refresh') === 0 && name !== 'refresh') {
        this[name]();
      }
    }
  }
};
