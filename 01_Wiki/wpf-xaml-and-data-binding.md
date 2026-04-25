---
title: WPF XAML and Data Binding
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [xaml-basics, wpf-binding]
---
# WPF XAML and Data Binding

**Windows Presentation Foundation (WPF)** uses a declarative approach to UI development, separating the visual structure from the application logic.

## XAML (Extensible Application Markup Language)
- **Declarative UI:** Define elements (buttons, grids, lists) using an XML-based syntax.
- **Separation of Concerns:** UI is defined in `.xaml` files, while logic resides in `.xaml.cs` (code-behind) or a ViewModel.
- **Resources:** Styles, templates, and constants can be defined in `ResourceDictionaries` for reuse.

## Data Binding Engine
The core of WPF's power lies in its ability to automatically synchronize the UI with underlying data.

- **Binding Expression:** `{Binding Path=PropertyName}`.
- **DataContext:** The object from which properties are retrieved.
- **Update Triggers:**
    - **OneWay:** Source to View.
    - **TwoWay:** Source to View and View to Source (common for input fields).
    - **OneTime:** Source to View once during initialization.
- **INotifyPropertyChanged:** The interface required for the UI to "listen" for property changes in the data source.

## Dependency Properties
Unlike standard C# properties, **Dependency Properties** are registered with the WPF property system, enabling advanced features like:
- Data binding.
- Animation.
- Styling.
- Default value inheritance through the element tree.

## Significance for Agents
XAML provides a high-level way to describe "Human-in-the-loop" interfaces. Agents can dynamically generate XAML or update bound properties to show status, request approval, or visualize complex decision trees.

---
## References
- [[ms-learn-wpf-overview]] (Source)
- [[wpf-moc]]
- [[mvvm-pattern-dotnet]]
