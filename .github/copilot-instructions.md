# Salesforce Project Instructions

## Apex Rules

- Write bulkified Apex.
- Never use SOQL inside loops.
- Never use DML inside loops.
- Prefer Set and Map for bulk processing.
- Use meaningful variable and method names.
- Use `with sharing` unless there is a specific reason not to.

## Testing Rules

- Create tests for new functionality.
- Use Test.startTest() and Test.stopTest() when appropriate.
- Use meaningful System.assert statements.
- Test positive and negative scenarios.
- Test bulk scenarios where applicable.

## Coding Approach

- Understand existing code before modifying it.
- Reuse existing classes and methods where appropriate.
- Don't create duplicate functionality.
- Explain important changes before implementing them.