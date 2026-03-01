# Codification Signals

> Patterns to detect in conversations that indicate knowledge should be captured as durable context. Used by the codify-knowledge skill to identify what to codify.

## Signal Categories

### 1. Repeated Explanations
**Detection pattern**: The same concept, workflow, or constraint has been explained in 2+ separate conversation turns or sessions.
**Indicators**:
- "As I mentioned earlier..."
- "Like we discussed before..."
- "This is the same issue as..."
- Explaining the same API, pattern, or constraint multiple times
- Re-describing the same architectural decision

**Urgency**: High — repeated explanations waste tokens and indicate missing context.

### 2. Debugging Breakthroughs
**Detection pattern**: Significant debugging effort (multiple failed attempts) leading to a root cause discovery.
**Indicators**:
- Multiple hypothesis-test cycles before finding the issue
- "The actual problem was..."
- "It turns out that..."
- Non-obvious root causes (the symptom was misleading)
- Environment-specific issues (works locally, fails in CI)

**Urgency**: High — debugging insights prevent re-discovery of known issues.

### 3. Architecture Decisions
**Detection pattern**: A design choice was made between multiple valid approaches.
**Indicators**:
- "We should use X instead of Y because..."
- "The trade-off here is..."
- Choosing between patterns, libraries, or approaches
- Decisions about data flow, component boundaries, or API design

**Urgency**: Medium — prevents revisiting settled decisions.

### 4. Gotchas & Non-Obvious Constraints
**Detection pattern**: A constraint or behavior that isn't obvious from the code alone.
**Indicators**:
- "Watch out for..."
- "This is counterintuitive, but..."
- "Don't do X because Y will happen"
- Framework quirks, edge cases, ordering dependencies
- "I wouldn't have expected that" moments

**Urgency**: Medium-High — gotchas are the most common source of repeated mistakes.

### 5. New Conventions
**Detection pattern**: A pattern is established that should be followed consistently going forward.
**Indicators**:
- "From now on, let's always..."
- "The pattern for this is..."
- "Use this approach when..."
- Establishing naming conventions, file organization, or API patterns

**Urgency**: Medium — conventions prevent inconsistency.

### 6. Routing Discoveries
**Detection pattern**: A file pattern or keyword consistently needs specialized handling.
**Indicators**:
- "Whenever we work on files in X, we need to..."
- "For these types of changes, use agent/skill Y"
- Repeated context-switching to load specific documentation

**Urgency**: Low-Medium — improves routing efficiency over time.

## Signal Strength

| Strength | Criteria | Action |
|----------|----------|--------|
| Strong | Repeated 2+ times, caused significant time waste, or is a blocker | Codify immediately |
| Moderate | Happened once but clearly reusable knowledge | Propose codification |
| Weak | Might be useful but is speculative or project-specific edge case | Note for later, don't codify yet |

## Anti-Patterns (Do NOT Codify)

- **Temporary state**: "The server is currently down" — not durable knowledge
- **Obvious facts**: Things any developer would know from reading the code
- **Personal preferences**: Unless adopted as a team convention
- **Speculative patterns**: "This might be useful someday" — wait for the second occurrence
- **Session-specific context**: Current task details, in-progress work states
