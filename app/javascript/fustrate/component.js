import Listenable from './listenable';

class Component extends Listenable {
  static initialize() {
    Component.initializers.forEach((func) => {
      func.call();
    });
  }

  static register(klass) {
    Component.initializers.push(klass.initialize);
  }
}

Component.initializers = [];

export default Component;
