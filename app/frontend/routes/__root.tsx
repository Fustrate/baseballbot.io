// import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import { createRootRoute, HeadContent, Outlet } from '@tanstack/react-router';
// Bun double exports a function from this file
// import { TanStackRouterDevtools } from '@tanstack/react-router-devtools';
import { Heading } from '@/catalyst/heading';
import { Navbar, NavbarDivider, NavbarItem, NavbarSection, NavbarSpacer } from '@/catalyst/navbar';
import { Sidebar, SidebarBody, SidebarHeader, SidebarItem, SidebarSection } from '@/catalyst/sidebar';
import { StackedLayout } from '@/catalyst/stacked-layout';

export const Route = createRootRoute({
  component: RootComponent,
  notFoundComponent: () => {
    return <Heading color="red">404 - Page Not Found</Heading>;
  },
});

const navItems = [
  { label: 'Game Threads', url: '/game_threads' },
  { label: 'Subreddits', url: '/subreddits' },
  { label: 'Gameday', url: '/gameday' },
];

function RootComponent() {
  return (
    <>
      <HeadContent />

      <StackedLayout
        navbar={
          <Navbar>
            <NavbarItem href="/" className="max-lg:hidden">
              <i className="fas fa-baseball" />
              Baseballbot.io
            </NavbarItem>

            <NavbarDivider className="max-lg:hidden" />

            <NavbarSection className="max-lg:hidden">
              {navItems.map(({ label, url }) => (
                <NavbarItem key={label} href={url}>
                  {label}
                </NavbarItem>
              ))}
            </NavbarSection>

            <NavbarSpacer />
          </Navbar>
        }
        sidebar={
          <Sidebar>
            <SidebarHeader>
              <SidebarItem href="/" className="lg:mb-2.5">
                <i className="fas fa-baseball" />
                Baseballbot.io
              </SidebarItem>
            </SidebarHeader>
            <SidebarBody>
              <SidebarSection>
                {navItems.map(({ label, url }) => (
                  <SidebarItem key={label} href={url}>
                    {label}
                  </SidebarItem>
                ))}
              </SidebarSection>
            </SidebarBody>
          </Sidebar>
        }
      >
        <Outlet />

        {/* <TanStackRouterDevtools /> */}
      </StackedLayout>
    </>
  );
}
