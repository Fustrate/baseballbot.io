import Listenable from './listenable'
import moment from 'moment'

class BasicObject extends Listenable {
  constructor(data) {
    super(data);

    this.extractFromData(data);
  }

  // Simple extractor to assign root keys as properties in the current object.
  // Formats a few common attributes as dates with moment.js
  extractFromData(data) {
    if (!data) {
      return
    }

    for (var key in data) {
      this[key] = data[key];
    }

    if (this.date) {
      this.date = moment(this.date);
    }

    if (this.created_at) {
      this.created_at = moment(this.created_at);
    }

    if (this.updated_at) {
      return this.updated_at = moment(this.updated_at);
    }
  }

  // Instantiate a new object of type klass for each item in items
  _createList(items, klass, additional_attributes = {}) {
    return items.map(function(item) {
      return new klass($.extend(true, {}, item, additional_attributes));
    })
  }

  static buildList(items, additional_attributes = {}) {
    var i, item, len, results;

    results = [];

    for (i = 0, len = items.length; i < len; i++) {
      item = items[i];
      results.push(new this($.extend(true, {}, item, additional_attributes)));
    }

    return results;
  }
}

export default BasicObject
