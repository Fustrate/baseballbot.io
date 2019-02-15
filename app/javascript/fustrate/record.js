import BasicObject from './basic_object'

class Record extends BasicObject {
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

  reload({force} = {}) {
    if (this._loaded && !force) {
      return $.when();
    }

    return $.get(this.path({ format: 'json' })).done((response) => {
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
        xhr.upload.onprogress = (e) => {
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
    var field, key, value;

    for (field in object) {
      if (!object.hasOwnProperty(field)) {
        continue;
      }

      value = object[field];

      if (!(typeof value !== 'undefined')) {
        continue;
      }

      key = namespace ? `${namespace}[${field}]` : field;

      if (value && typeof value === 'object') {
        this._appendObjectToFormData(data, key, value);
      } else if (typeof value === 'boolean') {
        data.append(key, Number(value));
      } else if (value !== null && value !== void 0) {
        data.append(key, value);
      }
    }

    return data;
  }

  _appendObjectToFormData(data, key, value) {
    if (value instanceof Array) {
      for (var array_item in value) {
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

    return $.Deferred((deferred) => {
      return record.update(attributes).fail(deferred.reject).done(() => {
        return this.deferred.resolve(record);
      });
    });
  }
}

Record.define('class', {
  get: function() {
    return this.constructor.class
  }
})

export default Record

