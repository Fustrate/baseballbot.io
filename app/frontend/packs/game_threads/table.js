import BaseballBot from '../../javascript/baseballbot';
import GameThreadsTable from '../../javascript/baseballbot/game_threads_table';

function getCurrentPageJson() {
  const pathname = window.location.pathname.replace(/\/+$/, '');

  return `${pathname}.json${window.location.search}`;
}

BaseballBot.start(new GameThreadsTable(document.body, getCurrentPageJson()));
