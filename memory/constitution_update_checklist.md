# Constitution Update Checklist

When amending the constitution (`/memory/constitution.md`), ensure all dependent documents are updated to maintain consistency.

## Templates to Update

### When adding/modifying ANY principle:

* [ ] `/templates/plan-template.md` - Update Constitution Check section
* [ ] `/templates/spec-template.md` - Update if requirements/scope affected
* [ ] `/templates/tasks-template.md` - Update if new task types needed
* [ ] `/.claude/commands/plan.md` - Update if planning process changes
* [ ] `/.claude/commands/tasks.md` - Update if task generation affected
* [ ] `/CLAUDE.md` - Update runtime development guidelines

### Principle-specific updates:

#### Principle I (Privacy-First):

* [ ] Ensure all templates emphasize no central servers, no mandatory login
* [ ] Update encryption and sync guidelines
* [ ] Add zero-analytics/tracking reminders

#### Principle II (Offline-First):

* [ ] Verify offline-first behavior in specs and plans
* [ ] Remove any hard dependency on internet connectivity
* [ ] Add reminders for offline testing

#### Principle III (Simplicity & Accessibility):

* [ ] Update templates with accessibility requirements
* [ ] Emphasize plain language and intuitive design
* [ ] Add examples for elder-friendly UI practices

#### Principle IV (Reliability & Data Integrity):

* [ ] Add backup/restore validation steps to templates
* [ ] Emphasize explicit user confirmation for sync overwrites
* [ ] Include migration/testing requirements for data safety

#### Principle V (Extensibility & Modularity):

* [ ] Add modular design guidelines to templates
* [ ] Include reminders for feature isolation
* [ ] Add extensibility evaluation checkpoints

## Validation Steps

1. **Before committing constitution changes:**

   * [ ] All templates reference new requirements
   * [ ] Examples updated to match new rules
   * [ ] No contradictions between documents

2. **After updating templates:**

   * [ ] Run through a sample implementation plan
   * [ ] Verify all constitution requirements addressed
   * [ ] Check that templates are self-contained (readable without constitution)

3. **Version tracking:**

   * [ ] Update constitution version number
   * [ ] Note version in template footers
   * [ ] Add amendment to constitution history

## Common Misses

Watch for these often-forgotten updates:

* Command documentation (`/commands/*.md`)
* Checklist items in templates
* Example code/commands
* Domain-specific variations (web vs mobile vs offline-first)
* Cross-references between documents

## Template Sync Status

Last sync check: 2025-09-09

* Constitution version: 1.0.0
* Templates aligned: ✅

---

*This checklist ensures the constitution's principles are consistently applied across all project documentation.*
