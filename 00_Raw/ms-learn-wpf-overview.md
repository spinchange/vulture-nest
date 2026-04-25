# Literature Note: Windows Presentation Foundation (WPF)
Source: https://learn.microsoft.com/en-us/dotnet/desktop/wpf/overview/
Date: 2026-04-25

WPF is a UI framework for building Windows desktop applications with a resolution-independent, vector-based rendering engine.

## Core Architectural Concepts
- **XAML (Extensible Application Markup Language):** An XML-based language for declarative UI definition.
- **Separation of Concerns:** Decoupling appearance (XAML) from behavior (Code-behind).
- **Dependency Properties:** An advanced property system that supports data binding, styling, and animation.
- **Routed Events:** An event system that allows events to "bubble" or "tunnel" through the element tree.

## Key Features
- **Data Binding Engine:** Automatic synchronization between UI elements and data sources.
- **Layout System:** Flexible containers (Grid, StackPanel, DockPanel) that adapt to window resizing.
- **Styles & Templates:** Powerful customization via `ControlTemplate` (changing look) and `DataTemplate` (changing data display).
- **Graphics & Animation:** Integrated support for 2D/3D graphics and hardware-accelerated animations.

## Fundamental Paradigms
- **Declarative UI:** Defining "what" the UI should look like rather than "how" to draw it.
- **MVVM (Model-View-ViewModel):** The architectural pattern optimized for WPF's data-binding capabilities.
