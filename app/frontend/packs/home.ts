import BaseballBot from '../javascript/baseballbot';
import GameThreadsTable from '../javascript/baseballbot/game_threads_table';
import { rootPath } from '../javascript/routes';

BaseballBot.start(new GameThreadsTable(rootPath({ format: 'json' })));
