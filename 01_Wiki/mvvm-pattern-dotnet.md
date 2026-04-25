---
title: MVVM Pattern in .NET
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [model-view-viewmodel, mvvm-basics]
---
# MVVM Pattern in .NET

The **Model-View-ViewModel (MVVM)** pattern is the architectural standard for WPF and other XAML-based frameworks (like WinUI and MAUI). It leverages **Data Binding** to minimize the need for "code-behind."

## The Core Triad

### 1. Model
- Represents the business logic and data.
- Agnostic of the UI.
- Examples: DTOs, Database entities, Agent state objects.

### 2. View
- The visual structure (XAML).
- Defines the layout and styling.
- Bound to the ViewModel via the `DataContext`.

### 3. ViewModel
- The "glue" between the Model and the View.
- Exposes data from the Model in a way the View can consume.
- Implements `INotifyPropertyChanged` to alert the View of data updates.
- Uses **Commands** (`ICommand`) to handle user actions (e.g., button clicks) without event handlers in the code-behind.

## Benefits for Development
- **Testability:** ViewModels can be unit-tested without launching a UI.
- **Maintainability:** Clear separation of concerns makes it easier to change the UI without breaking logic.
- **Designer Workflow:** Designers can work on the XAML while developers focus on the ViewModel logic.

## Application in Agentic Systems
MVVM is ideal for **Agent Observability**. The "Model" is the internal state of the agent, and the "ViewModel" translates that state into a human-readable format (e.g., status strings, progress percentages) that the XAML "View" can display in real-time.

---
## References
- [[ms-learn-wpf-overview]] (Source)
- [[wpf-xaml-and-data-binding]]
- [[wpf-moc]]
- [[hitl-ui-patterns]]
