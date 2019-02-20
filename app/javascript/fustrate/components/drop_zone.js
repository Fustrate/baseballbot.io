import $ from 'jquery';

import Component from '../component';

// Allow files to be dropped onto an element
class DropZone extends Component {
  constructor(target, callback) {
    super();

    $(target)
      .off('.drop_zone')
      .on('dragover.drop_zone dragenter.drop_zone', false)
      .on('drop.drop_zone', (event) => {
        callback(event.originalEvent.dataTransfer.files);

        return false;
      });
  }
}

export default DropZone;
