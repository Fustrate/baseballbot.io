import $ from 'jquery';

import GenericPage from './generic_page';
import Pagination from './components/pagination';

class GenericTable extends GenericPage {
  initialize() {
    super.initialize();

    this.tbody = $('tbody', this.table);

    this.reloadTable();
  }

  reloadTable() {} // eslint-disable-line class-methods-use-this

  createRow(item) {
    return this.constructor.updateRow($(this.constructor.blankRow), item);
  }

  static sortRows(rows, sortFunction = () => {}) {
    const rowsWithSortOrder = rows.map(row => [sortFunction(row), row]);

    rowsWithSortOrder.sort((x, y) => {
      if (x[0] === y[0]) {
        return 0;
      }

      if (x[0] > y[0]) {
        return 1;
      }

      return -1;
    });

    return rowsWithSortOrder.map(row => row[1]);
  }

  static updateRow(row) {
    return row;
  }

  reloadRows(rows, { sort } = { sort: null }) {
    $('tr.loading', this.tbody).hide();

    if (rows) {
      $('tr:not(.no-records):not(.loading)', this.tbody).remove();

      this.tbody.append(sort ? this.sortRows(rows, sort) : rows);
    }

    this.updated();
  }

  addRow(row) {
    this.tbody.append(row);

    this.updated();
  }

  removeRow(row) {
    row.fadeOut(() => {
      row.remove();

      this.updated();
    });
  }

  updated() {
    $('tr.no-records', this.tbody)
      .toggle($('tr:not(.no-records):not(.loading)', this.tbody).length < 1);
  }

  getCheckedIds() {
    return $('td:first-child input:checked', this.tbody).map(() => this.value);
  }

  // This should be fed a response from a JSON request for a paginated
  // collection.
  updatePagination(response) {
    if (!response.total_pages) {
      return;
    }

    this.pagination = new Pagination(response);

    $('.pagination', this.root).replaceWith(this.pagination.generate());
  }
}

export default GenericTable;
