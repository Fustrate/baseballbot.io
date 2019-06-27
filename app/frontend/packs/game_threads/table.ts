import BaseballBot from '../../javascript/baseballbot';
import GameThreadsTable from '../../javascript/baseballbot/game_threads_table';
import { gameThreadsPath } from '../../javascript/routes';

BaseballBot.start(new GameThreadsTable(gameThreadsPath({ format: 'json' })));
