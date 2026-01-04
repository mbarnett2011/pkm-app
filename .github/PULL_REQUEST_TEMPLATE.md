# Pull Request Template

Thank you for contributing to pkm-app! Please fill out this template to help us review your changes.

## Description

**What does this PR do?**
Provide a clear description of the changes in this pull request.

**Why is this change needed?**
Explain the problem this PR solves or the feature it adds.

**Related Issue**
Closes #[issue number] (if applicable)

---

## Type of Change

Please check the relevant option:

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)
- [ ] Performance improvement
- [ ] Test coverage improvement

---

## Roadmap Phase

Which phase does this PR relate to?

- [ ] Phase 1: Foundation & Menu Bar UI
- [ ] Phase 2: Data Models & File Operations
- [ ] Phase 3: Assistant Hub Integration
- [ ] Phase 4: Goal Hierarchy & Timeline
- [ ] Phase 5: Advanced Features
- [ ] N/A (Documentation, tooling, etc.)

---

## Changes Made

**Modified Files:**
List key files changed and why.

**New Files:**
List new files added and their purpose.

**Deleted Files:**
List any files removed and why.

---

## Testing

**How was this tested?**
- [ ] Unit tests added/updated
- [ ] Manual testing performed
- [ ] Tested with real PKM vault
- [ ] Tested on macOS [version]

**Test Coverage:**
- [ ] All new code has tests
- [ ] Existing tests still pass (`swift test`)
- [ ] No decrease in test coverage

**Manual Testing Steps:**
1. [Step 1]
2. [Step 2]
3. [Expected result]

---

## PKM Vault Compatibility

**Does this change affect how the app interacts with the PKM vault?**
- [ ] Yes (explain below)
- [ ] No

**If yes, describe:**
- Does it read new types of files?
- Does it write to vault files?
- Does it preserve YAML frontmatter?
- Does it maintain append-only semantics?

**Example Vault Structure:**
If relevant, provide an example of vault files this PR works with.

---

## Architecture Checklist

**Please confirm:**
- [ ] Follows MVVM pattern
- [ ] File I/O uses Swift actors (if applicable)
- [ ] No blocking operations on main thread
- [ ] Uses `async/await` instead of completion handlers
- [ ] Follows Swift API Design Guidelines
- [ ] Code is documented with DocC-style comments
- [ ] No force-unwraps (`!`) without clear justification
- [ ] No hardcoded paths (uses configuration or user defaults)

---

## Code Quality

**Please confirm:**
- [ ] Code builds without warnings (`swift build`)
- [ ] All tests pass (`swift test`)
- [ ] No new compiler warnings introduced
- [ ] Code follows existing style conventions
- [ ] No debug print statements left in code
- [ ] Error handling is appropriate and informative

---

## Documentation

**Documentation updated:**
- [ ] Code comments added/updated
- [ ] README.md updated (if public API changed)
- [ ] DEVELOPMENT.md updated (if dev setup changed)
- [ ] ROADMAP.md updated (if phase status changed)
- [ ] DocC documentation added for public APIs

---

## Screenshots (if applicable)

If this PR changes UI, please include before/after screenshots:

**Before:**
[Screenshot or N/A]

**After:**
[Screenshot or N/A]

---

## Breaking Changes

**Does this PR introduce breaking changes?**
- [ ] Yes (explain below)
- [ ] No

**If yes, describe:**
- What breaks?
- Migration path for users/developers?
- Deprecation warnings added?

---

## Performance Impact

**Does this PR affect performance?**
- [ ] Yes (explain below)
- [ ] No
- [ ] Unknown

**If yes, describe:**
- What's the performance impact?
- Have you benchmarked it?
- Any optimizations considered?

---

## Additional Notes

Any additional context, concerns, or questions for reviewers?

---

## Checklist

**Before submitting, please ensure:**
- [ ] I have read the DEVELOPMENT.md guide
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code where necessary
- [ ] I have updated relevant documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix/feature works
- [ ] New and existing tests pass locally
- [ ] I have checked my code builds in both debug and release configurations

---

## Reviewer Notes

**For reviewers:**
- Does this PR align with the roadmap?
- Is the architecture sound?
- Are tests comprehensive?
- Is documentation clear?
- Any security or data loss concerns (especially for file I/O)?
