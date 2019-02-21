class GenericPage {
  constructor(root) {
    this.root = root;

    this.reloadUIElements();
    this.addEventListeners();
  }

  // include(concern) {
  //   const instance = new concern();

  //   Object.getOwnPropertyNames(instance.constructor).forEach((key) => {
  //     if (key === 'included' || key === 'initialize') {
  //       return;
  //     }

  //     if (!this.constructor[key]) {
  //       this.constructor[key] = instance.constructor[key];
  //     }
  //   }, this);

  //   // Assign properties to the prototype
  //   Object.getOwnPropertyNames(Object.getPrototypeOf(concern)).forEach((key) => {
  //     if (key === 'included' || key === 'initialize') {
  //       return;
  //     }

  //     if (!this[key]) {
  //       this[key] = concern[key].bind(this);
  //     }
  //   }, this);

  //   if (instance.included != null) {
  //     instance.included.apply(this);
  //   }
  // }

  addEventListeners() {
    Object.getOwnPropertyNames(Object.getPrototypeOf(this)).forEach((name) => {
      // Edge returns true for /one.+two/.test('onetwo'), 2017-10-21
      if (/^add..*EventListeners$/.test(name)) {
        this[name].apply(this);
      }
    });
  }

  // Once the interface is loaded and the event listeners are active, run any
  // other tasks.
  initialize() {} // eslint-disable-line class-methods-use-this

  reloadUIElements() {
    this.fields = {};
    this.buttons = {};

    Array.prototype.filter.call(
      this.root.querySelectorAll('[data-field]'),
      element => !element.matches('.modal [data-field]'),
    ).forEach((element) => {
      this.fields[element.dataset.field] = element;
    });

    Array.prototype.filter.call(
      this.root.querySelectorAll('[data-button]'),
      element => !element.matches('.modal [data-button]'),
    ).forEach((element) => {
      this.buttons[element.dataset.button] = element;
    });
  }

  setHeader(text) {
    this.root.querySelector('.header > span').textContent = text;
  }

  // Calls all methods matching /refresh.+/
  refresh() {
    Object.getOwnPropertyNames(Object.getPrototypeOf(this)).forEach((name) => {
      if (name !== 'refresh' && name.indexOf('refresh') === 0) {
        this[name].apply(this);
      }
    });
  }
}

export default GenericPage;
