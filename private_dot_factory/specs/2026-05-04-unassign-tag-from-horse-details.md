## Plan — Unassign tag from horse details page

### Backend (`equi-spro-api`)

**1. New endpoint**: `DELETE /api/v1/horses/:id/tags/:tag`
- File: `src/horse/horse.controller.ts`
- Standard Swagger decorators (`@ApiOperation`, `@ApiOkResponse` with `HorseDto`, `@ApiBadRequestResponse` for `HORSE_NOT_FOUND`)
- `:tag` path param must be URL-decoded server-side (tags may contain digits/dashes; the workout flow stores raw chip-number strings)

```ts
@Delete(':id/tags/:tag')
@ApiOperation({ summary: 'Unassign a tag from a horse.' })
@ApiOkResponse({ description: 'Tag unassigned.', type: HorseDto })
removeTag(@Param('id') id: string, @Param('tag') tag: string) {
  return this.horseService.removeTag(id, decodeURIComponent(tag));
}
```

**2. Service method** in `src/horse/horse.service.ts`:
- Fetch horse with org-level filter (multi-tenant invariant from AGENTS.md)
- Throw `BadRequestException(HorseValidationError.HORSE_NOT_FOUND)` if missing
- Filter `tags` (strict equality — matches the chip exactly as shown in the UI)
- Persist via `horse.update({ tags })`, return new `HorseDto`
- Idempotent: if tag isn't present, no-op + return current dto (logged at debug level via `AppLoggerService`)

**3. E2E test**: `src/horse/__tests__/horse-remove-tag.e2e-spec.ts`
- Happy path removes one tag, leaves others intact
- Removing a tag that doesn't exist returns 200 with unchanged tags
- 400 when horse not found
- Org isolation: another org cannot remove tags from a foreign horse

**4. Run** `pnpm run lint` and `pnpm run test:e2e:local:file horse-remove-tag.e2e-spec.ts`

### Mobile (`equi-spro-app`)

**5. API client** (`lib/src/data/services/client_api_service.dart`):
```dart
AsyncResultS<HorseDto> unassignHorseTag(String horseId, String tag) {
  final encoded = Uri.encodeComponent(tag);
  return _delete<HorseDto>('/api/v1/horses/$horseId/tags/$encoded', ...);
}
```

**6. Repository** (`lib/src/data/repositories/horse_repository.dart`):
- `unassignTag(String horseId, String tag)` → calls service, returns `AsyncResultS<HorseEntity>`, updates cached `horseDetails` on success

**7. ViewModel** (`lib/src/ui/horses/viewmodel/horses_viewmodel.dart`):
- `OperationStatus unassignTagStatus = OperationStatus.idle`
- `Future<void> unassignTag(String horseId, String tag)` — sets loading, calls repo, sets success/error, calls `notifyListeners()`. On success, also calls `fetchHorseDetails(horseId)` so the detail row re-renders.

**8. UI changes** (`lib/src/ui/horses/view/horse_details_page.dart`):
- Replace the current single-row `DetailRowTile` for tags (lines 255–261) with a custom row: label "Alternative Tags" on the left, a `Wrap` of `Chip` widgets on the right — each chip has a `deleteIcon` and `onDeleted`.
- `onDeleted` triggers `showDialog` with `DSModalPopUp` (same component used by Delete Horse / Unassign Horse) → on confirm: `viewmodel.unassignTag(widget.horseId, tag)`
- Add an `unassignTagListener` mirroring the existing `_deletionListerner` / `_workoutsListener` pattern: success → `showSuccessSnackBar(l10n.horsesManagementUnassignTagSuccess)`; error → `showErrorSnackBar(ErrorHandlerUsecase.call(l10n, error))`

**9. Localization** — new keys in `lib/l10n/en/horses_management_en.arb`:
- `horsesManagementUnassignTag` → "Unassign Tag"
- `horsesManagementUnassignTagConfirm` → "Are you sure you want to unassign tag [[Tag]] from this horse?"
- `horsesManagementUnassignTagSuccess` → "Tag unassigned successfully"
Run `flutter pub get` to regenerate `app_localizations*.dart`.

**10. Test stubs** (per project AGENTS.md — stubs only, bodies on request):
- `test/src/ui/horses/viewmodel/horses_viewmodel_test.dart` — group `Unassign Tag`: success, repo error, loading state, notifies listeners, refreshes details after success
- `test/src/ui/horses/view/horse_details_page_test.dart` — widget stubs: renders chip per tag, delete icon shows confirmation modal, tapping confirm calls viewmodel

**11. Verification**: `dart format .`, `flutter analyze`, `flutter test`

### Out of scope
- Adding tags from the app (kept backend-only via workout assignment, per your answer)
- Editing tag value in place
- Bulk tag operations