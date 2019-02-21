import $ from 'jquery';

import Component from '../component';

class Dropdown extends Component {
  static initialize() {
    $(document.body).on('click.dropdowns', '.has-dropdown', this.open);
  }

  static open(event) {
    let left;
    let right;
    let top;

    Dropdown.hide();

    const button = event.currentTarget;
    const dropdown = button.nextElementSibling;

    Dropdown.locked = true;

    if (button.offsetTop > (Dropdown.body.height() / 2)) {
      top = button.offsetTop - dropdown.offsetHeight - 2;
    } else {
      top = button.offsetTop + button.offsetHeight + 2;
    }

    if (button.offsetLeft > (Dropdown.body.width() / 2)) {
      left = 'inherit';
      right = Dropdown.body.width() - button.offsetLeft - button.offsetWidth;
    } else {
      right = 'inherit';
      left = button.offsetLeft;
    }

    Dropdown.showDropdown(dropdown, { left, top, right });

    return false;
  }

  static showDropdown(dropdown, css) {
    dropdown.classList.add('visible');

    dropdown.style.display = 'none';
    dropdown.style.left = css.left;
    dropdown.style.top = css.top;
    dropdown.style.right = css.right;

    $(dropdown).fadeIn(200, () => {
      Dropdown.locked = false;
      Dropdown.body.one('click', Dropdown.hide);
    });
  }

  static hide() {
    if (Dropdown.locked) {
      return;
    }

    const visibleDropdown = document.querySelector('.dropdown.visible');

    visibleDropdown.classList.remove('visible');

    $(visibleDropdown).fadeOut(200);
  }
}

Dropdown.locked = false;

Component.register(Dropdown);

export default Dropdown;
