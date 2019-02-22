import moment from 'moment';

import Listenable from './listenable';

class BasicObject extends Listenable {
  constructor(data) {
    super(data);

    this.extractFromData(data);
  }

  // Simple extractor to assign root keys as properties in the current object.
  // Formats a few common attributes as dates with moment.js
  extractFromData(data) {
    if (!data) {
      return;
    }

    Object.getOwnPropertyNames(data).forEach((key) => {
      this[key] = data[key];
    }, this);

    if (this.date) {
      this.date = moment(this.date);
    }

    if (this.createdAt) {
      this.createdAt = moment(this.createdAt);
    }

    if (this.updatedAt) {
      this.updatedAt = moment(this.updatedAt);
    }
  }

  static buildList(items, attributes = {}) {
    return items.map(item => new this(Object.deepExtend({}, item, attributes)));
  }
}

export default BasicObject;
