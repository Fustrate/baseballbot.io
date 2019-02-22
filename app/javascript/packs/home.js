import BaseballBot from '../baseballbot';
import GameThreadsTable from '../baseballbot/game_threads_table';
import Routes from '../baseballbot/routes'; // eslint-disable-line import/no-unresolved

BaseballBot.start(new GameThreadsTable(document.body, Routes.root_path({ format: 'json' })));
