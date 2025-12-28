# Feature Request: Enhanced Rerack Animation

**Priority:** Medium  
**Status:** Planned  
**Estimated Effort:** 45-55 minutes  
**Created:** 2025-12-28

## Description
Transform the current simple fade-in rack animation into a dynamic 3-phase sequence when rerack is triggered.

## User Story
As a player, when I complete a double-sack, I want to see an exciting visual sequence where balls grey out, fade away, then fly in randomly from off-screen to their rack positions while the "Re-rack!" splash appears, so the rerack feels more satisfying and dynamic.

## Acceptance Criteria
- [ ] Phase 1: All active balls grey out over 200ms
- [ ] Phase 2: Grey balls fade to opacity 0 over 300ms
- [ ] Phase 3: Balls fly in from random off-screen positions over 1200ms
- [ ] Each ball uses curved path with Curves.easeOutBack
- [ ] Staggered timing (50ms delay between each ball)
- [ ] "Re-rack!" splash appears during fade-out phase
- [ ] Animation is smooth on production devices (60fps target)

## Technical Notes
See detailed specification: [rerack_animation_spec.md](../rerack_animation_spec.md)

## Related Files
- `lib/screens/game_screen.dart` - Animation controller and ball rendering
- `lib/models/game_state.dart` - Trigger rerack event
- `lib/widgets/re_rack_overlay.dart` - Splash timing coordination

## Dependencies
None

## Labels
`enhancement`, `animation`, `ux-polish`
