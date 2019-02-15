class Listenable {
  constructor() {
    this.listeners = {};
  }

  on(eventNames, callback) {
    eventNames.split(' ').forEach((eventName) => {
      if (!this.listeners[eventName]) {
        this.listeners[eventName] = [];
      }

      this.listeners[eventName].push(callback);
    });

    return this;
  }

  off(eventNames) {
    eventNames.split(' ').forEach((eventName) => {
      this.listeners[eventName] = [];
    });

    return this;
  }

  trigger(name, ...args) {
    if (!(name && this.listeners[name])) {
      return this;
    }

    this.listeners[name].forEach((callback) => {
      callback.apply(this, args);
    });

    return this;
  }
}

export default Listenable;
