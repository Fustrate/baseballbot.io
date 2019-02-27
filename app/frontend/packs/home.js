import BaseballBot from '../javascript/baseballbot';
import GameThreadsTable from '../javascript/baseballbot/game_threads_table';
import Routes from '../javascript/baseballbot/routes.js.erb';

BaseballBot.start(new GameThreadsTable(document.body, Routes.root_path({ format: 'json' })));
