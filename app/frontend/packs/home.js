import BaseballBot from '../baseballbot';
import GameThreadsTable from '../baseballbot/game_threads_table';
import Routes from '../baseballbot/routes.js.erb';

BaseballBot.start(new GameThreadsTable(document.body, Routes.root_path({ format: 'json' })));
