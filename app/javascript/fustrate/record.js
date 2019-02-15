import BasicObject from './basic_object'

class Record extends BasicObject {
  static get classname() {
    return null;
  }

  constructor(data) {
    super(data);

    this._loaded = false;

    if (typeof data === 'number' || typeof data === 'string') {
      // If the parameter was a number or string, it's likely the record ID
      this.id = parseInt(data, 10);
    } else {
      // Otherwise we were probably given a hash of attributes
      this.extractFromData(data);
    }
  }

  reload({ force } = {}) {
    if (this._loaded && !force) {
      return $.when();
    }

    return $.get(this.path({ format: 'json' })).done(response => {
      this.extractFromData(response);

      this._loaded = true;
    });
  }

  update(attributes = {}) {
    var url;

    if (this.id) {
      url = this.path({ format: 'json' });
    } else {
      this.extractFromData(attributes);

      url = Routes[this.constructor.create_path]({ format: 'json' });
    }

    if (this.community && attributes.community_id === void 0) {
      attributes.community_id = this.community.id;
    }

    var formData = this._toFormData(
      new FormData,
      attributes,
      this.constructor.paramKey()
    );

    return $.ajax({
      url: url,
      data: formData,
      processData: false,
      contentType: false,
      method: this.id ? 'PATCH' : 'POST',
      xhr: () => {
        var xhr;
        xhr = $.ajaxSettings.xhr();
        xhr.upload.onprogress = e => {
          return this.trigger('upload_progress', e);
        };
        return xhr;
      }
    }).done(this.extractFromData);
  }

  delete() {
    return $.ajax(this.path({ format: 'json' }), { method: 'DELETE' });
  }

  _toFormData(data, object, namespace) {
    for (let field of Object.getOwnPropertyNames(object)) {
      if (!(typeof object[field] !== 'undefined')) {
        continue;
      }

      let key = namespace ? `${namespace}[${field}]` : field;

      if (object[field] && typeof object[field] === 'object') {
        this._appendObjectToFormData(data, key, object[field]);
      } else if (typeof object[field] === 'boolean') {
        data.append(key, Number(object[field]));
      } else if (object[field] !== null && object[field] !== void 0) {
        data.append(key, object[field]);
      }
    }

    return data;
  }

  _appendObjectToFormData(data, key, value) {
    if (value instanceof Array) {
      for (let array_item of value) {
        data.append(`${key}[]`, array_item)
      }
    } else if (value instanceof File) {
      data.append(key, value);
    } else if (moment.isMoment(value)) {
      data.append(key, value.format());
    } else if (!(value instanceof Fustrate.Record)) {
      this._toFormData(data, value, key);
    }
  }

  static paramKey() {
    return this.class.underscore().replace('/', '_');
  }

  static create(attributes) {
    var record = new this;

    return $.Deferred(deferred => {
      record.update(attributes).fail(deferred.reject).done(() => {
        this.deferred.resolve(record);
      });
    });
  }
}

export default Record

