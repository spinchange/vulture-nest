---
title: TypeScript Classes
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ts-classes, class-inheritance, member-visibility, abstract-classes]
---
# TypeScript Classes

TypeScript offers full support for the ES2015 `class` keyword, adding type annotations and specific syntax for expressing relationships between classes and other types.

## Class Members
* **Fields**: Public writeable properties. Can have initializers and be marked as `readonly`.
* **Constructors**: Similar to functions; can have parameters, defaults, and overloads. Note: They cannot have type parameters or return type annotations.
* **Methods**: Functions defined on a class. Accessing fields/methods within a body requires `this.`.
* **Accessors**: `get` and `set` blocks. If `get` exists without `set`, the property is `readonly`.

## Class Heritage
* **`implements` Clause**: Ensures a class satisfies an `interface`. This is a check only and doesn't change the class's type or inference.
* **`extends` Clause**: Inherit from a base class. Derived classes must be subtypes of their base classes.

## Member Visibility
* **`public` (default)**: Accessible from anywhere.
* **`protected`**: Accessible only within the class and its subclasses.
* **`private`**: Accessible only within the class itself. Note: This is "soft private" and erased at runtime.
* **`#` (JS Private Fields)**: Hard private at runtime; not accessible via bracket notation or in subclasses.

## Static Members
Belong to the class constructor object rather than instances. Certain names (like `name`, `length`, `call`) are reserved.

## Generic Classes
Classes can have type parameters (e.g., `class Box<T>`). Static members cannot refer to the class's type parameters.

## The `this` Type
* **`this` at Runtime**: Use arrow functions to preserve `this` context or declare a `this` parameter in methods for static enforcement.
* **`this` Type**: Dynamically refers to the type of the current class (useful for fluent APIs).
* **`this`-based Type Guards**: Use `this is Type` as a return type for methods to perform narrowing on the instance.

## Abstract Classes
Defined with the `abstract` keyword. Cannot be directly instantiated and may contain abstract methods/fields that must be implemented by concrete subclasses.

---
## References
* Source: `00_Raw/typescript-handbook.md`
* [[typescript-moc]]
* [[typescript-objects]]
* [[typescript-generics]]
