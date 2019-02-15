class Listenable {
  constructor() {
    this.listeners = {};
  }

  on(eventNames, callback) {
    for (var eventName in eventNames.split(' ')) {
      if (!this.listeners[eventName]) {
        this.listeners[eventName] = [];
      }

      this.listeners[eventName].push(callback);
    }

    return this;
  }

  off(eventNames) {
    for (var eventName in eventNames.split(' ')) {
      this.listeners[eventName] = [];
    }

    return this;
  }

  trigger() {
    var args, event, name;

    [name, ...args] = arguments;

    if (!(name && this.listeners[name])) {
      return this;
    }

    for (event in this.listeners[name]) {
      event.apply(this, args);
    }

    return this;
  }
}

export default Listenable
