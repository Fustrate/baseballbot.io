// import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import { Disclosure, DisclosureButton, DisclosurePanel } from '@headlessui/react';
import { Bars3Icon, BellIcon, XMarkIcon } from '@heroicons/react/24/outline';
import { createRootRoute, HeadContent, Link, Outlet } from '@tanstack/react-router';
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools';
import PageHeader from '@/components/PageHeader';

export const Route = createRootRoute({
  component: RootComponent,
  notFoundComponent: () => {
    return <PageHeader color="red">404 - Page Not Found</PageHeader>;
  },
});

const user = {
  name: 'Tom Cook',
  email: 'tom@example.com',
  imageUrl:
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
};

const navigation = [
  { name: 'Dashboard', href: '#', current: true },
  { name: 'Team', href: '#', current: false },
  { name: 'Projects', href: '#', current: false },
  { name: 'Calendar', href: '#', current: false },
  { name: 'Reports', href: '#', current: false },
];

const userNavigation = [
  { name: 'Your Profile', href: '#' },
  { name: 'Settings', href: '#' },
  { name: 'Sign out', href: '#' },
];

function classNames(...classes: string[]) {
  return classes.filter(Boolean).join(' ');
}

function RootComponent() {
  return (
    <>
      <HeadContent />

      <div className="min-h-full">
        <Disclosure as="nav" className="bg-sky-900">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="flex h-16 items-center justify-between">
              <div className="flex items-center">
                <div className="hidden md:block">
                  <div className="flex items-baseline space-x-4">
                    <Link
                      to="/"
                      className="rounded-md px-3 py-2 font-medium text-slate-300 text-sm hover:bg-sky-800 hover:text-white [&.active]:bg-sky-950 [&.active]:text-white"
                    >
                      Home
                    </Link>
                    <Link
                      to="/game_threads"
                      className="rounded-md px-3 py-2 font-medium text-slate-300 text-sm hover:bg-sky-800 hover:text-white [&.active]:bg-sky-950 [&.active]:text-white"
                    >
                      Game Threads
                    </Link>
                    <Link
                      to="/subreddits"
                      className="rounded-md px-3 py-2 font-medium text-slate-300 text-sm hover:bg-sky-800 hover:text-white [&.active]:bg-sky-950 [&.active]:text-white"
                    >
                      Subreddits
                    </Link>
                    <Link
                      to="/gameday"
                      className="rounded-md px-3 py-2 font-medium text-slate-300 text-sm hover:bg-sky-800 hover:text-white [&.active]:bg-sky-950 [&.active]:text-white"
                    >
                      Gameday
                    </Link>
                  </div>
                </div>
              </div>
              {/* <div className="hidden md:block">
                <div className="ml-4 flex items-center md:ml-6">
                  <Menu as="div" className="relative ml-3">
                    <div>
                      <MenuButton className="relative flex max-w-xs items-center rounded-full bg-sky-800 text-sm text-white focus:outline-hidden focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800">
                        <span className="-inset-1.5 absolute" />
                        <span className="sr-only">Open user menu</span>
                        <img alt="" src={user.imageUrl} className="size-8 rounded-full" />
                      </MenuButton>
                    </div>
                    <MenuItems
                      transition
                      className="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black/5 transition focus:outline-hidden data-closed:scale-95 data-closed:transform data-closed:opacity-0 data-enter:duration-100 data-leave:duration-75 data-enter:ease-out data-leave:ease-in"
                    >
                      {userNavigation.map((item) => (
                        <MenuItem key={item.name}>
                          <a
                            href={item.href}
                            className="block px-4 py-2 text-sky-700 text-sm data-focus:bg-slate-100 data-focus:outline-hidden"
                          >
                            {item.name}
                          </a>
                        </MenuItem>
                      ))}
                    </MenuItems>
                  </Menu>
                </div>
              </div> */}
              <div className="-mr-2 flex md:hidden">
                {/* Mobile menu button */}
                <DisclosureButton className="group relative inline-flex items-center justify-center rounded-md bg-sky-800 p-2 text-slate-400 hover:bg-sky-700 hover:text-white focus:outline-hidden focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800">
                  <span className="-inset-0.5 absolute" />
                  <span className="sr-only">Open main menu</span>
                  <Bars3Icon aria-hidden="true" className="block size-6 group-data-open:hidden" />
                  <XMarkIcon aria-hidden="true" className="hidden size-6 group-data-open:block" />
                </DisclosureButton>
              </div>
            </div>
          </div>

          <DisclosurePanel className="md:hidden">
            <div className="space-y-1 px-2 pt-2 pb-3 sm:px-3">
              {navigation.map((item) => (
                <DisclosureButton
                  key={item.name}
                  as="a"
                  href={item.href}
                  aria-current={item.current ? 'page' : undefined}
                  className={classNames(
                    item.current ? 'bg-sky-900 text-white' : 'text-slate-300 hover:bg-sky-700 hover:text-white',
                    'block rounded-md px-3 py-2 font-medium text-base',
                  )}
                >
                  {item.name}
                </DisclosureButton>
              ))}
            </div>
            <div className="border-gray-700 border-t pt-4 pb-3">
              <div className="flex items-center px-5">
                <div className="shrink-0">
                  <img alt="" src={user.imageUrl} className="size-10 rounded-full" />
                </div>
                <div className="ml-3">
                  <div className="font-medium text-base text-white">{user.name}</div>
                  <div className="font-medium text-slate-400 text-sm">{user.email}</div>
                </div>
                <button
                  type="button"
                  className="relative ml-auto shrink-0 rounded-full bg-sky-800 p-1 text-slate-400 hover:text-white focus:outline-hidden focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800"
                >
                  <span className="-inset-1.5 absolute" />
                  <span className="sr-only">View notifications</span>
                  <BellIcon aria-hidden="true" className="size-6" />
                </button>
              </div>
              <div className="mt-3 space-y-1 px-2">
                {userNavigation.map((item) => (
                  <DisclosureButton
                    key={item.name}
                    as="a"
                    href={item.href}
                    className="block rounded-md px-3 py-2 font-medium text-base text-slate-400 hover:bg-sky-700 hover:text-white"
                  >
                    {item.name}
                  </DisclosureButton>
                ))}
              </div>
            </div>
          </DisclosurePanel>
        </Disclosure>

        <Outlet />

        <TanStackRouterDevtools />
      </div>
    </>
  );
}
