# Sprint M7 Known Issues and Technical Debt

This document tracks known issues and technical debt from Sprint M7 implementation that should be addressed in future sprints.

## High Priority Issues

### 1. Hardcoded Project ID
**Location**: `lib/widgets/property_panel.dart` (lines 355, 387, 419)

**Issue**: The property panel uses a hardcoded project ID `'current-project-id'` when opening selection dialogs.

**Impact**: 
- Dialogs will not work correctly without actual project context
- Cannot fetch the correct list of entities/commands/read models for the current project

**Solution**:
- Implement a project context provider (e.g., `currentProjectProvider`)
- Pass actual project ID from the canvas screen or application state
- Update property panel to read project ID from provider

**Priority**: High - Required for production use

### 2. Print-based Error Logging
**Location**: `lib/services/canvas_definition_sync_service.dart` (lines 38, 58, 79, 114)

**Issue**: Using `print()` for error logging instead of a proper logging framework.

**Impact**:
- No log levels (debug, info, warning, error)
- Cannot control logging in production
- Difficult to filter and analyze logs
- Not following Dart/Flutter best practices

**Solution**:
- Replace `print()` with `dart:developer`'s `log()` function
- Or integrate a logging package like `logger` or `logging`
- Add proper log levels for different error scenarios

**Priority**: Medium - Important for maintainability

## Medium Priority Issues

### 3. Navigation Not Implemented
**Location**: `lib/widgets/property_panel.dart` (Linked definition cards)

**Issue**: The "Edit" buttons on linked definition cards show TODO comments but don't actually navigate to editors.

**Impact**:
- Users cannot quickly navigate from canvas element to detailed definition editor
- Reduces workflow efficiency

**Solution**:
- Implement navigation routes to:
  - Entity editor screen
  - Command designer screen
  - Read model designer screen
- Pass the definition ID as a route parameter
- Update button handlers to use Navigator.push()

**Priority**: Medium - Enhances user experience

### 4. No Automatic Sync Triggers
**Location**: `lib/services/canvas_definition_sync_service.dart`

**Issue**: Synchronization service exists but is not automatically called when elements are updated.

**Impact**:
- Manual sync required
- Potential for data inconsistency between canvas and definitions
- Users might forget to sync

**Solution**:
- Hook sync service into canvas controller's `updateElement` method
- Add debouncing to avoid excessive sync calls
- Implement sync status indicators in UI

**Priority**: Medium - Important for data consistency

## Low Priority Issues

### 5. No Unit Tests
**Location**: All new code

**Issue**: No unit tests for new dialogs, sync service, or property panel changes.

**Impact**:
- Harder to catch regressions
- Reduced confidence when refactoring
- Doesn't meet Sprint M9 coverage goals (>80%)

**Solution**:
- Add unit tests for:
  - Selection dialog logic
  - Sync service methods
  - Canvas controller link/unlink methods
- Add widget tests for dialogs
- Add integration tests for full workflow

**Priority**: Low - Can be addressed in Sprint M9

### 6. No Conflict Resolution
**Location**: `lib/services/canvas_definition_sync_service.dart`

**Issue**: Bidirectional sync doesn't handle conflicts when both canvas and definition are modified.

**Impact**:
- Last-write-wins behavior
- Potential data loss in concurrent editing scenarios
- No user notification of conflicts

**Solution**:
- Implement conflict detection
- Add timestamp-based or version-based conflict checking
- Show conflict resolution dialog to user
- Consider operational transformation or CRDT for future

**Priority**: Low - Edge case, can be addressed later

### 7. No Sync Status Indicators
**Location**: UI (property panel, canvas)

**Issue**: No visual feedback during synchronization.

**Impact**:
- Users don't know if sync is in progress
- No indication of sync success or failure
- Unclear if changes have been saved

**Solution**:
- Add loading spinners during sync
- Show success/error notifications
- Add sync status icon in property panel
- Consider adding "last synced" timestamp

**Priority**: Low - Nice to have

## Future Enhancements

### 8. Offline Support
Consider implementing offline support with local storage and sync queue for when backend is unavailable.

### 9. Batch Sync Optimization
Optimize batch sync to only sync changed elements instead of all linked elements.

### 10. Undo/Redo for Link Operations
Add undo/redo support for link/unlink operations.

## Mitigation Strategies

Until these issues are resolved, the following mitigations are in place:

1. **Hardcoded Project ID**: Documented in code comments with TODO markers. Will need manual update or environment-specific configuration.

2. **Print Logging**: Wrapped in try-catch blocks to prevent crashes. Errors are logged but operations continue (fault-tolerant design).

3. **Navigation**: Buttons show placeholder behavior (SnackBar messages). Framework is in place for easy future implementation.

4. **Manual Sync**: Sync service is available and can be called manually from application code. Documentation explains how to use it.

## Resolution Plan

### Sprint M8
- Address Issue #1 (Hardcoded Project ID) - Required for IR v2.0 integration
- Address Issue #2 (Error Logging) - Quick win for code quality

### Sprint M9
- Address Issue #3 (Navigation Implementation)
- Address Issue #4 (Automatic Sync Triggers)
- Address Issue #5 (Unit Tests) - Required for Sprint M9 goals
- Address Issue #7 (Sync Status Indicators)

### Post-M9 (as needed)
- Address Issue #6 (Conflict Resolution) - Based on user feedback
- Consider Issue #8-10 (Future Enhancements) - Based on product priorities

---

**Document Version**: 1.0  
**Created**: 2025-12-08  
**Last Updated**: 2025-12-08  
**Status**: Active tracking
