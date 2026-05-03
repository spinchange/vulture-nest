---
title: WPF MOC
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [windows-presentation-foundation, xaml-hub]
---
# WPF MOC

This map covers the WPF/XAML path for Windows-native desktop interfaces. In the vault, WPF is not a primary implementation lane, but it is a relevant option when a local human-facing control surface is more important than web portability.

## Core Concepts
Start here if you need the language of the framework itself.

* [[wpf-xaml-and-data-binding]]: XAML syntax, Data Binding engine, and Dependency Properties.

## Architecture
This section covers the application-structure layer that makes WPF maintainable.

* [[mvvm-pattern-dotnet]]: The canonical pattern for WPF apps.

## Agentic Use Cases
This is where WPF intersects with the Nest directly.

- **Desktop Bridges**: building UIs that allow humans to approve or monitor agent actions
- **Custom Widgets**: rendering dense local views of agent state or structured data
- **HITL Surfaces**: pairing [[hitl-ui-patterns]] with a Windows-native control plane

## Where To Start

1. Read [[wpf-xaml-and-data-binding]] for the framework model.
2. Then read [[mvvm-pattern-dotnet]] for the application architecture.
3. Then connect WPF back to [[hitl-ui-patterns]] if the goal is an approval or monitoring surface.

---
## See Also
* [[dotnet-moc]]
* [[javascript-on-desktop]]
* [[hitl-ui-patterns]]
- [[ms-learn-wpf-overview]]
