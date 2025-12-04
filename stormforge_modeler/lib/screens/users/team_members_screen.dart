import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stormforge_modeler/models/team_member_model.dart';
import 'package:stormforge_modeler/services/providers.dart';

/// Provider for team members list.
final teamMembersProvider = FutureProvider.autoDispose.family<List<TeamMember>, String>(
  (ref, projectId) async {
    final teamMemberService = ref.watch(teamMemberServiceProvider);
    return await teamMemberService.listTeamMembers(projectId);
  },
);

/// Team members management screen.
class TeamMembersScreen extends ConsumerStatefulWidget {
  const TeamMembersScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  ConsumerState<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends ConsumerState<TeamMembersScreen> {
  @override
  Widget build(BuildContext context) {
    final teamMembersAsync = ref.watch(teamMembersProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
      ),
      body: teamMembersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No team members yet'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showAddMemberDialog(context),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Member'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(member.userId[0].toUpperCase()),
                  ),
                  title: Text('User ${member.userId.substring(0, 8)}...'),
                  subtitle: Text(member.role.displayName),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'change_role',
                        child: ListTile(
                          leading: Icon(Icons.swap_horiz),
                          title: Text('Change Role'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: ListTile(
                          leading: Icon(Icons.remove_circle, color: Colors.red),
                          title: Text('Remove', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'change_role':
                          _showChangeRoleDialog(context, member);
                          break;
                        case 'remove':
                          _showRemoveMemberDialog(context, member);
                          break;
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading team members: $error'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.refresh(teamMembersProvider(widget.projectId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final userIdController = TextEditingController();
    TeamRole selectedRole = TeamRole.editor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Team Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  hintText: 'Enter user ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TeamRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: TeamRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.displayName),
                        Text(
                          role.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRole = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final teamMemberService = ref.read(teamMemberServiceProvider);
                try {
                  await teamMemberService.addTeamMember(
                    projectId: widget.projectId,
                    userId: userIdController.text.trim(),
                    role: selectedRole,
                  );
                  ref.invalidate(teamMembersProvider(widget.projectId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Member added')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add member: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, TeamMember member) {
    TeamRole selectedRole = member.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Role'),
          content: DropdownButtonFormField<TeamRole>(
            value: selectedRole,
            decoration: const InputDecoration(
              labelText: 'New Role',
              border: OutlineInputBorder(),
            ),
            items: TeamRole.values.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role.displayName),
                    Text(
                      role.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedRole = value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final teamMemberService = ref.read(teamMemberServiceProvider);
                try {
                  await teamMemberService.updateTeamMember(
                    projectId: widget.projectId,
                    userId: member.userId,
                    role: selectedRole,
                  );
                  ref.invalidate(teamMembersProvider(widget.projectId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Role updated')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update role: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, TeamMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: const Text(
          'Are you sure you want to remove this team member? They will lose access to the project.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              final teamMemberService = ref.read(teamMemberServiceProvider);
              try {
                await teamMemberService.removeTeamMember(
                  projectId: widget.projectId,
                  userId: member.userId,
                );
                ref.invalidate(teamMembersProvider(widget.projectId));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Member removed')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove member: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
