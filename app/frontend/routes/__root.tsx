// import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import { createRootRoute, HeadContent, Outlet } from '@tanstack/react-router';
import {
  Dropdown,
  DropdownButton,
  DropdownDivider,
  DropdownItem,
  DropdownLabel,
  DropdownMenu,
} from '@/catalyst/dropdown';
// Bun double exports a function from this file
// import { TanStackRouterDevtools } from '@tanstack/react-router-devtools';
import { Heading } from '@/catalyst/heading';
import { Navbar, NavbarDivider, NavbarItem, NavbarSection, NavbarSpacer } from '@/catalyst/navbar';
import { Sidebar, SidebarBody, SidebarHeader, SidebarItem, SidebarSection } from '@/catalyst/sidebar';
import { StackedLayout } from '@/catalyst/stacked-layout';
import { AuthProvider, useAuth } from '@/hooks/useAuth';

export const Route = createRootRoute({
  component: () => (
    <AuthProvider>
      <RootComponent />
    </AuthProvider>
  ),
  notFoundComponent: () => {
    return <Heading color="red">404 - Page Not Found</Heading>;
  },
});

const navItems = [
  { label: 'Game Threads', url: '/game_threads' },
  { label: 'Subreddits', url: '/subreddits' },
  { label: 'Gameday', url: '/gameday' },
];

function UserMenu() {
  const { isLoggedIn, user } = useAuth();

  if (!isLoggedIn || !user) {
    return (
      <NavbarItem href="/sign_in">
        <i className="fas fa-sign-in-alt mr-2" />
        Sign In
      </NavbarItem>
    );
  }

  const handleSignOut = () => {
    fetch('/sign_out', { method: 'DELETE' })
      .then(() => {
        window.location.href = '/';
      })
      .catch((error) => {
        console.error('Sign out failed:', error);
      });
  };

  return (
    <Dropdown>
      <DropdownButton as={NavbarItem}>{user.username}</DropdownButton>
      <DropdownMenu className="min-w-64" anchor="bottom end">
        <DropdownItem>
          <i className="fas fa-user mr-2" />
          <DropdownLabel>u/{user.username}</DropdownLabel>
        </DropdownItem>
        <DropdownDivider />
        <DropdownItem onClick={handleSignOut}>
          <i className="fas fa-sign-out-alt mr-2" />
          <DropdownLabel>Sign out</DropdownLabel>
        </DropdownItem>
      </DropdownMenu>
    </Dropdown>
  );
}

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

            <NavbarSection>
              <UserMenu />
            </NavbarSection>
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
