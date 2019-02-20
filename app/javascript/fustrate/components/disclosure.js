import $ from 'jquery';

import Component from '../component';

class Disclosure extends Component {
  static initialize() {
    return $('body').on('click', '.disclosure-title', (event) => {
      const disclosure = $(event.currentTarget).closest('.disclosure');
      const isOpen = disclosure.hasClass('open');

      disclosure.toggleClass('open').trigger(`${(isOpen ? 'closed' : 'opened')}.disclosure`);

      return false;
    });
  }
}

Component.register(Disclosure);

export default Disclosure;
