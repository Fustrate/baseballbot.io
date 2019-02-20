import $ from 'jquery';
import moment from 'moment';

import Fustrate from '.';
import BasicObject from './basic_object';

class Record extends BasicObject {
  static get classname() { return null; }

  constructor(data) {
    super(data);

    this.isLoaded = false;

    if (typeof data === 'number' || typeof data === 'string') {
      // If the parameter was a number or string, it's likely the record ID
      this.id = parseInt(data, 10);
    } else {
      // Otherwise we were probably given a hash of attributes
      this.extractFromData(data);
    }
  }

  reload({ force } = {}) {
    if (this.isLoaded && !force) {
      return $.when();
    }

    return $.get(this.path({ format: 'json' })).done((response) => {
      this.extractFromData(response);

      this.isLoaded = true;
    });
  }

  update(attributes = {}) {
    let url;

    if (this.id) {
      url = this.path({ format: 'json' });
    } else {
      this.extractFromData(attributes);

      url = this.constructor.create_path({ format: 'json' });
    }

    const recordAttributes = attributes;

    if (this.community && attributes.community_id === undefined) {
      recordAttributes.community_id = this.community.id;
    }

    const formData = this.toFormData(
      new FormData(),
      recordAttributes,
      this.constructor.paramKey(),
    );

    return $.ajax({
      url,
      data: formData,
      processData: false,
      contentType: false,
      method: this.id ? 'PATCH' : 'POST',
      xhr: () => {
        const xhr = $.ajaxSettings.xhr();
        xhr.upload.onprogress = e => this.trigger('upload_progress', e);
        return xhr;
      },
    }).done(this.extractFromData);
  }

  delete() {
    return $.ajax(this.path({ format: 'json' }), { method: 'DELETE' });
  }

  _toFormData(data, object, namespace) {
    Object.getOwnPropertyNames(object).forEach((field) => {
      if (!(typeof object[field] !== 'undefined')) {
        return;
      }

      const key = namespace ? `${namespace}[${field}]` : field;

      if (object[field] && typeof object[field] === 'object') {
        this.appendObjectToFormData(data, key, object[field]);
      } else if (typeof object[field] === 'boolean') {
        data.append(key, Number(object[field]));
      } else if (object[field] !== null && object[field] !== undefined) {
        data.append(key, object[field]);
      }
    });

    return data;
  }

  appendObjectToFormData(data, key, value) {
    if (value instanceof Array) {
      value.forEach((item) => {
        data.append(`${key}[]`, item);
      });
    } else if (value instanceof File) {
      data.append(key, value);
    } else if (moment.isMoment(value)) {
      data.append(key, value.format());
    } else if (!(value instanceof Fustrate.Record)) {
      this.toFormData(data, value, key);
    }
  }

  static paramKey() {
    return this.class.underscore().replace('/', '_');
  }

  static create(attributes) {
    const record = new this();

    return $.Deferred((deferred) => {
      record.update(attributes).fail(deferred.reject).done(() => {
        this.deferred.resolve(record);
      });
    });
  }
}

export default Record;
