import Rails from '@rails/ujs';
import GenericPage from './generic_page';

class GenericForm extends GenericPage {
  addEventListeners() {
    super.addEventListeners();

    this.root.on('submit', this.onSubmit);
  }

  reloadUIElements() {
    super.reloadUIElements();

    document.querySelectorAll('[name]').forEach((element) => {
      const { name } = element;
      const captures = name.match(/\[([a-z0-9_]+)\]/g);

      if (captures) {
        this.setNestedField(captures, element);
      } else {
        this.fields[name] = element;
      }
    }, this);
  }

  // Modified to remove recursion - no need to pass elements around endlessly.
  setNestedField(path, element) {
    let next;

    let context = this.fields;
    const first = path.shift();
    let piece = first.substring(1, first.length - 1);

    while (path.length > 0) {
      if (context[piece] == null) {
        context[piece] = {};
      }

      context = context[piece];

      next = path.shift();

      piece = next.substring(1, next.length - 1);
    }

    context[piece] = element;
  }

  validate() { return true; } // eslint-disable-line class-methods-use-this

  onSubmit(e) {
    if (this.validate()) {
      return true;
    }

    e.preventDefault();

    setTimeout((() => Rails.enableFormElements(this.root)), 100);

    return false;
  }
}

export default GenericForm;
