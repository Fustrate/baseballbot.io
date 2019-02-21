import Fustrate from '.';
import GenericPage from './generic_page';
import Pagination from './components/pagination';

class GenericTable extends GenericPage {
  initialize() {
    super.initialize();

    this.tbody = this.table.querySelector('tbody');
    this.loadingRow = this.tbody.querySelector('tr.loading');
    this.noRecordsRow = this.tbody.querySelector('tr.no-records');

    this.reloadTable();
  }

  reloadTable() {} // eslint-disable-line class-methods-use-this

  createRow(item) {
    return this.constructor.updateRow(Fustrate.elementFromString(this.constructor.blankRow), item);
  }

  static sortRows(rows, sortFunction = () => {}) {
    const rowsWithSortOrder = rows.map(row => [sortFunction(row), row]);

    rowsWithSortOrder.sort((x, y) => {
      if (x[0] === y[0]) {
        return 0;
      }

      return x[0] > y[0] ? 1 : -1;
    });

    return rowsWithSortOrder.map(row => row[1]);
  }

  static updateRow(row) {
    return row;
  }

  reloadRows(rows, { sort } = { sort: null }) {
    if (this.loadingRow) {
      this.loadingRow.style.display = 'none';
    }

    if (rows) {
      this.tbody.querySelectorAll('tr:not(.no-records):not(.loading)').forEach((row) => {
        row.parentNode.removeChild(row);
      });

      (sort ? this.sortRows(rows, sort) : rows).forEach((row) => {
        this.tbody.appendChild(row);
      });
    }

    this.updated();
  }

  addRow(row) {
    this.tbody.appendChild(row);

    this.updated();
  }

  removeRow(row) {
    row.fadeOut(() => {
      row.remove();

      this.updated();
    });
  }

  updated() {
    if (!this.noRecordsRow) {
      return;
    }

    const hasRecords = this.tbody.querySelectorAll('tr:not(.no-records):not(.loading)').length > 0;

    if (hasRecords) {
      this.noRecordsRow.style.display = 'none';
    } else {
      this.noRecordsRow.style.display = '';
    }
  }

  getCheckedIds() {
    return [...this.tbody.querySelectorAll('td:first-child input:checked')].map(() => this.value);
  }

  // This should be fed a response from a JSON request for a paginated
  // collection.
  updatePagination(response) {
    if (!response.total_pages) {
      return;
    }

    this.pagination = new Pagination(response);

    const paginationHTML = this.pagination.generate();

    this.root.querySelectorAll('.pagination').forEach((pagination) => {
      pagination.outerHTML = paginationHTML;
    });
  }
}

export default GenericTable;
