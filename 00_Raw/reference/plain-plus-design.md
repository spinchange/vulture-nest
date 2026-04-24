# Plain+ Design Specification: Project Summary

**Plain+** is a minimalist design system and aesthetic framework specifically engineered to counter the recognizable "fingerprint" of AI-generated user interfaces. It prioritizes semantic HTML, typographic restraint, and structural clarity over decorative elements.

### Core Goals
*   **Anti-AI Aesthetic:** To create interfaces that feel "human," "editorial," and "considered" by intentionally avoiding common LLM-generated design tropes (e.g., rounded corners, soft gradients, and purple/blue color ramps).
*   **Premium through Restraint:** To achieve a high-end feel by refining default browser rendering rather than adding visual "noise."
*   **Content-Forward Focus:** To serve as the primary vehicle for information-heavy artifacts like documentation, dashboards, admin panels, and developer tools where the interface should be transparent.

### Core Concepts
*   **The "Plus" Factor:** The system defines the "plus" as the gap between raw HTML and a professional layout, bridged through fluid type scales, specific font pairings, and disciplined spacing.
*   **Typographic Contrast:** A foundational rule pairing **Serif fonts** (e.g., Charter, Georgia) for body text with **System Sans-Serif fonts** for headings. This contrast creates hierarchy without requiring size or weight extremes.
*   **Warm Neutrals:** Replaces "cool digital grays" with warm-toned inks and surfaces (#1a1a1a ink on #fdfdfc surface) to mimic the feel of paper rather than a screen.
*   **Single Accent Discipline:** Exactly one accent color is permitted, used in no more than three specific locations (a top-page flourish, interactive hovers, and rare inline emphasis).
*   **Spatial Hierarchy:** Uses whitespace and thin 1px rules instead of containers, shadows, or thick borders to separate content.

### Project Structure
The specification is organized into 11 functional sections:
1.  **Philosophy:** The "why" behind the anti-AI aesthetic.
2.  **Decision Tree:** A guide to determine if Plain+ is appropriate for a specific project (Content-forward vs. Experience-forward).
3.  **Design Tokens:** Atomic CSS custom properties for type, color, spacing, and measure.
4.  **Typography:** Detailed rules for the Serif/Sans pairing and heading hierarchy.
5.  **Color:** The "Warmth Principle" and forbidden AI-signature colors (Purple, Teal, Startup Blue).
6.  **Spacing & Rhythm:** Vertical rhythm based on a 1.6rem base unit.
7.  **Components:** Specifications for buttons (square, no-pill), inputs, tables (no zebra stripes), and notices.
8.  **Layout Archetypes:** Standard patterns for documents, sidebars, and dashboards.
9.  **The Rules:** Ten non-negotiable mandates (e.g., **No border-radius**, **No gradients**, **No box-shadows**).
10. **React/JSX Usage:** Implementation patterns for modern frontend frameworks.
11. **Pre-Ship Checklist:** A verification list to ensure no "AI tells" have crept into the final artifact.

### Key Constraints ("The Rules")
To maintain the integrity of the system, several common design practices are strictly forbidden:
*   **No Border-Radius:** All elements must be square.
*   **No Gradients or Shadows:** Depth must come from hierarchy and spacing, not visual effects.
*   **No "AI Colors":** Explicit ban on purples, teals, and specific "SaaS blues."
*   **Whitespace over Containers:** Space is used to separate; boxes are viewed as unnecessary decoration.
