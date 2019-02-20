import $ from 'jquery';

import Component from '../component';

class Dropdown extends Component {
  static initialize() {
    this.body = $('body');
    return this.body.on('click.dropdowns', '.has-dropdown', this.open);
  }

  static open(event) {
    let left;
    let right;
    let top;

    Dropdown.hide();

    const button = $(event.currentTarget);
    const dropdown = $('+ .dropdown', button);

    Dropdown.locked = true;

    if (button.position().top > (Dropdown.body.height() / 2)) {
      top = button.position().top - dropdown.outerHeight() - 2;
    } else {
      top = button.position().top + button.outerHeight() + 2;
    }
    if (button.position().left > (Dropdown.body.width() / 2)) {
      left = 'inherit';
      right = Dropdown.body.width() - button.position().left - button.outerWidth();
    } else {
      right = 'inherit';
      ({ left } = button.position());
    }

    Dropdown.showDropdown(dropdown, { left, top, right });

    return false;
  }

  static showDropdown(dropdown, css) {
    return dropdown.addClass('visible').hide().css(css).fadeIn(200, () => {
      this.locked = false;
      this.body.one('click', this.hide);
    });
  }

  static hide() {
    if (Dropdown.locked) {
      return;
    }

    $('.dropdown.visible').removeClass('visible').fadeOut(200);
  }
}

Dropdown.locked = false;

Component.register(Dropdown);

export default Dropdown;
