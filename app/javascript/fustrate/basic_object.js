import moment from 'moment';
import $ from 'jquery';

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

    Object.keys(data).forEach((key) => {
      this[key] = data[key];
    });

    if (this.date) {
      this.date = moment(this.date);
    }

    if (this.created_at) {
      this.created_at = moment(this.created_at);
    }

    if (this.updated_at) {
      this.updated_at = moment(this.updated_at);
    }
  }

  static buildList(items, attributes = {}) {
    return items.map(item => new this($.extend(true, {}, item, attributes)));
  }
}

export default BasicObject;
