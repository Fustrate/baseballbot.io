import $ from 'jquery';

class GenericPage {
  constructor(root) {
    this.root = root;

    this.reloadUIElements();
    this.addEventListeners();
    this.initialize();
  }

  include(concern) {
    const instance = new concern();

    Object.getOwnPropertyNames(instance.constructor).forEach((key) => {
      if (key === 'included' || key === 'initialize') {
        return;
      }

      if (!this.constructor[key]) {
        this.constructor[key] = instance.constructor[key];
      }
    });

    // Assign properties to the prototype
    Object.getOwnPropertyNames(concern.prototype).forEach((key) => {
      if (key === 'included' || key === 'initialize') {
        return;
      }

      if (!this[key]) {
        this[key] = concern.prototype[key].bind(this);
      }
    });

    if (instance.included != null) {
      instance.included.apply(this);
    }
  }

  addEventListeners() {
    Object.getOwnPropertyNames(this).forEach((name) => {
      // Edge returns true for /one.+two/.test('onetwo'), 2017-10-21
      if (/^add..*EventListeners$/.test(name)) {
        this[name].apply(this);
      }
    });
  }

  // Once the interface is loaded and the event listeners are active, run any
  // other tasks.
  initialize() {}

  reloadUIElements() {
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

  setHeader(text) {
    $('.header > span', this.root).text(text);
  }

  // Calls all methods matching /refresh.+/
  refresh() {
    Object.getOwnPropertyNames(this).forEach((name) => {
      if (name.indexOf('refresh') === 0 && name !== 'refresh') {
        this[name]();
      }
    });
  }
}

export default GenericPage;
