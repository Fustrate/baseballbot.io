import { getCurrentPageJson } from '@fustrate/rails/dist/js/ajax';

import BaseballBot from '../../javascript/baseballbot';
import GameThreadsTable from '../../javascript/baseballbot/game_threads_table';

BaseballBot.start(new GameThreadsTable(getCurrentPageJson()));
