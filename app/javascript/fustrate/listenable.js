class Listenable {
  constructor() {
    this.listeners = {};
  }

  on(eventNames, callback) {
    for (let eventName of eventNames.split(' ')) {
      if (!this.listeners[eventName]) {
        this.listeners[eventName] = [];
      }

      this.listeners[eventName].push(callback);
    }

    return this;
  }

  off(eventNames) {
    for (let eventName of eventNames.split(' ')) {
      this.listeners[eventName] = [];
    }

    return this;
  }

  trigger(name, ...args) {
    if (!(name && this.listeners[name])) {
      return this;
    }

    for (let event of this.listeners[name]) {
      event.apply(this, args);
    }

    return this;
  }
}

export default Listenable
