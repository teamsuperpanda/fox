# Project: Fox

**Description:** A simple, local-first notes application for mobile devices, built exclusively with Flutter. The app allows users to create and manage notes, with all data stored locally on the device.

**Goal:** Modernize and maintain the Flutter application.

## UI/UX Proposal: "Subtle Serenity"

**Core Principles:**
*   **Clarity & Focus:** Notes are paramount; UI elements should support, not distract.
*   **Gentle Engagement:** Subtle animations and feedback to make interactions feel fluid and responsive.
*   **Warm Modernism:** A clean, contemporary look softened by inviting colors and approachable typography.

**1. Color Palette: "Dawn Chorus"**
*   **Primary (Background):** `#F8F5F1` (Soft Off-White) - A warm, inviting canvas, less stark than pure white.
*   **Accent 1 (Primary Action/Highlight):** `#8B9A6B` (Muted Sage Green) - Evokes calm, growth, and nature. Used for main CTAs, active states.
*   **Accent 2 (Secondary Action/Subtle Detail):** `#C7B8A5` (Warm Stone Grey) - For secondary buttons, dividers, subtle outlines. Grounding and sophisticated.
*   **Text/Icons:** `#333333` (Deep Charcoal) - Soft black for readability, less harsh than pure black.
*   **Error/Warning:** `#D9534F` (Soft Terracotta) - A warm, earthy red for alerts.

**2. Typography: "Readable Elegance"**
*   **Headings (e.g., Note Titles):** **'Lora'** (Serif) - Provides a touch of classic elegance and warmth, making titles feel significant.
*   **Body Text (Note Content, UI Labels):** **'Inter'** (Sans-serif) - Highly readable, modern, and clean. Ensures legibility at all sizes.
    *   **Font Sourcing:** The `google_fonts` package will be used to manage 'Lora' and 'Inter' fonts. This package automatically handles bundling fonts into the application's assets, ensuring they are available offline without requiring manual download and inclusion in `assets/fonts`.

**3. Iconography: "Clean & Approachable"**
*   **Style:** Outline icons with slightly rounded corners. Avoid overly complex or filled icons.
*   **Color:** Primarily `Deep Charcoal` (`#333333`), with `Muted Sage Green` (`#8B9A6B`) for active or primary action icons (e.g., "Add Note").

**4. Button Style: "Soft Interaction"**
*   **Primary Buttons (e.g., "Save Note", "Add New"):**
    *   **Background:** `Muted Sage Green` (`#8B9A6B`)
    *   **Text:** `Soft Off-White` (`#F8F5F1`)
    *   **Shape:** Slightly rounded rectangles (e.g., `borderRadius: 8.0`).
    *   **Elevation:** Subtle shadow on press, giving a gentle "push" feedback.
*   **Secondary/Outline Buttons (e.g., "Cancel", "Edit"):**
    *   **Background:** Transparent
    *   **Border:** 1px `Warm Stone Grey` (`#C7B8A5`)
    *   **Text:** `Deep Charcoal` (`#333333`)
    *   **Shape:** Matches primary buttons.
*   **Floating Action Button (FAB):** Circular, `Muted Sage Green` background, `Soft Off-White` icon.

**5. User Experience (UX): "Flow & Feedback"**
*   **Transitions:** Smooth, subtle fades or slides between screens. Avoid jarring cuts.
*   **Note List:** Clean, card-like entries with ample padding. A subtle hover/tap effect on notes to indicate interactivity.
*   **Note Detail:** Full-screen editor with minimal chrome. Focus on the content.
*   **Feedback:** Gentle haptic feedback on key interactions (e.g., saving, deleting). Subtle, non-intrusive snackbars for confirmations.
*   **Empty States:** Friendly, illustrative empty states (e.g., "No notes yet! Tap + to add one.") using the color palette.

**Personality & Identity:**
Fox, with "Subtle Serenity," feels like a calm, organized personal space. It's not loud or flashy, but its thoughtful details (warm colors, elegant fonts, gentle animations) create a sense of quiet confidence and ease of use. It's a reliable companion for your thoughts, designed to be a pleasant part of your daily routine.
