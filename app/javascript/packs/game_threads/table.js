import BaseballBot from '../../baseballbot';
import GameThreadsTable from '../../baseballbot/game_threads_table';

function getCurrentPageJson() {
  const pathname = window.location.pathname.replace(/\/+$/, '');

  return `${pathname}.json${window.location.search}`;
}

BaseballBot.start(new GameThreadsTable(document.body, getCurrentPageJson()));
