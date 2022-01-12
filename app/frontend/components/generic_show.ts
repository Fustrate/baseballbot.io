import { GenericPage, autorefresh } from '@fustrate/rails';

export { autorefresh };

export default abstract class GenericShow extends GenericPage {
  public override refresh(): void {
    this.callDecoratedMethods('$autorefresh');
  }
}
