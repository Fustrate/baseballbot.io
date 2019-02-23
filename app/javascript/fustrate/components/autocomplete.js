import $ from 'jquery';
import Awesomplete from 'awesomplete';

import Component from '../component';

Awesomplete.SORT_BYLENGTH = () => {};

class Autocomplete extends Component {
  constructor(input, types) {
    super();

    this.input = input;

    let defaultTypes = types;

    if (Array.isArray(types)) {
      defaultTypes = {
        plain: {
          list: types.map(value => ({ value })),
        },
      };
    }

    this.sources = Object.keys(defaultTypes).map((key) => {
      const options = defaultTypes[key];
      return Object.deepExtend({}, this.constructor.types[key], options);
    });

    if (this.sources.length === undefined) {
      this.sources = [this.sources];
    }

    const existing = this.input.data('awesomplete');

    if (existing) {
      existing.sources = this.sources;

      return;
    }

    this.awesomplete = new Awesomplete(this.input[0], {
      minChars: 0,
      maxItems: 25,
      filter: () => true,
      item: option => option, // Items are pre-rendered
      sort: false, // Items are fed in the intended order
    });

    this.id_field = this.awesomplete.container.querySelector('~ input:hidden[name*="_id"]');
    this.type_field = this.awesomplete.container.querySelector('~ input:hidden[name*="_type"]');

    this.input
      .data('awesomplete', this)
      .on('awesomplete-highlight', this.onHighlight)
      .on('awesomplete-select', this.onSelect)
      .on('keyup', this.onKeyup.debounce())
      .on('focus', this.onFocus);
  }

  blanked() {
    if (this.input.val().trim() !== '') {
      return;
    }

    this.awesomplete.close();

    if (this.id_field) {
      this.id_field.value = null;
    }

    if (this.type_field) {
      this.type_field.value = null;
    }

    this.input.trigger('blanked.autocomplete');
  }

  onFocus() {
    this.items = [];
    this.value = this.input.val().trim();

    this.sources.forEach((source) => {
      if (source.list == null) {
        return;
      }

      source.list.forEach((datum) => {
        if (source.filter(datum, this.value)) {
          this.items.push(this.createListItem(datum, source));
        }
      }, this);
    }, this);

    this.awesomplete.list = this.items;
  }

  onHighlight() {
    const item = this.input[0].querySelector('+ ul li[aria-selected="true"]');

    if (!item) {
      return;
    }

    item.scrollIntoView(false);

    this.replace(item.dataset.datum.displayValue);
  }

  onSelect(e) {
    // aria-selected isn't set on click
    const item = e.originalEvent.origin.closest('li');
    const datum = item.data('datum');

    this.replace(datum.displayValue);

    this.awesomplete.close();

    if (this.id_field) {
      this.id_field.value = datum.id;
    }

    if (this.type_field) {
      this.type_field.value = datum.type;
    }

    this.input.data({ datum }).trigger('finished.autocomplete');

    return false;
  }

  onKeyup(e) {
    const keyCode = e.which || e.keyCode;
    const value = this.input.val().trim();

    if (value === '' && this.value !== '') {
      this.blanked();

      return;
    }

    // Ignore: Tab, Enter, Esc, Left, Up, Right, Down
    if ([9, 13, 27, 37, 38, 39, 40].includes(keyCode)) {
      return;
    }

    // Don't perform the same search twice in a row
    if (value === this.value || value.length < 3) {
      return;
    }

    this.value = value;
    this.items = [];

    this.sources.forEach((source) => {
      if (source.url != null) {
        this.performSearch(source);
      } else if (source.list != null) {
        source.list.forEach((datum) => {
          if (source.filter(datum, this.value)) {
            this.items.push(this.createListItem(datum, source));
          }
        }, this);

        this.awesomplete.list = this.items;
      }
    }, this);
  }

  performSearch(source) {
    $.get(source.url({
      search: this.value,
      commit: 1,
      format: 'json',
    })).done((response) => {
      response.forEach((item) => {
        this.items.push(this.createListItem(item, source));
      }, this);

      this.awesomplete.list = this.items;
    });
  }

  createListItem(datum, source) {
    const listItemDatum = datum;

    listItemDatum.displayValue = datum[source.displayKey];
    listItemDatum.type = source.type;

    const listItem = source.item.call(this, listItemDatum, this.value);

    return $(listItem).data({ listItemDatum }).get(0);
  }

  highlight(text) {
    if (!text) {
      return '';
    }

    return text.replace(RegExp(`(${this.value.split(/\s+/).join('|')})`, 'gi'), '<mark>$&</mark>');
  }

  replace(text) {
    this.awesomplete.replace(text);
  }

  static addType(name, func) {
    Autocomplete.types[name] = func;
  }

  static addTypes(types) {
    Object.getOwnPropertyNames(types).forEach((name) => {
      this.addType(name, types[name]);
    }, this);
  }
}

Autocomplete.types = {
  plain: {
    displayKey: 'value',
    item: object => `<li>${this.highlight(object.value)}</li>`,
    filter: (object, userInput) => {
      const search = userInput.trim().toLowerCase();

      return object.value.toLowerCase().indexOf(search) >= 0;
    },
  },
};

export default Autocomplete;
