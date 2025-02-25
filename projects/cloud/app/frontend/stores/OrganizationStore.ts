import { ApolloClient } from '@apollo/client';
import { makeAutoObservable, runInAction } from 'mobx';
import {
  ChangeUserRoleDocument,
  OrganizationQuery,
  OrganizationDocument,
  Role,
  RemoveUserDocument,
  InviteUserDocument,
} from '../graphql/types';

class OrganizationStore {
  organization: OrganizationQuery['organization'];

  client: ApolloClient<object>;

  constructor(client: ApolloClient<object>) {
    this.client = client;
    makeAutoObservable(this);
  }

  get members() {
    if (!this.organization) {
      return [];
    }
    return [...this.users, ...this.admins].sort(
      (first, second) => 0 - (first.name > second.name ? -1 : 1),
    );
  }

  get users() {
    if (!this.organization) {
      return [];
    }
    return this.organization.users.map((user) => {
      return {
        id: user.id,
        email: user.email,
        name: user.account.name,
        avatarUrl: user.avatarUrl ?? undefined,
        role: Role.User,
      };
    });
  }

  get admins() {
    if (!this.organization) {
      return [];
    }
    return this.organization.admins.map((user) => {
      return {
        id: user.id,
        email: user.email,
        name: user.account.name,
        avatarUrl: user.avatarUrl ?? undefined,
        role: Role.Admin,
      };
    });
  }

  async removeMember(memberId: string) {
    if (!this.organization) {
      return;
    }
    await this.client.mutate({
      mutation: RemoveUserDocument,
      variables: {
        input: {
          organizationId: this.organization.id,
          userId: memberId,
        },
      },
    });
    runInAction(() => {
      if (!this.organization) {
        return;
      }
      this.organization.users = this.organization.users.filter(
        (user) => user.id !== memberId,
      );
      this.organization.admins = this.organization.admins.filter(
        (user) => user.id !== memberId,
      );
    });
  }

  async changeUserRole(memberId: string, newRole: Role) {
    if (!this.organization) {
      return;
    }
    await this.client.mutate({
      mutation: ChangeUserRoleDocument,
      variables: {
        input: {
          userId: memberId,
          organizationId: this.organization.id,
          role: newRole,
        },
      },
    });
    runInAction(() => {
      if (!this.organization) {
        return;
      }
      switch (newRole) {
        case Role.User:
          const adminIndex = this.organization.admins
            .map((admin) => admin.id)
            .indexOf(memberId);
          this.organization.users.push(
            this.organization.admins[adminIndex],
          );
          this.organization.admins.splice(adminIndex, 1);
          break;
        case Role.Admin:
          const userIndex = this.organization.users
            .map((user) => user.id)
            .indexOf(memberId);
          this.organization.admins.push(
            this.organization.users[userIndex],
          );
          this.organization.users.splice(userIndex, 1);
          break;
      }
    });
  }

  async load(organizationName: string) {
    const { data } = await this.client.query({
      query: OrganizationDocument,
      variables: { name: organizationName },
    });
    runInAction(() => {
      this.organization = data.organization;
    });
  }

  async inviteMember(memberEmail: string) {
    if (!this.organization) {
      return;
    }
    await this.client.mutate({
      mutation: InviteUserDocument,
      variables: {
        input: {
          inviteeEmail: memberEmail,
          organizationId: this.organization.id,
        },
      },
    });
  }
}

export default OrganizationStore;
