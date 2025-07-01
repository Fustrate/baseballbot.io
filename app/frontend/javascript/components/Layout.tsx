import type { PropsWithChildren } from 'react';
import { Navbar, NavbarDivider, NavbarItem, NavbarSection, NavbarSpacer } from '@/catalyst/navbar';
import { Sidebar, SidebarBody, SidebarHeader, SidebarItem, SidebarSection } from '@/catalyst/sidebar';
import { StackedLayout } from '@/catalyst/stacked-layout';

const navItems = [
  { label: 'Game Threads', url: '/game_threads' },
  { label: 'Subreddits', url: '/subreddits' },
  { label: 'Gameday', url: '/gameday' },
];

export default function Layout({ children }: PropsWithChildren) {
  return (
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
      {children}
    </StackedLayout>
  );
}
